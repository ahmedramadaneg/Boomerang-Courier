extends Node2D
## Parallax sunset sky: gradient, stars, moon and two mountain ridges.

var _stars: Array[Vector3] = []
var _time: float = 0.0


func _ready() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 12345
    for i in 90:
        _stars.append(Vector3(rng.randf_range(0.0, 1280.0), rng.randf_range(0.0, 430.0), rng.randf_range(1.0, 2.6)))


func _process(delta: float) -> void:
    _time += delta
    queue_redraw()


func _draw() -> void:
    var size: Vector2 = get_viewport_rect().size
    var cam_pos := Vector2.ZERO
    var cam: Camera2D = get_viewport().get_camera_2d()
    if cam != null:
        cam_pos = cam.get_screen_center_position()

    var split: float = size.y * 0.55
    draw_polygon(
        PackedVector2Array([Vector2(0, 0), Vector2(size.x, 0), Vector2(size.x, split), Vector2(0, split)]),
        PackedColorArray([Palette.SKY_TOP, Palette.SKY_TOP, Palette.SKY_MID, Palette.SKY_MID]))
    draw_polygon(
        PackedVector2Array([Vector2(0, split), Vector2(size.x, split), Vector2(size.x, size.y), Vector2(0, size.y)]),
        PackedColorArray([Palette.SKY_MID, Palette.SKY_MID, Palette.SKY_BOTTOM, Palette.SKY_BOTTOM]))

    for s in _stars:
        var a: float = 0.35 + 0.65 * (0.5 + 0.5 * sin(_time * 2.0 + s.x))
        draw_circle(Vector2(s.x, s.y), s.z, Color(1, 1, 1, a))

    draw_circle(Vector2(1020.0 - cam_pos.x * 0.02, 130.0), 46.0, Palette.MOON)
    draw_circle(Vector2(1038.0 - cam_pos.x * 0.02, 120.0), 40.0, Palette.SKY_TOP.lerp(Palette.SKY_MID, 0.5))

    _ridge(size, cam_pos.x, 0.08, size.y - 230.0, 200.0, 170.0, Palette.MOUNTAIN_FAR)
    _ridge(size, cam_pos.x, 0.20, size.y - 130.0, 170.0, 140.0, Palette.MOUNTAIN_NEAR)


func _ridge(size: Vector2, cam_x: float, factor: float, base_y: float, height: float, step: float, color: Color) -> void:
    var heights: Array[float] = [1.0, 0.45, 0.8]
    var shift: float = fposmod(cam_x * factor, step * 3.0)
    var pts := PackedVector2Array()
    var count: int = int(size.x / step) + 5
    var first_x: float = -step * 3.0 - shift
    pts.append(Vector2(first_x, size.y))
    for i in range(count):
        var x: float = first_x + float(i) * step
        var h: float = heights[posmod(i, 3)] * height
        pts.append(Vector2(x, base_y + height - h))
    var last_x: float = first_x + float(count - 1) * step
    pts.append(Vector2(last_x, size.y))
    draw_colored_polygon(pts, color)
