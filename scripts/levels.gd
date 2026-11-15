class_name Levels
extends RefCounted
## Level data (generated and checked with a physics simulation, every level is beatable).
## platforms: [x, y, w, h]   spikes: [x, y_top, w]   springs: [x, y_top]   checkpoints: [x, y_top]
## par = throws needed for a gold medal.

static func get_levels() -> Array:
    return [
        {
            "name": "1. Rooftop Hop",
            "par": 7,
            "start": Vector2(140, 578),
            "goal": Vector2(2300, 560),
            "platforms": [
                [0, 600, 420, 300],
                [640, 520, 220, 380],
                [900, 330, 160, 28],
                [1080, 600, 260, 300],
                [1440, 340, 36, 300],
                [1560, 560, 240, 340],
                [2000, 560, 500, 340],
            ],
            "spikes": [],
            "springs": [],
            "checkpoints": [],
            "stars": [Vector2(530, 440), Vector2(980, 270), Vector2(1210, 500), Vector2(1700, 440)],
        },
        {
            "name": "2. Spike Valley",
            "par": 7,
            "start": Vector2(140, 578),
            "goal": Vector2(2650, 440),
            "platforms": [
                [0, 600, 380, 300],
                [560, 560, 760, 340],
                [1500, 480, 260, 420],
                [1900, 560, 300, 340],
                [2350, 440, 500, 460],
            ],
            "spikes": [
                [820, 560, 120],
                [1060, 560, 120],
            ],
            "springs": [],
            "checkpoints": [
                [1540, 480],
            ],
            "stars": [Vector2(470, 470), Vector2(880, 440), Vector2(1120, 440), Vector2(1620, 390), Vector2(2050, 450)],
        },
        {
            "name": "3. Cloud Climb",
            "par": 7,
            "start": Vector2(140, 618),
            "goal": Vector2(2450, 470),
            "platforms": [
                [0, 640, 360, 300],
                [520, 560, 200, 40],
                [820, 470, 200, 40],
                [1120, 380, 200, 40],
                [1420, 290, 200, 40],
                [1720, 380, 200, 40],
                [2020, 470, 520, 300],
            ],
            "spikes": [
                [2250, 470, 100],
            ],
            "springs": [],
            "checkpoints": [
                [1500, 290],
            ],
            "stars": [Vector2(440, 480), Vector2(720, 390), Vector2(1020, 300), Vector2(1320, 200), Vector2(1820, 290), Vector2(2150, 370)],
        },
        {
            "name": "4. Spring Festival",
            "par": 6,
            "start": Vector2(140, 578),
            "goal": Vector2(2650, 300),
            "platforms": [
                [0, 600, 380, 300],
                [560, 600, 260, 300],
                [950, 260, 200, 40],
                [1300, 420, 260, 300],
                [1700, 300, 200, 40],
                [2000, 600, 280, 300],
                [2450, 300, 450, 600],
            ],
            "spikes": [
                [1380, 420, 100],
            ],
            "springs": [
                [650, 600],
                [2090, 600],
            ],
            "checkpoints": [
                [1480, 420],
            ],
            "stars": [Vector2(700, 300), Vector2(1050, 150), Vector2(1430, 330), Vector2(1800, 200), Vector2(2150, 420)],
        },
        {
            "name": "5. The Gauntlet",
            "par": 9,
            "start": Vector2(140, 618),
            "goal": Vector2(2950, 560),
            "platforms": [
                [0, 640, 360, 300],
                [520, 600, 160, 40],
                [760, 400, 36, 260],
                [880, 560, 220, 340],
                [1280, 480, 160, 40],
                [1580, 380, 160, 40],
                [1880, 560, 260, 340],
                [2300, 460, 160, 40],
                [2600, 560, 500, 340],
            ],
            "spikes": [
                [930, 560, 100],
                [1940, 560, 90],
            ],
            "springs": [],
            "checkpoints": [
                [1300, 480],
            ],
            "stars": [Vector2(600, 500), Vector2(1000, 420), Vector2(1360, 380), Vector2(1660, 280), Vector2(2380, 360)],
        },
    ]


static func medal_name(throws: int, par: int) -> String:
    if throws <= par:
        return "GOLD MEDAL"
    if throws <= par + 4:
        return "SILVER MEDAL"
    return "BRONZE MEDAL"
