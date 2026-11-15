extends Node2D
## Level controller: builds levels from Levels.gd, HUD, medals, best scores.
## The level-select menu (LevelSelect) opens at start and with Esc / M.
## Keys: R = restart level, 1-5 = jump to a level, Esc / M = level menu.
## After finishing a level: click / Enter / Space = next level.

const SAVE_PATH: String = "user://scores.cfg"

var level_index: int = 0
var time: float = 0.0
var throws: int = 0
var falls: int = 0
var stars_got: int = 0
var stars_total: int = 0
var par: int = 0
var finished: bool = false
var _level_name: String = ""

@onready var level_root: Node2D = $Level
@onready var player: Player = $Player
@onready var goal: Goal = $Goal
@onready var background: CanvasLayer = $Background
@onready var hud: CanvasLayer = $HUD
@onready var menu: LevelSelect = $LevelSelect
@onready var banner_label: Label = $HUD/BannerLabel


func _ready() -> void:
    background.process_mode = Node.PROCESS_MODE_ALWAYS  # sky keeps animating behind the menu
    _style_label(banner_label)
    player.threw.connect(_on_player_threw)
    player.died.connect(_on_player_died)
    goal.reached.connect(_on_goal_reached)
    menu.level_chosen.connect(_on_level_chosen)
    menu.closed.connect(_on_menu_closed)
    load_level(0)
    _open_menu()


func _process(delta: float) -> void:
    if not finished:
        time += delta


func _unhandled_input(event: InputEvent) -> void:
    var key := event as InputEventKey
    if key != null and key.pressed and not key.echo:
        var number: int = int(key.keycode) - int(KEY_1)
        if key.keycode == KEY_ESCAPE or key.keycode == KEY_M:
            _open_menu()
        elif key.keycode == KEY_R:
            load_level(level_index)
        elif number >= 0 and number < Levels.get_levels().size():
            load_level(number)
        elif finished and (key.keycode == KEY_ENTER or key.keycode == KEY_SPACE):
            _next_level()
        return
    var mb := event as InputEventMouseButton
    if mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT and finished:
        _next_level()


func _open_menu() -> void:
    hud.visible = false
    menu.open()


func _on_level_chosen(index: int) -> void:
    hud.visible = true
    load_level(index)


func _on_menu_closed() -> void:
    hud.visible = true


func load_level(index: int) -> void:
    level_index = index
    var data: Dictionary = Levels.get_levels()[index]
    _level_name = data["name"]
    par = data["par"]

    for child in level_root.get_children():
        level_root.remove_child(child)
        child.queue_free()

    for p in data["platforms"]:
        var rect: Array = p
        var plat := Platform.new()
        plat.position = Vector2(float(rect[0]), float(rect[1]))
        plat.platform_size = Vector2(float(rect[2]), float(rect[3]))
        plat.accent = minf(float(rect[2]), float(rect[3])) <= 40.0
        level_root.add_child(plat)

    for s in data["spikes"]:
        var sp: Array = s
        var hz := Hazard.new()
        hz.position = Vector2(float(sp[0]), float(sp[1]))
        hz.width = float(sp[2])
        level_root.add_child(hz)

    for s in data["springs"]:
        var spr_data: Array = s
        var spring := Spring.new()
        spring.position = Vector2(float(spr_data[0]), float(spr_data[1]))
        level_root.add_child(spring)

    for c in data["checkpoints"]:
        var cp_data: Array = c
        var flag := Checkpoint.new()
        flag.position = Vector2(float(cp_data[0]), float(cp_data[1]))
        level_root.add_child(flag)

    stars_total = 0
    for st in data["stars"]:
        var star_pos: Vector2 = st
        var star := Star.new()
        star.position = star_pos
        star.collected.connect(_on_star_collected)
        level_root.add_child(star)
        stars_total += 1

    goal.position = data["goal"]
    player.kill_y = 1100.0
    player.teleport(data["start"])

    time = 0.0
    throws = 0
    falls = 0
    stars_got = 0
    finished = false
    banner_label.visible = false
    player.set_deferred("input_enabled", true)


func _next_level() -> void:
    var next: int = level_index + 1
    if next >= Levels.get_levels().size():
        _open_menu()
    else:
        load_level(next)


func _on_player_threw() -> void:
    throws += 1


func _on_player_died() -> void:
    falls += 1


func _on_star_collected() -> void:
    stars_got += 1


func _on_goal_reached() -> void:
    if finished:
        return
    finished = true
    player.input_enabled = false
    var last: bool = level_index == Levels.get_levels().size() - 1
    var next_text: String = "Click to return to the level menu" if last else "Click for the next level"
    var best_text: String = _record_score()
    banner_label.text = "DELIVERY COMPLETE!\\n%s\\n\\nTime  %.1fs     Throws  %d / %d\\nStars  %d of %d     Retries  %d\\n%s\\n\\n%s   ·   R to try again" % [
        Levels.medal_name(throws, par), time, throws, par, stars_got, stars_total, falls, best_text, next_text]
    banner_label.visible = true
    get_tree().call_group("fx", "burst", goal.global_position + Vector2(0, -60), Palette.GOAL_GLOW, 40, 400.0)


func _record_score() -> String:
    var cfg := ConfigFile.new()
    cfg.load(SAVE_PATH)  # fine if the file doesn't exist yet
    var section: String = "level%d" % level_index
    var best_time: float = cfg.get_value(section, "time", 99999.0)
    var best_throws: int = cfg.get_value(section, "throws", 99999)
    var note: String = ""
    if time < best_time:
        best_time = time
        cfg.set_value(section, "time", time)
        note += "NEW BEST TIME!  "
    if throws < best_throws:
        best_throws = throws
        cfg.set_value(section, "throws", throws)
        note += "FEWEST THROWS!"
    cfg.save(SAVE_PATH)
    return "Best: %.1fs / %d throws   %s" % [best_time, best_throws, note]


func _style_label(label: Label) -> void:
    label.add_theme_color_override("font_color", Palette.TEXT)
    label.add_theme_color_override("font_outline_color", Palette.TEXT_OUTLINE)
    label.add_theme_constant_override("outline_size", 3)
    label.add_theme_font_size_override("font_size", 17)
