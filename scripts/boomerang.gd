class_name Boomerang
extends Area2D
## The magical boomerang package.
## IDLE (held) -> THROWING (flies to the cursor / a wall) -> RETURNING (curved path back).
## When it reaches the courier it emits `returned` with a recoil impulse.

signal returned(impulse: Vector2)
signal bounced(pos: Vector2)

enum State { IDLE, THROWING, RETURNING }

@export var throw_speed: float = 950.0
@export var return_speed: float = 900.0
@export var max_range: float = 520.0
@export var min_range: float = 80.0
## How strongly the return path bends (fraction of the distance).
@export var curve_ratio: float = 0.55
@export var recoil_strength: float = 820.0
## true  = the package drags you toward where you threw it (default, feels like a grapple)
## false = impulse follows the return travel direction literally (pushes you away)
@export var pull_toward_throw: bool = true
@export var catch_radius: float = 24.0

var state: State = State.IDLE

var _dir: Vector2 = Vector2.RIGHT
var _origin: Vector2 = Vector2.ZERO
var _range: float = 0.0
var _p0: Vector2 = Vector2.ZERO
var _t: float = 0.0
var _curve_sign: float = -1.0
var _last_dir: Vector2 = Vector2.LEFT
var _spin: float = 0.0
var _trail: Array[Vector2] = []
var _player: Node2D


func _ready() -> void:
    top_level = true
    z_index = 5
    visible = false
    _player = get_parent() as Node2D
    body_entered.connect(_on_body_entered)


func is_idle() -> bool:
    return state == State.IDLE


func throw(from: Vector2, target: Vector2) -> void:
    var to_target: Vector2 = target - from
    _dir = to_target.normalized() if to_target.length() > 1.0 else Vector2.RIGHT
    _range = clampf(to_target.length(), min_range, max_range)
    _origin = from
    global_position = from
    _curve_sign = -1.0 if _dir.x >= 0.0 else 1.0  # always arcs upward
    _trail.clear()
    state = State.THROWING
    visible = true
    set_deferred("monitoring", true)
    set_deferred("monitorable", true)


func recall() -> void:
    if state == State.THROWING:
        _start_return()


func reset() -> void:
    state = State.IDLE
    visible = false
    set_deferred("monitoring", false)
    set_deferred("monitorable", false)


## Predicts the recoil impulse for a throw (ignores walls). Used for the aim arrow.
func preview_impulse(from: Vector2, target: Vector2) -> Vector2:
    var to_target: Vector2 = target - from
    var d: Vector2 = to_target.normalized() if to_target.length() > 1.0 else Vector2.RIGHT
    var r: float = clampf(to_target.length(), min_range, max_range)
    var side_sign: float = -1.0 if d.x >= 0.0 else 1.0
    var p0: Vector2 = from + d * r
    var perp: Vector2 = (from - p0).orthogonal().normalized()
    var p1: Vector2 = (p0 + from) * 0.5 + perp * side_sign * r * curve_ratio
    var tangent: Vector2 = (from - p1).normalized()
    var dir: Vector2 = -tangent if pull_toward_throw else tangent
    var power: float = inverse_lerp(min_range, max_range, r)
    return dir * recoil_strength * lerpf(0.45, 1.0, power)


func _physics_process(delta: float) -> void:
    match state:
        State.THROWING:
            global_position += _dir * throw_speed * delta
            _spin += 20.0 * delta
            if global_position.distance_to(_origin) >= _range:
                _start_return()
        State.RETURNING:
            _spin += 20.0 * delta
            var p2: Vector2 = _player_center()
            var chord: float = maxf(_p0.distance_to(p2), 1.0)
            _t = minf(_t + return_speed * delta / chord, 1.0)
            var perp: Vector2 = (p2 - _p0).orthogonal().normalized()
            var p1: Vector2 = (_p0 + p2) * 0.5 + perp * _curve_sign * chord * curve_ratio
            var prev: Vector2 = global_position
            # Quadratic Bezier toward the courier's current position.
            global_position = _p0.lerp(p1, _t).lerp(p1.lerp(p2, _t), _t)
            var step: Vector2 = global_position - prev
            if step.length() > 0.01:
                _last_dir = step.normalized()
            if global_position.distance_to(p2) <= catch_radius or _t >= 1.0:
                _catch()
        _:
            pass

    if state != State.IDLE:
        _trail.push_front(global_position)
        if _trail.size() > 14:
            _trail.pop_back()
    queue_redraw()


func _start_return() -> void:
    state = State.RETURNING
    _p0 = global_position
    _t = 0.0
    set_deferred("monitoring", false)


func _catch() -> void:
    var power: float = inverse_lerp(min_range, max_range, _range)
    var strength: float = recoil_strength * lerpf(0.45, 1.0, power)
    var dir: Vector2 = -_last_dir if pull_toward_throw else _last_dir
    state = State.IDLE
    visible = false
    set_deferred("monitoring", false)
    set_deferred("monitorable", false)
    returned.emit(dir * strength)


func _player_center() -> Vector2:
    return _player.global_position + Vector2(0, -6)


func _on_body_entered(_body: Node2D) -> void:
    if state == State.THROWING:
        get_tree().call_group("fx", "burst", global_position, Palette.BOOM, 10, 220.0)
        bounced.emit(global_position)
        _start_return()  # bounced off a wall


func _draw() -> void:
    for i in range(_trail.size() - 1):
        var a: Vector2 = to_local(_trail[i])
        var b: Vector2 = to_local(_trail[i + 1])
        var col := Color(Palette.BOOM_TRAIL.r, Palette.BOOM_TRAIL.g, Palette.BOOM_TRAIL.b, 1.0 - float(i) / float(_trail.size()))
        draw_line(a, b, col, 4.0)
    draw_set_transform(Vector2.ZERO, _spin, Vector2.ONE)
    # Folded-paper parcel with a ribbon crossing the middle.
    draw_colored_polygon(PackedVector2Array([
        Vector2(-18, -14), Vector2(10, -18), Vector2(20, 8),
        Vector2(-8, 18), Vector2(-20, 2)
    ]), Palette.BOOM_PARCEL)
    draw_line(Vector2(-18, -5), Vector2(16, -2), Palette.BOOM, 4.0)
    draw_line(Vector2(-2, -16), Vector2(2, 15), Palette.BOOM, 4.0)
    draw_line(Vector2(-18, -14), Vector2(10, -18), Palette.TEXT, 2.0)