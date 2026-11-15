class_name LevelSelect
extends CanvasLayer
## The little route board. Choose a stop to start delivering.

signal level_chosen(index: int)
signal closed

const SAVE_PATH := "user://scores.cfg"
var can_resume := false
var _buttons: Array[Button] = []


func _ready() -> void:
    layer = 20
    process_mode = Node.PROCESS_MODE_ALWAYS
    visible = false

    var root := Control.new()
    add_child(root)
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var wash := ColorRect.new()
    root.add_child(wash)
    wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    wash.color = Color(0.055, 0.10, 0.13, 0.88)

    var center := CenterContainer.new()
    root.add_child(center)
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 12)
    center.add_child(column)

    column.add_child(_make_label("THE LITTLE DELIVERY CO.", 22, Palette.STAR))
    column.add_child(_make_label("Boomerang Courier", 52, Palette.TEXT))
    column.add_child(_make_label("Pick a route. Make the delivery. Try not to drop the parcel.", 17, Palette.TEXT))

    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 14)
    column.add_child(row)

    var levels := Levels.get_levels()
    for i in range(levels.size()):
        var button := Button.new()
        button.custom_minimum_size = Vector2(205, 178)
        button.focus_mode = Control.FOCUS_ALL
        _style_button(button)
        button.pressed.connect(_choose.bind(i))
        row.add_child(button)
        _buttons.append(button)

    column.add_child(_make_label("CLICK A ROUTE  ·  1–5 TO JUMP IN  ·  ESC TO RESUME", 15, Palette.STAR))


func open() -> void:
    _refresh()
    visible = true
    get_tree().paused = true


func _refresh() -> void:
    var scores := ConfigFile.new()
    scores.load(SAVE_PATH)
    var levels := Levels.get_levels()
    for i in range(levels.size()):
        var data: Dictionary = levels[i]
        var section := "level%d" % i
        var score_line := "A fresh route"
        if scores.has_section_key(section, "throws"):
            var throws: int = scores.get_value(section, "throws", 0)
            var seconds: float = scores.get_value(section, "time", 0.0)
            score_line = "%s\n%d throws  ·  %.1fs" % [Levels.medal_name(throws, data["par"]), throws, seconds]
        _buttons[i].text = "%02d   %s\n\nTARGET: %d throws\n\n%s" % [i + 1, data["name"].get_slice(". ", 1), data["par"], score_line]


func _choose(index: int) -> void:
    visible = false
    get_tree().paused = false
    can_resume = true
    level_chosen.emit(index)


func _unhandled_input(event: InputEvent) -> void:
    if not visible:
        return
    var key := event as InputEventKey
    if key == null or not key.pressed or key.echo:
        return
    var number := int(key.keycode) - int(KEY_1)
    if number >= 0 and number < _buttons.size():
        _choose(number)
        get_viewport().set_input_as_handled()
    elif key.keycode == KEY_ESCAPE and can_resume:
        visible = false
        get_tree().paused = false
        closed.emit()
        get_viewport().set_input_as_handled()


func _make_label(copy: String, size: int, colour: Color) -> Label:
    var label := Label.new()
    label.text = copy
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", colour)
    label.add_theme_color_override("font_outline_color", Palette.TEXT_OUTLINE)
    label.add_theme_constant_override("outline_size", 3)
    return label


func _style_button(button: Button) -> void:
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color("#29434a")
    normal.border_color = Palette.PLATFORM_TOP
    normal.set_border_width_all(2)
    normal.set_corner_radius_all(10)
    normal.set_content_margin_all(14)
    var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
    hover.bg_color = Color("#3b6263")
    hover.border_color = Palette.ACCENT
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", hover)
    button.add_theme_color_override("font_color", Palette.TEXT)
    button.add_theme_color_override("font_hover_color", Palette.STAR)
    button.add_theme_font_size_override("font_size", 17)
