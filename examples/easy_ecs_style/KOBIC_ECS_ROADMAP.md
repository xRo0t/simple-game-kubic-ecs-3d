# Kobic ECS Better User-Facing Style

This document describes the desired Kobic ECS user experience.

It does not explain language implementation details.
It only documents the shape we want Kobic users to write in the future, why it is better, and which current low-level parts it should replace.

The current `examples/easy_ecs_style` folder is a design/reference example of the direction, not the final supported syntax.

## Goals

The new style should make gameplay code easier without changing the ECS idea.

Main goals:
- Keep ECS as the core model.
- Make user code typed and readable.
- Reduce repeated manual setup.
- Hide raw pointer and string-keyed component access from normal gameplay code.
- Keep hot update loops fast.
- Keep world, mob, and controller files organized like a real game project.

This is not about adding magic.
It is about giving the user a clean API over the same ECS concepts.

## Current Pain Points

The current style works, but it asks the user to do too much low-level work.

Examples:
- Components are registered manually with string names and byte sizes.
- Components are added by writing raw memory.
- Queries use strings such as `"Transform"` and `"MoveSpeed"`.
- Systems are called manually from the game loop.
- Rendering and transform sync are passed around by hand.
- Resources are accessed by string names.
- User code must know too much about internal storage details.

These are acceptable engine internals, but they are not ideal as the normal game API.

## Desired Component Style

Current style:

```dlt
world.register_component("MoveSpeed", 4)

ptr: i64 = world.add_component_zeroed(entity, "MoveSpeed")
if ptr != 0:
    Memory.write_f32(ptr, 5.0)
```

Desired style:

```dlt
@component
struct MoveSpeed:
    value: f32 = 5.0

world.add(entity, MoveSpeed(value=5.0))
```

Why this is better:
- The component name comes from the type.
- The size comes from the type.
- The default values come from the struct.
- The user does not write raw memory setup.
- The code says what it means: add `MoveSpeed` to this entity.

Current support note:
- `@component` exists as a marker, but automatic ECS registration and typed `world.add(...)` are not fully available as the final Kobic API yet.

## Desired Resource Style

Current style:

```dlt
state: EarthState = EarthState()
world.add_resource("EarthState", addressof(state), 4)

ptr: i64 = world.get_resource("EarthState")
```

Desired style:

```dlt
@resource
struct EarthState:
    ground_id: i32 = -1

world.insert_resource(EarthState())
earth: EarthState = world.resource<EarthState>()
```

Why this is better:
- Resources become typed.
- The user does not depend on string names.
- Systems can clearly ask for the resource they need.
- Game state becomes easier to find and reason about.

Current support note:
- Generic call style such as `world.resource<EarthState>()` is a future target for this ECS API, not something to assume is supported today.

## Desired Query Style

Current style:

```dlt
it: QueryIter = world.iter2_with("Transform", "MoveSpeed", "PlayerTag")

while it.next() == 1:
    entity: i32 = it.entity()
    transform: i64 = it.data_a()
    speed_ptr: i64 = it.data_b()
```

Desired style:

```dlt
for entity, transform, speed in world.query<Transform, MoveSpeed>().with<PlayerTag>():
    transform.x = transform.x + speed.value * dt
```

Alternative desired style:

```dlt
@system
fun move_player(
    player: @query<Transform, MoveSpeed, has=PlayerTag>,
    dt: @res<DeltaTime>
) -> void:
    player.transform.x = player.transform.x + player.speed.value * dt.value
```

Why this is better:
- The query is typed.
- The component list is visible directly in the code.
- The user does not manually map `data_a()` and `data_b()` to component meanings.
- The tag/filter is explicit.
- The loop reads like gameplay logic instead of storage traversal.

Current support note:
- The real game may still need lower-level query helpers today, but this reference example intentionally shows the cleaner target API.

## Desired Single Entity Lookup

Current style:

```dlt
player_ptr: i64 = world.first1_with("Transform", "PlayerTag")
if player_ptr == 0:
    return
```

Desired style:

```dlt
player_transform: Transform = world.first<Transform>().with<PlayerTag>()
```

Why this is better:
- It clearly asks for one `Transform` from the entity tagged as `PlayerTag`.
- It avoids manual pointer checks in simple cases.
- It makes player-following or camera-following code easier to read.

Current support note:
- This is target syntax. Real Kobic gameplay code may still need explicit lookup helpers today.

## Desired System Style

Current style:

```dlt
while win.should_close() == 0:
    update_player_input(world, renderer, player, dt)
    update_goblin_behavior(world, renderer, dt)
```

Desired style:

```dlt
@system(stage="update")
fun update_player_input(
    player: @query<Transform, MoveSpeed, has=PlayerTag>,
    dt: @res<DeltaTime>
) -> void:
    ...

@system(stage="update", after="update_player_input")
fun update_goblin_behavior(
    goblins: @query<Transform, GoblinBrain, FleeAgent, Facing, has=GoblinTag>,
    player: @query<Transform, has=PlayerTag>,
    dt: @res<DeltaTime>
) -> void:
    ...
```

Why this is better:
- Kobic can own the update order.
- Systems declare their data needs.
- The main file becomes smaller.
- `dt`, resources, and queries are passed consistently.
- Game logic is organized by system responsibility.

Current support note:
- `@system` exists as a marker, but automatic system scheduling is a future Kobic API goal.

## Desired App and Main Loop Style

Current style:

```dlt
win: Window = Window.create("Game", 800, 600)
ctx: VulkanContext = VulkanContext()
sc: Swapchain = Swapchain()
rp: RenderPass = RenderPass()
ren: Renderer = Renderer()
Engine.init_render(ctx, sc, rp, ren, wh, 800, 600)

while win.should_close() == 0:
    ...

Engine.cleanup(ctx, sc, rp, ren, world)
win.destroy()
```

Desired style:

```dlt
app: App = App.create("Game", 800, 600)
world: Scene = Scene.create()

spawn_world(world)
spawn_player(world, 0.0, 0.5, 0.0)

app.run(world)
```

Why this is better:
- The render lifecycle is not repeated in every game.
- Window, renderer, timing, and cleanup are owned by `App`.
- The game entry point describes the game, not the engine plumbing.

Current support note:
- Some convenience helpers exist in the easy example direction, but the fully clean `app.run(world)` style is still a target API.

## Desired Spawn Style

Current style:

```dlt
entity: i32 = world.spawn_cube(ren, "Goblin", 1.0, x, y, z)
Node3D.set_scale(world, entity, 0.5, 1.7, 0.5)
add_goblin_tag(world, entity)
add_goblin_brain(world, entity, x, z)
add_flee_agent(world, entity)
add_facing(world, entity)
world.sync_entity(ren, entity)
```

Desired style:

```dlt
entity: i32 = world.spawn_cube("Goblin", 1.0, x, y, z)
world.add(entity, GoblinTag())
world.add(entity, GoblinBrain(home_x=x, home_z=z))
world.add(entity, FleeAgent())
world.add(entity, Facing())
```

Possible later style:

```dlt
entity: i32 = world.spawn(GoblinPrefab(), x, y, z)
```

Why this is better:
- Spawn code focuses on the entity being created.
- Renderer plumbing disappears from gameplay code.
- Component setup is readable.
- Prefab/bundle style can reduce repeated mob setup later.

Current support note:
- Real Kobic gameplay code may still need explicit renderer/sync plumbing today, but this reference example intentionally hides it.

## Desired Transform Sync Style

Current style:

```dlt
Memory.write_f32(transform + 0, px)
Memory.write_f32(transform + 8, pz)
world.sync_entity(ren, entity)
```

Desired style:

```dlt
transform.x = px
transform.z = pz
```

Why this is better:
- Gameplay systems should edit transforms, not manually update render matrices.
- Kobic should decide when dirty transforms are synced.
- The code becomes shorter and less error-prone.

Current support note:
- Automatic dirty transform sync is a future Kobic API behavior.

## Desired Mob Organization

The file organization used by the current game is good and should stay:

```text
world/earth.dlt
mobs/player/player.dlt
mobs/player/controller.dlt
mobs/goblin/goblin.dlt
mobs/goblin/controller.dlt
```

Recommended responsibility split:
- `world/*`: decides what exists in this map and where it spawns
- `mobs/*/player.dlt` or `mobs/*/goblin.dlt`: defines components and setup for the entity type
- `mobs/*/controller.dlt`: defines behavior systems
- `main.dlt`: starts the app and wires high-level game startup only

Why this is better:
- `main.dlt` stays small.
- The world owns map layout.
- The mob owns its definition.
- The controller owns behavior.

## Things To Avoid

Avoid making the public Kobic ECS style depend on:
- raw `Memory.write_*` calls in normal gameplay code
- component byte sizes written by hand
- string component names in every update loop
- manual renderer passing through every spawn/update helper
- manual query result cleanup in hot paths
- large design-only syntax examples that look supported but are not

## Current Unsupported Or Not Final Syntax

These are useful future targets, but should be treated as design notes for now:

```dlt
world.query<Transform, MoveSpeed>().with<PlayerTag>()
world.get<MoveSpeed>(entity)
world.resource<EarthState>()
world.first<Transform>().with<PlayerTag>()
app.run(world)
@query<Transform, MoveSpeed, has=PlayerTag>
@res<DeltaTime>
```

Also treat this as future-facing pseudo syntax:

```dlt
app.run(world, systems=[
    update_player_input,
    update_goblin_behavior,
])
```

Reason:
- The final system registration/scheduling API is not decided yet.
- Lists of function values should not be assumed to be supported as the final Kobic user API today.

## Summary

The better Kobic ECS style should make the user write:
- typed components
- typed resources
- typed queries
- clear systems
- small main files
- clean mob/world organization

Instead of making users write:
- string-keyed component access
- raw memory field writes
- manual byte sizes
- manual query pointer mapping
- renderer plumbing in gameplay code
- manual system calls in every main loop

The target is simple:
- keep the ECS backend serious and fast
- make the front-facing Kobic API feel clean, typed, and game-focused
