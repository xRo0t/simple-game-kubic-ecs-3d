# Simple Game - Kobic ECS 3D Playground

A fast 3D sandbox built with the Kobic Engine and the Dolet programming language.
The scene is no longer just a cube demo: it now has a living world with player
movement, social goblins, simple ambient critters, and thousands of entities
running through data-oriented update loops.

## What Is Inside

- A first-person player controller with WASD movement and mouse look.
- 3000 goblins spread across the world with group behavior.
- Goblin groups can form, split, follow a leader, and flee from the player.
- 500 neutral critters with simple random wandering for ambient life.
- World-side spawning with mob-specific spawn/setup logic kept inside each mob.
- Clear tuning values for speed, flee radius, group distance, and roam distance.
- A modular layout that keeps `player`, `goblin`, `critter`, and `world` logic separated.

## Why This Project Matters

This project is a practical stress test and gameplay prototype for Kobic-style ECS
workflows. It focuses on the parts that matter for real games:

- Many entities updating every frame.
- Simple AI that still looks alive.
- Clean ownership between world spawning and mob behavior.
- Low-overhead arrays for hot mob state.
- A code layout that can grow into real gameplay systems.

## Current World

The world spawns a large ground plane, then fills it with two kinds of mobs:

- `Goblin`: taller hostile mobs with flee behavior and social group logic.
- `Critter`: small cube-like neutral mobs that wander randomly without advanced AI.

The goblins use a leader/follower group model. A group stores its leader once per
frame, followers read that cached leader position, and fallback behavior uses the
group center if needed. This keeps the behavior smarter without adding expensive
per-follower searches.

## Controls

- `W`, `A`, `S`, `D`: move.
- Mouse: look around when captured.
- `M`: capture mouse.
- `Escape`: release mouse.
- Arrow keys: fallback camera yaw when mouse is not captured.

## Project Structure

- `src/main.dlt`: application setup and main loop.
- `src/world/earth.dlt`: world creation and spawn placement.
- `src/mobs/player/`: player state and controller.
- `src/mobs/goblin/`: goblin state, spawn/setup, cleanup, and AI controller.
- `src/mobs/critter/`: simple ambient mob state, spawn/setup, cleanup, and controller.
- `assets/`: future asset location.
- `bin/`: local build output.

## Build And Run

Use the included build script:

```bat
build.bat
```

Or compile directly:

```bat
doletc src/main.dlt -o bin/main.exe
```

## Direction

The goal is to keep pushing this from a small demo into a serious ECS game
playground: richer mobs, better world rules, cleaner engine-facing APIs, and
gameplay systems that stay fast even when the entity count climbs.
