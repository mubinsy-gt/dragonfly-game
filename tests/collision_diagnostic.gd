extends Node2D
## Diagnostic: memverifikasi pemisahan collision item (pickup) vs rintangan (damage).

var _events: Array[String] = []


func _ready() -> void:
	print("=== DRAGON FLY collision diagnostic ===")
	await _test_coin()
	await _test_gem()
	await _test_obstacle()
	await _test_spawn_placement()
	await _test_counter_increment()
	await _test_freed_reference()
	print("=== diagnostic finished ===")
	get_tree().quit()


func _spawn_player(pos: Vector2) -> Player:
	var p: Player = (load("res://scenes/gameplay/player.tscn") as PackedScene).instantiate()
	p.position = pos
	add_child(p)
	p.configure(Game.selected_dragon())
	p.reset_for_new_run()
	p.start()
	p.obstacle_hit.connect(func() -> void: _events.append("OBSTACLE_HIT"))
	p.item_picked.connect(func(k: int, v: int) -> void: _events.append("ITEM_PICKED_%d_%d" % [k, v]))
	return p


func _test_coin() -> void:
	_events.clear()
	var dragon := Game.selected_dragon()
	var p: Player = _spawn_player(Vector2(300, 180))
	var c: Area2D = (load("res://scenes/items/coin.tscn") as PackedScene).instantiate()
	c.position = Vector2(322, 180)
	add_child(c)
	print("COIN  : coin.layer=", c.collision_layer, " coin.mask=", c.collision_mask,
		" | hurtbox.mask=", p.get_node("Hurtbox").collision_mask,
		" | magnet.mask=", p.get_node("Magnet").collision_mask,
		" | shields_before=", p.shields_left)
	await get_tree().create_timer(0.4).timeout
	print("COIN  : events=", _events, " shields_after=", p.shields_left, " (dragon has ", dragon.shields, " shields)")
	p.queue_free()
	if is_instance_valid(c):
		c.queue_free()
	await get_tree().process_frame


func _test_gem() -> void:
	_events.clear()
	var p: Player = _spawn_player(Vector2(300, 180))
	var g: Area2D = (load("res://scenes/items/gem.tscn") as PackedScene).instantiate()
	g.position = Vector2(322, 180)
	add_child(g)
	print("GEM   : gem.layer=", g.collision_layer)
	await get_tree().create_timer(0.4).timeout
	print("GEM   : events=", _events, " shields_after=", p.shields_left)
	p.queue_free()
	if is_instance_valid(g):
		g.queue_free()
	await get_tree().process_frame


func _test_obstacle() -> void:
	_events.clear()
	# Player di dalam pilar atas (gap center 180, gap 120 -> pilar atas 0..120).
	var p: Player = _spawn_player(Vector2(300, 60))
	var o: Obstacle = (load("res://scenes/gameplay/obstacles/pillar_obstacle.tscn") as PackedScene).instantiate()
	o.position = Vector2(300, 0)
	add_child(o)
	o.configure_pair(180.0, 120.0)
	print("PILLAR: pillar hit areas groups -> top=", o.get_node("Top/Hit").is_in_group("obstacle"),
		" bottom=", o.get_node("Bottom/Hit").is_in_group("obstacle"))
	await get_tree().create_timer(0.4).timeout
	print("PILLAR: events=", _events, " shields_after=", p.shields_left)
	p.queue_free()
	o.queue_free()
	await get_tree().process_frame


func _test_spawn_placement() -> void:
	print("--- spawn placement test (80 obstacles) ---")
	var gp: Node2D = (load("res://scenes/gameplay/gameplay.tscn") as PackedScene).instantiate()
	add_child(gp)
	gp.set_process(false)
	await get_tree().process_frame
	var floating_seen: int = 0
	var items_checked: int = 0
	var overlaps: int = 0
	for n in 80:
		gp._spawn_obstacle()
		var obs = gp.obstacles[0]
		if obs.mode == 1:
			floating_seen += 1
		var new_items: Array = gp.items.duplicate()
		for it in new_items:
			items_checked += 1
			if _item_overlaps_obstacle(it, obs):
				overlaps += 1
				print("  OVERLAP mode=", obs.mode, " item_y=", it.position.y, " obs_y=", obs.position.y)
		obs.queue_free()
		for it in new_items:
			it.queue_free()
		gp.obstacles.clear()
		gp.items.clear()
		await get_tree().process_frame
	gp.queue_free()
	print("SPAWN : floating=", floating_seen, " items=", items_checked, " overlaps=", overlaps, " (harus 0)")


func _test_counter_increment() -> void:
	print("--- live counter test (via gameplay scene) ---")
	var gp: Node2D = (load("res://scenes/gameplay/gameplay.tscn") as PackedScene).instantiate()
	add_child(gp)
	gp.set_process(false)
	await get_tree().process_frame
	var before: int = Game.run_coins_collected
	var player: Player = gp.player
	var coin: Area2D = (load("res://scenes/items/coin.tscn") as PackedScene).instantiate()
	coin.position = player.position
	gp.get_node("World/Items").add_child(coin)
	await get_tree().create_timer(0.4).timeout
	var after: int = Game.run_coins_collected
	print("COUNTER: before=", before, " after=", after, " delta=", after - before,
		" (harus +1) shields=", player.shields_left, " alive=", not gp.get_node("GameOverMenu").visible)
	gp.queue_free()
	await get_tree().process_frame


func _test_freed_reference() -> void:
	print("--- freed reference test (reproduksi error yang dilaporkan) ---")
	var gp: Node2D = (load("res://scenes/gameplay/gameplay.tscn") as PackedScene).instantiate()
	add_child(gp)
	gp.set_process(false)
	await get_tree().process_frame
	# Koin di atas pemain -> terambil -> Collectible memanggil queue_free().
	var coin: Area2D = (load("res://scenes/items/coin.tscn") as PackedScene).instantiate()
	coin.position = gp.player.position
	gp.get_node("World/Items").add_child(coin)
	await get_tree().create_timer(0.3).timeout
	print("items setelah diambil = ", gp.items.size())
	await get_tree().create_timer(0.3).timeout
	print("items setelah benar-benar bebas = ", gp.items.size())
	# Kasus terburuk: paksa referensi basi ke dalam array (perilaku lama).
	var stale: Node2D = (load("res://scenes/items/coin.tscn") as PackedScene).instantiate()
	add_child(stale)
	stale.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	gp.items.append(stale)
	print("referensi basi valid? ", is_instance_valid(stale), " (harus false) items=", gp.items.size())
	for k in 40:
		gp._move_world(0.016)
	print("OK: _move_world x40 dengan referensi basi tanpa error; items=", gp.items.size())
	gp.queue_free()
	await get_tree().process_frame


func _item_overlaps_obstacle(item: Node2D, obs: Node2D) -> bool:
	for path in ["Top/Hit", "Bottom/Hit", "Hit"]:
		var hit: Area2D = obs.get_node_or_null(path)
		if hit == null or not hit.visible:
			continue
		var shape_node: CollisionShape2D = hit.get_node_or_null("Shape")
		if shape_node == null or shape_node.shape == null:
			continue
		var rect_shape: RectangleShape2D = shape_node.shape
		var center: Vector2 = hit.global_position
		var rect := Rect2(center - rect_shape.size * 0.5, rect_shape.size).grow(14.0)
		if rect.has_point(item.global_position):
			return true
	return false