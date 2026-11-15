class_name Hazard
extends Area2D
## Spike strip. Origin is the bottom-left; spikes point up. Touching it sends you to the checkpoint.

@export var width: float = 100.0


func _ready() -> void:
    collision_layer = 0
    collision_mask = 2
    var shape_node := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(width, 18.0)
    shape_node.shape = rect
    shape_node.position = Vector2(width * 0.5, -9.0)
    add_child(shape_node)
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        (body as Player).call_deferred("hurt")


func _draw() -> void:
    var count: int = int(width / 20.0)
    for i in range(count):
        var x0: float = float(i) * 20.0
        draw_colored_polygon(
            PackedVector2Array([Vector2(x0, 0), Vector2(x0 + 10.0, -26.0), Vector2(x0 + 20.0, 0)]),
            Palette.SPIKE)
