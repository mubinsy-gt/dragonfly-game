class_name DragonCatalog
extends Resource
## Katalog semua naga yang tersedia. Diisi lewat Inspector.

@export var dragons: Array[DragonData] = []


func get_by_id(id: StringName) -> DragonData:
	for dragon in dragons:
		if dragon != null and dragon.id == id:
			return dragon
	return null


func index_of(id: StringName) -> int:
	for i in dragons.size():
		if dragons[i] != null and dragons[i].id == id:
			return i
	return -1


func size() -> int:
	return dragons.size()