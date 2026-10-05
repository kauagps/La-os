# Laços

Um jogo de ação-aventura e dedução com mecânicas de combate pacifico, desenvolvido em Godot 4.7.

## Visão Geral

"Laços" é um jogo onde o jogador assume o papel do "Guardião dos Laços" que deve explorar um mapa místico, enfraquecer inimigos em combates não-letais e devolver objetos perdidos aos habitantes para restaurar sentimentos de pertencimento e transformar o ambiente de tristeza para esperança.

## Tecnologias

- **Engine**: Godot 4.7 (stable)
- **Renderizador**: Forward Plus
- **Física 2D**: Jolt Physics (configurado em project.godot)
- **Plataforma**: PC (Exportável para WebGL ou executável)

## Estrutura do Projeto

```
laços/
├── project.godot          ← Configuração do projeto
├── scenes/                ← Cenas do jogo
│   ├── player.tscn        ← Cena principal do jogador
│   ├── dialogue_box.tscn  ← Sistema de diálogo
│   └── npc_interactable.tscn ← Exemplo de NPC interativo
├── scripts/               ← Scripts GDScript
│   ├── player.gd          ← Movimento, colisão, interação
│   ├── dialogue_box.gd    ← Efeito typewriter para diálogos
│   └── npc_interactable.gd← Lógica de interação com NPCs
├── .godot/                ← Cache da editora (ignorado pelo git)
├── .import/               ← Arquivos de importação de assets (tracked)
├── .gitignore             ← Configurações de ignorar arquivos
├── .gitattributes         ← Configurações de linha e encoding
└── .editorconfig          ← Configurações de editor
```

## Como Executar

1. **Pré-requisitos**: Godot 4.7+ instalado
2. Abrir o projeto no Godot Editor:
   - Clique em "Import" no launcher do Godot
   - Selecione a pasta `laços/`
   - Confirme o projeto
3. Executar:
   - Pressione `F5` no editor para testar
   - Ou clique no botão "Play" na interface

## Controles

- **Movimento**: WASD ou Setas do teclado
- **Interação**: Tecla `E` (para conversar com NPCs, pegar itens, etc.)
- **Diálogo**: 
  - `E` para avançar texto
  - Pressione `E` durante o efeito typewriter para pular para o texto completo

## Notas de Desenvolvimento

- **Fase 1 Implementada**: Movimento básico, colisão e sistema de diálogo estão funcionais
- **Assets Placeholder**: Sprites precisam ser substituídos pelos arts finais
- **Grupo System**: 
  - Jogadores: grupo "Player"
  - Objetos interativos: grupo "Interactable"
  - Diálogos: grupo "DialogueBox"
- **Sinais**: 
  - `interact_requested` → disparado quando jogador pressiona E próximo de um interativo
  - `dialogue_finished` → disparado quando diálogo termina
  - `item_delivered` → disparado quando jogador entrega um item

## Licença

Este projeto está em desenvolvimento para fins educacionais/jam de jogos.