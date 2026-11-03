class_name MapCatalog
extends Resource
## Katalog empat map. Map berganti tiap 25 rintangan (lihat GAME_CONFIG).

@export var maps: Array[MapConfig] = []
## Jumlah rintangan per map sebelum berganti.
@export var obstacles_per_map: int = 25


func get_map_for_obstacles(passed: int) -> MapConfig:
	if maps.is_empty():
		return null
	var per: int = maxi(1, obstacles_per_map)
	var index: int = int(passed / float(per)) % maps.size()
	return maps[index]


func size() -> int:
	return maps.size()