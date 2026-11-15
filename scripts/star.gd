class_name Star
extends Area2D
## Collectible star. Touch it with the courier OR with the flying boomerang.

signal collected

var _time: float = 0.0
var _taken: bool = false


func _ready() -> void:
    collision_layer = 0
    collision_mask = 6  # player (2) + boomerang (4)
    var shape_node := CollisionShape2D.new()
    var circle := CircleShape2D.new()
    circle.radius = 22.0
    shape_node.shape = circle
    add_child(shape_node)
    body_entered.connect(_on_hit)
    area_entered.connect(_on_hit)
    _time = randf() * TAU


func _process(delta: float) -> void:
    _time += delta
    queue_redraw()


func _on_hit(_other: Node) -> void:
    if _taken:
        return
    _taken = true
    collected.emit()
    get_tree().call_group("fx", "burst", global_position, Palette.STAR, 16, 280.0)
    queue_free()


func _draw() -> void:
    var bob: float = sin(_time * 3.0) * 4.0
    var pts := PackedVector2Array()
    for i in range(10):
        var ang: float = -PI / 2.0 + float(i) * PI / 5.0
        var r: float = 16.0 if i % 2 == 0 else 7.0
        pts.append(Vector2(cos(ang), sin(ang)) * r + Vector2(0, bob))
    draw_colored_polygon(pts, Palette.STAR)
