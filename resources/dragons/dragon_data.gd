class_name DragonData
extends Resource
## Definisi satu naga: harga, statistik, dan referensi visual.
## Semua nilai dapat diedit melalui Inspector pada file .tres terkait.

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Purchase")
## Harga naga. Naga pertama (gratis) memakai 0.
@export var price: int = 0
@export_enum("coin", "gem") var currency: String = "coin"

@export_group("Gameplay Stats")
## Bonus poin sebagai pecahan (0.05 = +5%). Hanya memengaruhi skor.
@export_range(0.0, 5.0, 0.01) var point_bonus: float = 0.0
## Radius magnet dalam piksel pada resolusi dasar 640x360.
@export var magnet_radius: float = 32.0
## Jumlah pelindung (penyerap benturan) yang dimiliki naga.
@export var shields: int = 0

@export_group("Visual")
## Scene visual naga (Node2D dengan AnimatedSprite2D animasi terbang).
@export var scene: PackedScene
## Ikon naga untuk toko dan HUD.
@export var icon: Texture2D


## "Gratis" untuk harga 0, selain itu angka biasa.
func price_text() -> String:
	if price <= 0:
		return "GRATIS"
	return str(price)


func currency_label() -> String:
	return "GEM" if currency == "gem" else "KOIN"


func bonus_percent_text() -> String:
	return "%+d%%" % roundi(point_bonus * 100.0)