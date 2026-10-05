extends Area2D

@export var item_name: StringName = &"facaseringueiro"
@export var item_text: String = "Pires do seringueiro"

func _ready() -> void:
	add_to_group("Interactable")

func interact(player: Node2D) -> void:
	var inv = player.get_node_or_null("Inventory")
	if inv == null:
		print("Sem inventário no jogador!")
		return
	if inv.add_item(item_name):
		print("Pegou item: %s" % item_text)
		if player.has_method("set_has_pires"):
			player.set_has_pires(true)
		queue_free()
	else:
		print("Inventário cheio!")
