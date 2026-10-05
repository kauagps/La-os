# Player.gd - Godot 4.7
# Fase 1: Foundation - Movement + Collision + Interaction
#
# Node hierarchy expected (player.tscn):
#   CharacterBody2D (Player)
#     ├── CollisionShape2D  (wall/physics collision)
#     ├── Sprite2D          (visual placeholder)
#     └── Area2D            (Interaction detection range)
#         └── CollisionShape2D (trigger shape)

extends CharacterBody2D

# --- Configuráveis ---
@export var speed: float = 180.0          # velocidade de movimento
@export var interaction_distance: float = 48.0

# Mapear ação de ataque
@export var attack_action: StringName = &"attack"

@export var vida_max: int = 100
var vida: int = 100  # distância para interagir

# --- Estado interno ---
var _can_interact: bool = true
var _interaction_target: Node2D = null     # objeto/NPC próximo
var _dialogue_active: bool = false
var _is_attacking: bool = false
var _has_pires: bool = false

# --- Sinais ---
signal interact_requested
signal item_delivered(item_name: String)

func set_has_pires(has: bool) -> void:
	_has_pires = has
	var anim = $AnimatedSprite2D
	if anim:
		if has:
			anim.animation = "with_pires"
			anim.play()
		else:
			anim.animation = "default"
			anim.play()

func _ready() -> void:
	# Registrar este player para queries globais
	add_to_group("Player")
	# Criar inventário se não existir (montado manualmente no Godot)
	if get_node_or_null("Inventory") == null:
		var inv = preload("res://scripts/inventory.gd").new()
		inv.name = "Inventory"
		add_child(inv)
	print("Player ready — movement + interaction active.")

func _physics_process(_delta: float) -> void:
	if _dialogue_active:
		velocity = Vector2.ZERO
		return
	_handle_movement()
	_detect_interaction_target()

func _input(event: InputEvent) -> void:
	print("INPUT EVENT: ", event.as_text())
	# Tecla 'E' (ui_accept) dispara interação
	if event.is_action_pressed("ui_accept") and _can_interact:
		# Evitar interagir enquanto diálogo está visível
		var dialogue = get_tree().get_first_node_in_group("DialogueBox")
		if dialogue and dialogue.visible:
			return
		if _interaction_target and _interaction_target.has_method("interact"):
			_interaction_target.interact(self)
			emit_signal("interact_requested")
	# Ataque curto
	if event.is_action_pressed("attack") and not _dialogue_active:
		var bodies = get_tree().get_nodes_in_group("Interactable")
		for obj in bodies:
			if global_position.distance_to(obj.global_position) < 70:
				if obj.has_method("tomar_dano"):
					obj.tomar_dano(15)
					var dir = (obj.global_position - global_position).normalized()
					obj.global_position += dir * 15.0
		# Sprite "fight" ao atacar
		var anim = $AnimatedSprite2D
		if anim:
			anim.animation = "fight"
			anim.play()
			_is_attacking = true
			get_tree().create_timer(0.3).timeout.connect(func():
				_is_attacking = false
				if is_instance_valid(anim) and anim.animation == "fight":
					anim.animation = "default"
			)

# --- Movimento WASD / Setas ---
func _handle_movement() -> void:
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if input_dir.length() > 0 and not _is_attacking:
		input_dir = input_dir.normalized()
		velocity = input_dir * speed
		# Muda animação pelo sentido
		var anim = $AnimatedSprite2D
		if anim:
			if input_dir.y > 0.5:
				anim.animation = "walk front"
			elif input_dir.y < -0.5:
				anim.animation = "walk back"
			elif input_dir.x > 0.5 or input_dir.x < -0.5:
				anim.animation = "walk lado"
			anim.play()
			anim.scale.x = -1.0 if input_dir.x < 0 else 1.0
	else:
		velocity = Vector2.ZERO
		if not _is_attacking:
			var anim = $AnimatedSprite2D
			if anim:
				anim.animation = "default"
				anim.play()

	move_and_slide()

# --- Detecção de Alvo de Interação ---
func _detect_interaction_target() -> void:
	# Raycast ou distância mínima até NPCs/objetos com grupo "Interactable"
	var closest: Node2D = null
	var closest_dist := INF

	for obj in get_tree().get_nodes_in_group("Interactable"):
		var dist := global_position.distance_to(obj.global_position)
		if dist < interaction_distance and dist < closest_dist:
			closest = obj
			closest_dist = dist
	
	_interaction_target = closest

# --- API pública para entrega de item ---
func set_dialogue_active(active: bool) -> void:
	_dialogue_active = active
	_can_interact = not active

func tomar_dano(quantidade: int) -> void:
	vida = max(vida - quantidade, 0)
	print("Vida: %d / %d" % [vida, vida_max])
	# Atualiza barra visual se existir
	var bar = get_tree().current_scene.get_node_or_null("UI/HealthBar")
	if bar == null:
		bar = get_tree().current_scene.get_node_or_null("HealthBar")
	if bar == null:
		bar = get_node("/root/Main/Player/Camera2D/HealthBar")
	if bar:
		bar.scale.x = float(vida) / float(vida_max)
	if vida <= 0:
		print("Morreu!")

func deliver_item(item_name: String) -> void:
	emit_signal("item_delivered", item_name)
