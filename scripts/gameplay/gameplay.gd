extends Node2D
## Pengendali utama gameplay: penerbangan, spawning, skor, map, dan game over.

const OBSTACLE_SCENES := {
	&"pillar": preload("res://scenes/gameplay/obstacles/pillar_obstacle.tscn"),
	&"stalactite": preload("res://scenes/gameplay/obstacles/stalactite_obstacle.tscn"),
	&"floating": preload("res://scenes/gameplay/obstacles/floating_obstacle.tscn"),
}
const COIN_SCENE: PackedScene = preload("res://scenes/items/coin.tscn")
const GEM_SCENE: PackedScene = preload("res://scenes/items/gem.tscn")
const IMPACT_EFFECT: PackedScene = preload("res://scenes/effects/one_shot_effect.tscn")
const FX_IMPACT := preload("res://assets/effects/fx_impact.png")
const FX_SPARK := preload("res://assets/effects/fx_spark.png")

const SPAWN_X := 700.0
const MAIN_MENU_PATH := "res://scenes/menus/main_menu.tscn"

enum State { READY, PLAYING, COUNTDOWN, PAUSED, GAMEOVER }

@onready var background: RunnerBackground = $Background
@onready var obstacles_root: Node2D = $World/Obstacles
@onready var items_root: Node2D = $World/Items
@onready var player: Player = $World/Player
@onready var effects: Node2D = $Effects
@onready var hud: HUD = $HUD
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var game_over_menu: GameOverMenu = $GameOverMenu

var state: int = State.READY
var scroll_speed: float = 0.0
var spawn_timer: float = 0.0
var obstacles: Array = []
var items: Array = []
var current_map: MapConfig
var map_index: int = -1

var _countdown_left: float = 0.0
var _state_before_pause: int = State.READY


func _ready() -> void:
	Game.begin_run()
	player.position = Vector2(Game.config.player_start_x, Game.config.player_start_y)
	player.configure(Game.selected_dragon())
	player.reset_for_new_run()
	player.obstacle_hit.connect(_on_player_obstacle_hit)
	player.item_picked.connect(_on_player_item_picked)
	hud.pause_pressed.connect(_pause)
	pause_menu.resume_requested.connect(_resume)
	pause_menu.home_requested.connect(_go_home)
	game_over_menu.retry_requested.connect(_retry)
	game_over_menu.home_requested.connect(_go_home)
	pause_menu.visible = false
	game_over_menu.visible = false
	scroll_speed = Game.config.base_scroll_speed
	# Inisialisasi mandiri: aman dijalankan langsung (F6) tanpa menu utama.
	if Game.map_catalog.size() > 0:
		_change_map(0, false)
	_enter_ready()
	AudioManager.play_music()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if state == State.PLAYING or state == State.READY or state == State.COUNTDOWN:
			_pause()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("flap"):
		_flap()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("pause"):
		_pause()


func _process(delta: float) -> void:
	var bg_speed: float = scroll_speed if state == State.PLAYING else Game.config.base_scroll_speed * 0.35
	background.advance(bg_speed * delta)

	if state == State.COUNTDOWN:
		_countdown_left -= delta
		var number: int = int(ceil(_countdown_left))
		if number > 0:
			hud.show_countdown(str(number))
		else:
			hud.hide_countdown()
			state = State.PLAYING
			player.start()
			spawn_timer = 1.0
		return

	if state != State.PLAYING:
		return

	_move_world(delta)
	hud.update_stats(Game.current_score(), Game.run_obstacles, Game.run_coins_collected, Game.run_gems_collected, player.shields_left)


func _enter_ready() -> void:
	state = State.READY
	player.stop()
	hud.show_countdown("")
	hud.hide_countdown()
	hud.set_hint("TAP / SPASI UNTUK TERBANG")
	hud.set_pause_visible(true)
	hud.update_stats(0, 0, 0, 0, player.shields_left)


func _flap() -> void:
	if state == State.READY:
		state = State.PLAYING
		player.start()
		hud.set_hint("")
		spawn_timer = 1.0
		player.flap()
	elif state == State.PLAYING:
		player.flap()


func _move_world(delta: float) -> void:
	var dist: float = scroll_speed * delta
	_move_nodes_and_prune(obstacles, dist, -140.0)
	_move_nodes_and_prune(items, dist, -80.0)

	spawn_timer -= delta
	if spawn_timer <= 0.0:
		_spawn_obstacle()
		spawn_timer = _current_spawn_interval()

	var cycle: int = int(Game.run_obstacles / 100.0)
	scroll_speed = minf(
		Game.config.max_scroll_speed,
		Game.config.base_scroll_speed
			+ Game.run_obstacles * Game.config.speed_increase_per_obstacle
			+ cycle * Game.config.base_scroll_speed * Game.config.difficulty_increase_per_cycle
	)


## Menggeser setiap node dalam `list` lalu membuang referensi yang sudah
## dibebaskan. Elemen array TIDAK di-assign ke variabel bertipe sebelum
## diverifikasi valid, sehingga tidak memicu
## "Trying to assign invalid previously freed instance".
func _move_nodes_and_prune(list: Array, dist: float, min_x: float) -> void:
	for i in range(list.size() - 1, -1, -1):
		if not is_instance_valid(list[i]):
			list.remove_at(i)
			continue
		var node: Node2D = list[i]
		node.position.x -= dist
		if node.position.x < min_x:
			node.queue_free()
			list.remove_at(i)


## Menyimpan node ke daftar sekaligus menghapus referensinya dari daftar
## begitu node keluar dari tree (mis. koin diambil lalu queue_free oleh
## Collectible). Dengan begini daftar tidak pernah menyimpan referensi ke
## objek yang sudah dibebaskan.
func _track(list: Array, node: Node) -> void:
	list.append(node)
	node.tree_exiting.connect(_on_tracked_exiting.bind(list, node), CONNECT_ONE_SHOT)


func _on_tracked_exiting(list: Array, node: Node) -> void:
	var index: int = list.find(node)
	if index != -1:
		list.remove_at(index)


func _current_spawn_interval() -> float:
	var cycle: int = int(Game.run_obstacles / 100.0)
	return maxf(
		Game.config.min_spawn_interval,
		Game.config.spawn_interval
			- Game.run_obstacles * Game.config.spawn_interval_shrink_per_obstacle
			- cycle * 0.08
	)


func _current_gap_height() -> float:
	var cycle: int = int(Game.run_obstacles / 100.0)
	return maxf(
		Game.config.min_gap_height,
		Game.config.gap_height
			- Game.run_obstacles * Game.config.gap_shrink_per_obstacle
			- cycle * 6.0
	)


func _spawn_obstacle() -> void:
	var map := current_map
	var types: Array = map.obstacle_types if map != null else [&"pillar"]
	if types.is_empty():
		types = [&"pillar"]
	var type: StringName = types[randi() % types.size()]
	var scene: PackedScene = OBSTACLE_SCENES.get(type, OBSTACLE_SCENES[&"pillar"])
	var obs: Obstacle = scene.instantiate()
	obstacles_root.add_child(obs)
	obs.position = Vector2(SPAWN_X, 0.0)
	var gap: float = _current_gap_height()
	if obs.mode == 1:
		var cy: float = randf_range(Game.config.spawn_margin_top + 30.0, 360.0 - Game.config.spawn_margin_bottom - 30.0)
		obs.configure_single(cy)
		# Item diletakkan di ruang aman di atas / bawah batu, BUKAN di dalam
		# badan batu (dulu koin muncul di tengah batu sehingga naga harus
		# menabrak batu untuk mengambilnya -> seolah koin menyebabkan kematian).
		_maybe_spawn_items(_safe_floating_item_y(cy), 40.0)
	else:
		var lo: float = Game.config.spawn_margin_top + gap * 0.5
		var hi: float = 360.0 - Game.config.spawn_margin_bottom - gap * 0.5
		var cy: float = randf_range(lo, hi)
		obs.configure_pair(cy, gap)
		_maybe_spawn_items(cy, gap)
	obs.passed.connect(_on_obstacle_passed)
	_track(obstacles, obs)


## Mengembalikan posisi Y yang aman untuk item di sekitar batu mengambang
## agar tidak berada di dalam badan batu (batu ±26 px + radius item + margin).
func _safe_floating_item_y(rock_center_y: float) -> float:
	var clearance: float = 54.0
	var below: float = rock_center_y + clearance
	var above: float = rock_center_y - clearance
	var options: Array = []
	if below <= 320.0:
		options.append(below)
	if above >= 40.0:
		options.append(above)
	if options.is_empty():
		return clampf(rock_center_y, 40.0, 320.0)
	return options[randi() % options.size()]


func _maybe_spawn_items(center_y: float, _span: float) -> void:
	# Koin tersusun horizontal di tengah celah.
	if randf() < 0.75:
		var count: int = randi_range(1, 3)
		var y: float = clampf(center_y, 40.0, 320.0)
		for i in count:
			var coin: Collectible = COIN_SCENE.instantiate()
			coin.position = Vector2(SPAWN_X + (i - (count - 1) * 0.5) * 24.0, y)
			items_root.add_child(coin)
			_track(items, coin)
	# Gem langka.
	if randf() < Game.config.rare_gem_chance:
		var gem: Collectible = GEM_SCENE.instantiate()
		gem.position = Vector2(SPAWN_X + 60.0, clampf(center_y, 40.0, 320.0))
		items_root.add_child(gem)
		_track(items, gem)


func _on_obstacle_passed() -> void:
	Game.run_obstacles += 1
	Game.run_base_points += 1
	Game.run_coins_collected += Game.config.coins_per_obstacle
	if Game.config.gem_every_obstacles > 0 and Game.run_obstacles % Game.config.gem_every_obstacles == 0:
		Game.run_gems_collected += 1
	AudioManager.play_sfx("coin")
	var per: int = maxi(1, Game.map_catalog.obstacles_per_map)
	var count: int = maxi(1, Game.map_catalog.size())
	var new_index: int = int(Game.run_obstacles / float(per)) % count
	if new_index != map_index:
		_change_map(new_index, true)


func _change_map(index: int, animate: bool) -> void:
	if Game.map_catalog.size() == 0:
		return
	index = clampi(index, 0, Game.map_catalog.size() - 1)
	map_index = index
	current_map = Game.map_catalog.maps[index]
	if not animate or hud == null:
		background.apply_map(current_map)
		return
	var tween := create_tween()
	tween.tween_method(hud.set_fade, 0.0, 0.85, 0.9)
	tween.tween_callback(func() -> void:
		background.apply_map(current_map)
		hud.show_map_name(current_map.display_name)
	)
	tween.tween_method(hud.set_fade, 0.85, 0.0, 1.1)


func _on_player_obstacle_hit() -> void:
	if state != State.PLAYING:
		return
	AudioManager.play_sfx("hit")
	_spawn_effect(FX_IMPACT, player.global_position)
	var dead: bool = player.on_hit()
	if dead:
		_game_over()
	else:
		hud.update_stats(Game.current_score(), Game.run_obstacles, Game.run_coins_collected, Game.run_gems_collected, player.shields_left)


func _on_player_item_picked(kind: int, value: int) -> void:
	_spawn_effect(FX_SPARK, player.global_position)
	if kind == 1:
		Game.run_gems_collected += value
		AudioManager.play_sfx("gem")
	else:
		Game.run_coins_collected += value
		AudioManager.play_sfx("coin")


func _spawn_effect(texture: Texture2D, world_pos: Vector2) -> void:
	var effect: OneShotEffect = IMPACT_EFFECT.instantiate()
	effect.setup(texture)
	effects.add_child(effect)
	effect.global_position = world_pos


func _game_over() -> void:
	state = State.GAMEOVER
	player.stop()
	_finish_run()
	hud.set_pause_visible(false)
	hud.hide_countdown()
	game_over_menu.show_results({
		"score": Game.current_score(),
		"obstacles": Game.run_obstacles,
		"base_points": Game.run_base_points,
		"bonus": Game.selected_dragon().point_bonus if Game.selected_dragon() != null else 0.0,
		"coins": Game.run_coins_collected,
		"gems": Game.run_gems_collected,
		"high_score": SaveManager.high_score,
	})


## Hadiah dikreditkan tepat satu kali per permainan.
func _finish_run() -> void:
	if Game.run_reward_credited:
		return
	Game.run_reward_credited = true
	SaveManager.add_gems(Game.run_gems_collected)
	SaveManager.add_coins(Game.run_coins_collected)
	SaveManager.set_high_score(Game.current_score())


func _clear_world() -> void:
	for obs in obstacles:
		if is_instance_valid(obs):
			obs.queue_free()
	for item in items:
		if is_instance_valid(item):
			item.queue_free()
	obstacles.clear()
	items.clear()


func _pause() -> void:
	if state != State.PLAYING and state != State.READY and state != State.COUNTDOWN:
		return
	_state_before_pause = state
	state = State.PAUSED
	pause_menu.visible = true
	get_tree().paused = true


func _resume() -> void:
	pause_menu.visible = false
	get_tree().paused = false
	if _state_before_pause == State.READY:
		_enter_ready()
	else:
		state = State.COUNTDOWN
		_countdown_left = float(Game.config.countdown_seconds)
		hud.show_countdown(str(Game.config.countdown_seconds))


func _retry() -> void:
	game_over_menu.visible = false
	_clear_world()
	Game.begin_run()
	player.position = Vector2(Game.config.player_start_x, Game.config.player_start_y)
	player.reset_for_new_run()
	scroll_speed = Game.config.base_scroll_speed
	_change_map(0, false)
	hud.set_fade(0.0)
	_enter_ready()


func _go_home() -> void:
	_finish_run()
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_PATH)