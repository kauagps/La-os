extends Area2D

@export var max_items: int = 3
var items: Array[StringName] = []

signal item_added(name: StringName)

func add_item(name: StringName) -> bool:
	if items.size() >= max_items:
		return false
	items.append(name)
	emit_signal("item_added", name)
	print("Inventário: " + str(items))
	return true

func has_item(name: StringName) -> bool:
	return items.has(name)

func remove_item(name: StringName) -> bool:
	var idx = items.find(name)
	if idx >= 0:
		items.remove_at(idx)
		return true
	return false
