@tool
class_name Platform
extends StaticBody2D
## A solid chunk of rooftop. Its position is the upper-left corner.

@export var platform_size: Vector2 = Vector2(200, 40):
    set(value):
        platform_size = value
        _rebuild()
@export var accent: bool = false

var _shape_node: CollisionShape2D


func _ready() -> void:
    _rebuild()


func _rebuild() -> void:
    if not is_inside_tree():
        return
    if _shape_node == null:
        _shape_node = CollisionShape2D.new()
        _shape_node.shape = RectangleShape2D.new()
        add_child(_shape_node)
    (_shape_node.shape as RectangleShape2D).size = platform_size
    _shape_node.position = platform_size * 0.5
    queue_redraw()


func _draw() -> void:
    var body := Palette.ACCENT_BODY if accent else Palette.PLATFORM_BODY
    var top := Palette.ACCENT if accent else Palette.PLATFORM_TOP
    draw_rect(Rect2(Vector2.ZERO, platform_size), body)
    draw_rect(Rect2(0, 0, platform_size.x, 9), top)
    draw_line(Vector2(0, 10), Vector2(platform_size.x, 10), body.lightened(0.22), 2.0)

    # Subtle joints and fasteners make the rooftops feel built, not tiled.
    var x := 28.0
    while x < platform_size.x - 12.0:
        draw_line(Vector2(x, 18), Vector2(x, platform_size.y - 8), Palette.PLATFORM_LINE, 1.0)
        draw_circle(Vector2(x + 5, 23), 2.0, top.darkened(0.18))
        x += 56.0
