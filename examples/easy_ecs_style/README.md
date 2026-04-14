# Easy ECS Style Example

This folder is a design/reference example for the cleaner Kobic ECS style we want.

It keeps the same project shape as the real game:
- `main.dlt`
- `world/earth.dlt`
- `mobs/player/*`
- `mobs/goblin/*`

It intentionally shows the desired future-facing API:
- typed `@component` and `@resource`
- typed `world.add(...)`
- typed resource access like `world.resource<EarthState>()`
- query parameters like `@query<Transform, MoveSpeed, has=PlayerTag>`
- scheduled systems through `@system`
- app-owned run loop through `app.run(world)`

Important:
- This folder is not the current build target.
- Some syntax shown here is not the current supported Kobic API yet.
- The goal is to keep a clear example of the API shape we want users to write later.
