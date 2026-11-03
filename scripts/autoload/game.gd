extends Node
## Game (autoload) - katalog global, status satu permainan, dan perhitungan skor.

const CONFIG_PATH := "res://resources/config/game_config.tres"
const DRAGON_CATALOG_PATH := "res://resources/dragons/dragon_catalog.tres"
const MAP_CATALOG_PATH := "res://resources/maps/map_catalog.tres"

var config: GameConfig
var dragon_catalog: DragonCatalog
var map_catalog: MapCatalog

# --- status satu permainan (direset setiap mulai) ---
var run_obstacles: int = 0
var run_base_points: int = 0
var run_coins_collected: int = 0
var run_gems_collected: int = 0
var run_reward_credited: bool = false


func _ready() -> void:
	config = load(CONFIG_PATH) as GameConfig
	dragon_catalog = load(DRAGON_CATALOG_PATH) as DragonCatalog
	map_catalog = load(MAP_CATALOG_PATH) as MapCatalog
	if config == null:
		push_warning("DragonFly: GameConfig tidak ditemukan, memakai default.")
		config = GameConfig.new()
	if dragon_catalog == null:
		push_warning("DragonFly: DragonCatalog tidak ditemukan.")
		dragon_catalog = DragonCatalog.new()
	if map_catalog == null:
		push_warning("DragonFly: MapCatalog tidak ditemukan.")
		map_catalog = MapCatalog.new()


func selected_dragon() -> DragonData:
	var data: DragonData = dragon_catalog.get_by_id(StringName(SaveManager.selected_dragon))
	if data == null and not dragon_catalog.dragons.is_empty():
		data = dragon_catalog.dragons[0]
	return data


## Skor akhir = total poin dasar x (1 + bonus). Dibulatkan ke bawah.
func compute_score(base_points: int, bonus: float) -> int:
	return int(floor(float(base_points) * (1.0 + bonus)))


func current_score() -> int:
	var dragon := selected_dragon()
	var bonus := dragon.point_bonus if dragon != null else 0.0
	return compute_score(run_base_points, bonus)


func begin_run() -> void:
	run_obstacles = 0
	run_base_points = 0
	run_coins_collected = 0
	run_gems_collected = 0
	run_reward_credited = false