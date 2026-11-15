class_name Fx
extends Node2D
## Tiny particle system. Anyone can call: get_tree().call_group("fx", "burst", pos, color, count)

var _parts: Array = []


func _ready() -> void:
    add_to_group("fx")
    z_index = 20


func burst(pos: Vector2, color: Color, count: int = 12, speed: float = 260.0) -> void:
    for i in count:
        var ang: float = randf() * TAU
        var spd: float = randf_range(0.3, 1.0) * speed
        _parts.append({
            "pos": pos,
            "vel": Vector2(cos(ang), sin(ang)) * spd,
            "life": 0.0,
            "max": randf_range(0.3, 0.7),
            "color": color,
            "size": randf_range(2.0, 5.0),
        })


func _process(delta: float) -> void:
    var alive: Array = []
    for p in _parts:
        var life: float = p["life"]
        life += delta
        if life < float(p["max"]):
            var vel: Vector2 = p["vel"]
            var pos: Vector2 = p["pos"]
            vel = vel * 0.96 + Vector2(0.0, 300.0) * delta
            pos += vel * delta
            p["life"] = life
            p["vel"] = vel
            p["pos"] = pos
            alive.append(p)
    _parts = alive
    queue_redraw()


func _draw() -> void:
    for p in _parts:
        var a: float = 1.0 - float(p["life"]) / float(p["max"])
        var c: Color = p["color"]
        c.a = a
        var pos: Vector2 = p["pos"]
        draw_circle(pos, float(p["size"]) * a + 1.0, c)
