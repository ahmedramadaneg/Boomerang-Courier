class_name Checkpoint
extends Area2D
## Flag. Origin is its base. Touch it once and you respawn here after a fall or spikes.

signal activated

var active: bool = false
var _time: float = 0.0


func _ready() -> void:
    collision_layer = 0
    collision_mask = 2
    var shape_node := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(50.0, 70.0)
    shape_node.shape = rect
    shape_node.position = Vector2(0.0, -35.0)
    add_child(shape_node)
    body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
    _time += delta
    queue_redraw()


func _on_body_entered(body: Node2D) -> void:
    if body is Player and not active:
        active = true
        (body as Player).checkpoint = global_position + Vector2(0, -22)
        get_tree().call_group("fx", "burst", global_position + Vector2(0, -50), Palette.GOAL_FLAG, 18, 240.0)
        activated.emit()


func _draw() -> void:
    var flag_col: Color = Palette.GOAL_FLAG if active else Palette.PLATFORM_LINE.lightened(0.35)
    draw_rect(Rect2(-2, -64, 4, 64), Palette.GOAL_POST)
    var wave: float = sin(_time * 4.0) * 3.0 if active else 0.0
    draw_colored_polygon(
        PackedVector2Array([Vector2(2, -64), Vector2(34, -54.0 + wave), Vector2(2, -42)]),
        flag_col)
