# DialogueBox.gd - Godot 4.7
# Sistema de diálogo com efeito typewriter (letra por letra) + retrato do NPC
#
# Uso:
#   dialogue_box.start_dialogue([
#       { "text": "Olá, sou o Seringueiro.", "portrait": "seringueiro" },
#       { "text": "Você encontrou minha faca?", "portrait": "seringueiro" }
#   ])
#
# Sinais emitidos:
#   signal dialogue_finished()

extends Control

@onready var bg: ColorRect = $Panel
@onready var text_label: Label = $Panel/TextLabel
@onready var portrait: TextureRect = $Panel/Portrait
@onready var continue_hint: Label = $Panel/ContinueHint

signal dialogue_finished

# Estado interno
var _dialogue_queue: Array[Dictionary] = []
var _last_dialogue: Array[Dictionary] = []
var _current_index: int = 0
var _char_index: int = 0
var _is_typing: bool = false
var _type_speed: float = 0.03  # segundos por caractere
var _timer: Timer

func _ready() -> void:
	add_to_group("DialogueBox")
	_timer = Timer.new()
	_timer.wait_time = _type_speed
	_timer.one_shot = true
	_timer.timeout.connect(_on_type_timer_timeout)
	add_child(_timer)
	hide()
	if continue_hint:
		continue_hint.visible = false

# --- API Pública ---
func start_dialogue(dialogue_data: Array[Dictionary]) -> void:
	if dialogue_data.is_empty():
		return
	
	_dialogue_queue = dialogue_data
	_last_dialogue = dialogue_data.duplicate()
	_current_index = 0
	_char_index = 0
	_is_typing = true
	
	# Trava movimento do player
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("set_dialogue_active"):
		player.set_dialogue_active(true)
	
	show()
	continue_hint.visible = false
	_process_next_line()

# --- Lógica Typewriter ---
func _process_next_line() -> void:
	if _current_index >= _dialogue_queue.size():
		_finish_dialogue()
		return
	
	var entry := _dialogue_queue[_current_index]
	
	# Definir retrato (se houver e arquivo existir)
	if entry.has("portrait") and entry["portrait"]:
		var portrait_path = "res://assets/portraits/%s.png" % entry["portrait"]
		if FileAccess.file_exists(portrait_path):
			portrait.texture = load(portrait_path)
			portrait.visible = true
		else:
			portrait.visible = false
	else:
		portrait.visible = false
	
	# Resetar e iniciar digitação
	_char_index = 0
	_is_typing = true
	_timer.start()

func _on_type_timer_timeout() -> void:
	if _dialogue_queue.is_empty() or _current_index >= _dialogue_queue.size():
		_timer.stop()
		return
	var entry := _dialogue_queue[_current_index]
	var full_text: String = entry["text"]
	
	if _char_index < full_text.length():
		_char_index += 1
		text_label.text = full_text.substr(0, _char_index)
		_timer.start()
	else:
		_is_typing = false
		continue_hint.visible = true

func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event.is_action_pressed("ui_accept"):
		if _is_typing:
			# Pular typewriter → mostrar linha completa
			var entry := _dialogue_queue[_current_index]
			text_label.text = entry["text"]
			_char_index = entry["text"].length()
			_is_typing = false
			continue_hint.visible = true
			_timer.stop()
		else:
			# Avançar para próxima linha
			_current_index += 1
			continue_hint.visible = false
			_process_next_line()

func restart_dialogue() -> void:
	# Reinicia o diálogo com as últimas linhas
	if _last_dialogue.is_empty():
		return
	start_dialogue(_last_dialogue.duplicate())

func _finish_dialogue() -> void:
	_timer.stop()
	hide()
	_dialogue_queue.clear()
	_current_index = 0
	_char_index = 0
	_is_typing = false
	continue_hint.visible = false
	emit_signal("dialogue_finished")
	# Libera movimento do player
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("set_dialogue_active"):
		player.set_dialogue_active(false)
