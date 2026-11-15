class_name Player
extends CharacterBody2D
## The Courier. He cannot walk or jump: only the returning boomerang moves him.
## Mouse: LEFT click = throw, RIGHT click = recall the package early.

signal threw
signal died

@export var gravity: float = 1100.0
@export var ground_friction: float = 900.0
@export var air_drag: float = 40.0
@export var max_speed: float = 1500.0
@export var kill_y: float = 1100.0
## How much speed you keep when the package hits you: on the ground / in the air.
## Keeping more in the air lets you chain throws into long flights.
@export var keep_ground: float = 0.3
@export var keep_air: float = 0.55

var input_enabled: bool = true
var checkpoint: Vector2 = Vector2.ZERO

var _floor_time: float = 0.0
var _shake: float = 0.0
var _look: Vector2 = Vector2.ZERO
var _dust_timer: float = 0.0
var _face: float = 1.0

@onready var boomerang: Boomerang = $Boomerang
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
    checkpoint = global_position
    boomerang.returned.connect(_on_boomerang_returned)
    boomerang.bounced.connect(_on_boomerang_bounced)


func _unhandled_input(event: InputEvent) -> void:
    if not input_enabled:
        return
    var mb := event as InputEventMouseButton
    if mb == null or not mb.pressed:
        return
    if mb.button_index == MOUSE_BUTTON_LEFT:
        if boomerang.is_idle():
            var aim_target: Vector2 = get_global_mouse_position()
            if absf(aim_target.x - global_position.x) > 1.0:
                _face = signf(aim_target.x - global_position.x)
            boomerang.throw(global_position + Vector2(0, -6), aim_target)
            threw.emit()
    elif mb.button_index == MOUSE_BUTTON_RIGHT:
        boomerang.recall()


func _physics_process(delta: float) -> void:
    velocity.y += gravity * delta
    var drag: float = ground_friction if is_on_floor() else air_drag
    velocity.x = move_toward(velocity.x, 0.0, drag * delta)
    velocity = velocity.limit_length(max_speed)
    move_and_slide()

    if absf(velocity.x) > 20.0:
        _face = signf(velocity.x)

    if is_on_floor():
        _floor_time += delta
        if _floor_time > 0.5 and absf(velocity.x) < 30.0:
            checkpoint = global_position
    else:
        _floor_time = 0.0

    _dust_timer -= delta
    if velocity.length() > 350.0 and _dust_timer <= 0.0:
        _dust_timer = 0.04
        get_tree().call_group("fx", "burst", global_position + Vector2(0, 10), Palette.BOOM_TRAIL, 2, 60.0)

    if global_position.y > kill_y:
        respawn()


func _process(delta: float) -> void:
    # Camera looks a little toward the mouse so you can see where you're aiming.
    var look_target := Vector2.ZERO
    if input_enabled:
        var from_center: Vector2 = get_viewport().get_mouse_position() - get_viewport_rect().size * 0.5
        look_target = (from_center * 0.15).limit_length(110.0)
    _look = _look.lerp(look_target, clampf(6.0 * delta, 0.0, 1.0))

    var shake_offset := Vector2.ZERO
    if _shake > 0.1:
        shake_offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake
        _shake = maxf(_shake - 60.0 * delta, 0.0)
    camera.offset = _look + shake_offset
    queue_redraw()


func shake(amount: float) -> void:
    _shake = maxf(_shake, amount)


func teleport(pos: Vector2) -> void:
    global_position = pos
    checkpoint = pos
    velocity = Vector2.ZERO
    boomerang.reset()
    camera.reset_smoothing()


func bounce(power: float) -> void:
    velocity.y = -power
    shake(4.0)


func hurt() -> void:
    get_tree().call_group("fx", "burst", global_position, Palette.SPIKE, 22, 320.0)
    shake(10.0)
    respawn()


func respawn() -> void:
    global_position = checkpoint
    velocity = Vector2.ZERO
    _floor_time = 0.0
    boomerang.reset()
    camera.reset_smoothing()
    get_tree().call_group("fx", "burst", global_position, Palette.PLAYER_BODY, 14, 200.0)
    died.emit()


func _predict_velocity(impulse: Vector2) -> Vector2:
    var keep: float = keep_ground if is_on_floor() else keep_air
    var v: Vector2 = velocity * keep + impulse
    if is_on_floor() and impulse.y > -200.0:
        v.y -= 160.0  # small hop so he lifts off the ground
    return v


func _on_boomerang_returned(impulse: Vector2) -> void:
    # The returning package yanks the courier along its recoil vector.
    velocity = _predict_velocity(impulse)
    shake(minf(impulse.length() / 120.0, 8.0))
    get_tree().call_group("fx", "burst", global_position, Palette.BOOM, 16, 300.0)


func _on_boomerang_bounced(_pos: Vector2) -> void:
    shake(3.0)


func _draw() -> void:
    # A little parcel runner, drawn from simple shapes so the art stays crisp.
    draw_circle(Vector2(0, 2), 19.0, Color(0.08, 0.12, 0.14, 0.18))
    draw_rect(Rect2(-12, -20, 24, 34), Palette.PLAYER_BODY)
    draw_rect(Rect2(-14, -25, 28, 9), Palette.PLAYER_CAP)
    draw_rect(Rect2(-10, -30, 20, 7), Palette.PLAYER_CAP)
    draw_rect(Rect2(-8 + 3 * _face, -15, 4, 5), Palette.TEXT)
    draw_rect(Rect2(2 + 3 * _face, -15, 4, 5), Palette.TEXT)
    draw_line(Vector2(-4, -5), Vector2(4, -5), Palette.PLAYER_BELT, 2.0)
    draw_rect(Rect2(-15 if _face > 0.0 else 5, -2, 10, 14), Palette.PLAYER_SATCHEL)
    draw_line(Vector2(-12, 14), Vector2(-8, 20), Palette.PLAYER_BELT, 4.0)
    draw_line(Vector2(8, 14), Vector2(12, 20), Palette.PLAYER_BELT, 4.0)
    draw_line(Vector2(-10, 20), Vector2(-3, 20), Palette.PLAYER_BELT, 3.0)
    draw_line(Vector2(9, 20), Vector2(16, 20), Palette.PLAYER_BELT, 3.0)

    if boomerang.is_idle() and input_enabled:
        _draw_aim()

func _draw_aim() -> void:
    var origin := Vector2(0, -6)
    var to_mouse: Vector2 = get_local_mouse_position() - origin
    var dist: float = clampf(to_mouse.length(), boomerang.min_range, boomerang.max_range)
    var dir: Vector2 = to_mouse.normalized()
    var steps: int = int(dist / 24.0)
    for i in range(1, steps + 1):
        draw_circle(origin + dir * 24.0 * float(i), 3.0, Color(Palette.AIM.r, Palette.AIM.g, Palette.AIM.b, 0.6))
    draw_arc(origin + dir * dist, 9.0, 0.0, TAU, 20, Palette.AIM_END, 2.0)

    # Preview: arrow = fling direction, dotted arc = predicted flight (ignores walls).
    var imp: Vector2 = boomerang.preview_impulse(global_position + origin, get_global_mouse_position())
    var fling_dir: Vector2 = imp.normalized()
    var arrow_len: float = clampf(imp.length() / 8.0, 30.0, 110.0)
    var tip: Vector2 = origin + fling_dir * arrow_len
    draw_line(origin, tip, Palette.ARROW, 3.0)
    var side: Vector2 = fling_dir.orthogonal() * 8.0
    draw_line(tip, tip - fling_dir * 14.0 + side, Palette.ARROW, 3.0)
    draw_line(tip, tip - fling_dir * 14.0 - side, Palette.ARROW, 3.0)

    var pos := Vector2.ZERO
    var vel: Vector2 = _predict_velocity(imp)
    var dt: float = 0.05
    for i in range(1, 23):
        vel.y += gravity * dt
        vel.x = move_toward(vel.x, 0.0, air_drag * dt)
        pos += vel * dt
        var fade: float = 1.0 - float(i) / 23.0
        draw_circle(pos, 2.5, Color(Palette.ARROW.r, Palette.ARROW.g, Palette.ARROW.b, fade * 0.8))
