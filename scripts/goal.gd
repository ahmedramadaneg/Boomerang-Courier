class_name Goal
extends Area2D
## The mailbox. Origin is at its feet.

signal reached

var _time: float = 0.0


func _ready() -> void:
    body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
    _time += delta
    queue_redraw()


func _on_body_entered(body: Node2D) -> void:
    if body is Player:
        reached.emit()


func _draw() -> void:
    var pulse: float = 0.5 + 0.5 * sin(_time * 3.0)
    var glow := Color(Palette.GOAL_GLOW.r, Palette.GOAL_GLOW.g, Palette.GOAL_GLOW.b, 0.18)
    draw_circle(Vector2(0, -55), 52.0 + pulse * 8.0, glow)
    draw_rect(Rect2(-4, -60, 8, 60), Palette.GOAL_POST)            # post
    draw_rect(Rect2(-26, -100, 52, 40), Palette.GOAL_BOX)          # box
    draw_rect(Rect2(-18, -88, 36, 6), Palette.SKY_TOP)             # slot
    draw_rect(Rect2(26, -100, 4, 30), Palette.GOAL_POST)           # flag pole
    draw_rect(Rect2(30, -100, 20.0 + pulse * 4.0, 12), Palette.GOAL_FLAG)
