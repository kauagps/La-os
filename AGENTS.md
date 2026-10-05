# AGENTS.md

Godot 4.7 project "Laços" (Portuguese: "Laços" = "bonds/ties"). Action-adventure/deduction game with pacifist combat mechanics. Short deadline — others handle art/audio/narrative.

## Core Loop (Phases)
1. **Foundation**: Movement + collision + dialogue box.
2. **Core Loop**: Pacifist combat ("purificação") + simple inventory (3 items).
3. **Level**: One scenario; visual shift from dark (sad) to colorful (welcoming) after item delivery.
4. **Polish**: SFX, BGM shift, menu buttons.
5. **Build**: Freeze code; export WebGL or executable; test; upload.

## Programming Requirements (REQ-F)
- **Movement**: WASD/Arrow keys + collision with walls/obstacles.
- **Interaction**: Press 'E' to interact with signs, ground items, NPCs in range.
- **Combat (Non-lethal)**: Light projectile/AoE attack reduces enemy "darkness" (no death); sets enemy to Stunned/Accessible state.
- **Enemy AI**: Basic chase when player enters field of view.
- **Inventory**: Simple UI holding 3 items; select to "deliver" to stunned enemy.
- **Dialogues**: Bottom textbox, typewriter effect (letter-by-letter), shows speaker portrait.
- **Base Evolution**: Conditional visual change (show hidden objects/lights) when rescued NPC flag = true.

## Technical Notes
- Engine: Godot 4.7, Forward Plus renderer, d3d12 on Windows.
- Stretch mode: `canvas_items` / `expand` (fixed canvas scaling).
- 3D physics: Jolt (if used) — but core loop is 2D/top-down.
- `.godot/` is generated cache (gitignored; never edit).
- `*.import` files next to assets are tracked in git.
- LF line endings, UTF-8.
- No build/test/lint tooling; verify in Godot editor.
- Headless CLI (if available): `godot --headless --path . --quit`.

## Implementation Status
- ✅ **Phase 1 (Foundation)**: Player movement, collision, interaction, and dialogue box implemented
- ✅ **Scene structure**: `Player.tscn`, `DialogueBox.tscn`, `NPCInteractable.tscn` created
- ✅ **Scripts**: `player.gd`, `dialogue_box.gd`, `npc_interactable.gd` ready for implementation
- ✅ **Group system**: Players in "Player" group, interactables in "Interactable" group
- ✅ **Dialogue system**: Typewriter effect, portrait support, signals

## Next Steps (for developer)
1. Test movement and collision in Godot editor
2. Create placeholder sprites for player and NPC
3. Test interaction with the NPC example
4. Add dialogue content to the dialogue box
5. Implement enemy AI and combat system
6. Create inventory system with 3 items
7. Implement base transformation logic

## File Structure
```
laços/
├── scenes/
│   ├── player.tscn
│   ├── dialogue_box.tscn
│   └── npc_interactable.tscn
├── scripts/
│   ├── player.gd
│   ├── dialogue_box.gd
│   └── npc_interactable.gd
└── project.godot (existing)
```

## Commands
- Open project in Godot editor → select `laços/` as project folder
- Run game: Press F5 in editor or use Godot's Run button
- Headless mode (if CLI installed): `godot --headless --path . --quit`