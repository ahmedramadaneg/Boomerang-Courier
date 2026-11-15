class_name Spring
extends Area2D
## Spring pad. Origin is the bottom-left, 60 px wide. Launches the courier upward.

@export var power: float = 900.0

var _squash: float = 0.0


func _ready() -> void:
    collision_layer = 0
    collision_mask = 2
    var shape_node := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(60.0, 14.0)
    shape_node.shape = rect
    shape_node.position = Vector2(30.0, -7.0)
    add_child(shape_node)
    body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
    if _squash > 0.0:
        _squash = maxf(_squash - delta * 4.0, 0.0)
        queue_redraw()


func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        (body as Player).call_deferred("bounce", power)
        _squash = 1.0
        get_tree().call_group("fx", "burst", global_position + Vector2(30, -10), Palette.ACCENT, 10, 220.0)


func _draw() -> void:
    var pad_y: float = -14.0 + 6.0 * _squash
    draw_rect(Rect2(6, -4, 48, 4), Palette.ACCENT_BODY)
    var zig := PackedVector2Array([
        Vector2(12, -4), Vector2(48, pad_y * 0.66), Vector2(12, pad_y * 0.33 - 2.0), Vector2(48, pad_y + 5.0),
    ])
    draw_polyline(zig, Palette.TEXT, 3.0)
    draw_rect(Rect2(0, pad_y, 60, 5), Palette.ACCENT)
