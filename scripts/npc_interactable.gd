# NPCInteractable.gd - Godot 4.7
# Exemplo de NPC interativo para teste da Fase 1
#
# Grupo: "Interactable" (automático)
# O script deve estar vinculado à cena do NPC!
#
# Variáveis exportáveis:
#   dialogue_lines: Array[Dictionary] → falas do NPC
#   required_item: StringName → item necessário para curar (opcional)

extends Area2D

signal npc_rescued(path: NodePath)

@export var dialogue_lines: Array[Dictionary] = [
	{"text": "Eu perdi meu pires... não consigo\ncontar minha história sem ela.", "portrait": "seringueiro"},
	{"text": "Se você encontrar meu pires,\nficarei eternamente grato.", "portrait": "seringueiro"},
	{"text": "A floresta está escura demais...\neu preciso voltar para a base.", "portrait": "seringueiro"}
]
@export var required_item: StringName = &"facaseringueiro"

@export var vida_max: int = 50
var vida: int = 50

var _is_interactable: bool = true
var _damage_timer: Timer = null
var _stunned: bool = false

func _ready() -> void:
	add_to_group("Interactable")
	_update_visual_state()
	print("NPC pronto: %s" % (dialogue_lines[0]["text"]))
	_damage_timer = Timer.new()
	_damage_timer.wait_time = 0.5
	_damage_timer.one_shot = true
	add_child(_damage_timer)

# --- Ataque básico (quando próximo) ---
var _speed_current: float = 30.0
const SPEED_MAX: float = 60.0

func _process(delta: float) -> void:
	if vida <= 0:
		return
	if _stunned:
		return
	# Perseguição básica
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var dir: Vector2 = (player.global_position - global_position).normalized()
		global_position += dir * _speed_current * delta
		_speed_current = min(_speed_current + 10.0 * delta, SPEED_MAX)

	if _damage_timer and not _damage_timer.is_stopped():
		return
	var bodies = get_overlapping_bodies()
	for b in bodies:
		if b.has_method("tomar_dano"):
			b.tomar_dano(10)
			_damage_timer.start()

# --- Chamado pelo Player quando pressiona 'E' próximo ---
func interact(player: Node2D) -> void:
	# Só dialoga se derrotado (vida <= 0) ou se tem item
	var tem_item := false
	var player_inv = player.get_node_or_null("Inventory")
	if required_item and player_inv:
		tem_item = player_inv.has_item(required_item)
	
	if vida > 0 and not tem_item:
		return

	# Se tem item necessário: agradece e remove
	if required_item and player_inv and player_inv.has_item(required_item):
		player_inv.remove_item(required_item)
		print("NPC recebeu o item! Agradece!")
		# Diálogo de agradecimento
		_show_dialogue([{"text":"Muito obrigado! Você me salvou...\nA floresta agora tem luz.","portrait":"seringueiro"}])
		# Emitir sinal de resgate
		var root = get_tree().current_scene
		if root:
			root.emit_signal("npc_rescued", get_path())
		return

	# Se ainda não derrotado, aplica dano
	if vida > 0 and tem_item:
		vida = 0
		var anim = $AnimatedSprite2D
		if anim:
			anim.animation = "default"
			anim.play()
	
	# Verificar se o jogador tem o item necessário
	if required_item and player_inv and not player_inv.has_item(required_item):
		_show_dialogue([{"text": "Preciso encontrar meu item antes...", "portrait": "seringueiro"}])
		return
	
	# Mostrar diálogo (pode repetir)
	_show_dialogue(dialogue_lines)
	# Removido: _is_interactable = false  (para poder dialogar de novo)
	
	# Muda animação ao ser resgatado
	var anim = $AnimatedSprite2D
	if anim:
		anim.animation = "default"
		anim.play()
	
	# Notificar a base (se Main existir)
	var root = get_tree().current_scene
	if root:
		root.emit_signal("npc_rescued", get_path())
	
	print("NPC resgatado!")

# --- Exibir diálogo ---
func tomar_dano(quantidade: int) -> void:
	vida = max(vida - quantidade, 0)
	print("NPC vida: %d / %d" % [vida, vida_max])
	# Atualiza barra visual se existir (dentro do NPC ou na cena)
	var bar = find_child("HealthBar")
	if bar == null:
		bar = find_child("UI/EnemyHealth")
	if bar == null:
		bar = get_tree().current_scene.get_node_or_null("EnemyHealth")
	if bar == null:
		bar = get_tree().current_scene.get_node_or_null("UI/EnemyHealth")
	if bar:
		bar.scale.x = float(vida) / float(vida_max)
	# Paralisa por 1s após qualquer dano
	_stunned = true
	if _damage_timer == null or not is_instance_valid(_damage_timer):
		_damage_timer = Timer.new()
		_damage_timer.wait_time = 1.0
		_damage_timer.one_shot = true
		add_child(_damage_timer)
	_damage_timer.start()
	if vida <= 0:
		print("NPC derrotado!")
	# Paralisa por 1s após dano
	_stunned = true
	var stun_timer = Timer.new()
	stun_timer.wait_time = 1.0
	stun_timer.one_shot = true
	add_child(stun_timer)
	stun_timer.timeout.connect(func():
		_stunned = false
		stun_timer.queue_free()
	)
	stun_timer.start()

func _show_dialogue(lines: Array[Dictionary]) -> void:
	var dialogue_box = get_tree().get_first_node_in_group("DialogueBox")
	if dialogue_box:
		dialogue_box.start_dialogue(lines)

# --- Feedback visual simples ---
func _update_visual_state() -> void:
	var anim = $AnimatedSprite2D
	if anim:
		anim.animation = "default"
		anim.play()
	# Se tiver sprite, muda cor para indicar status
	var sprite = find_child("Sprite2D")
	if sprite:
		sprite.visible = true
