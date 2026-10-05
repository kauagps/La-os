# Main.gd - Nó raiz da cena principal (Fase 1 pronto para teste)

extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var dialogue_box: Control = get_tree().get_first_node_in_group("DialogueBox")

func _ready():
	# Adicionar DialogueBox ao grupo de diálogo para busca global
	dialogue_box.add_to_group("DialogueBox")
	
	# Conectar sinais do player ao diálogo
	player.interact_requested.connect(_on_player_request_dialogue)
	
	# Testar o sistema: mover player para uma posição segura
	player.position = Vector2(400, 300)
	
	print("Main scene initialized - ready for Phase 1 testing")

# --- Handler: quando jogador interage ---
func _on_player_request_dialogue():
	# Obter todos os NPCs ativos (grupo Interactable)
	var interactables = get_tree().get_nodes_in_group("Interactable")
	
	# Filtrar apenas aqueles não resgatados ainda (ou quaisquer, para teste)
	for npc in interactables:
		if npc.has_method("interact"):
			npc.interact(player)
			break  # apenas o primeiro NPC para teste
