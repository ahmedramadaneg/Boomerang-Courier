# Boomerang Courier

A tiny rooftop-delivery platform game about a courier with a very unusual way of getting around.

You don't steer the courier directly. You throw the parcel, wait for it to loop back, and use the catch to launch yourself across the rooftops. The farther you send it, the bigger the pull. Aim carefully, grab the little stars if you can, and get the package to the mailbox.

## Playing

- **Left mouse button** — throw the parcel toward the cursor.
- **Right mouse button** — call the parcel back early.
- **Move the cursor farther away** — increase the throw's range and the return boost.
- **R** — restart the current route.
- **Esc / M** — open the route board.
- **1–5** — jump straight to a route.
- **Enter / Space / left click after a delivery** — continue.

The dotted guide shows the parcel's range. The arrow and flight dots give you a rough idea of the boost and the courier's next movement. The preview is an estimate; it doesn't account for walls or hazards.

## The routes

There are five hand-built routes, each with a different little challenge: rooftop gaps, spike strips, a climb through the clouds, spring-assisted jumps, and a final gauntlet. Checkpoints make the longer routes a little less punishing. Stars are optional, but they're there for a reason.

Your best time and lowest throw count are saved locally on your computer.

## Running the game

1. Open the project folder in **Godot 4.3 or newer**.
2. Let the editor import the project.
3. Open `scenes/main.tscn` if it isn't already selected.
4. Press **F6** to run the main scene, or **F5** to run the project.

No add-ons or external assets are needed. The character, rooftops, sky, parcel, and effects are drawn in GDScript, so the project stays lightweight and easy to tinker with.

## A note on the code

The project is intentionally split into small scripts: the courier handles movement, the boomerang handles its throw and return, and the level controller builds each route from the data in `levels.gd`. `palette.gd` is the one place to change the overall colour mood. Feel free to adjust the physics and art; experimenting is part of the fun.
