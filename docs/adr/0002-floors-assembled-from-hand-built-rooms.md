# 2. Floors are assembled from hand-built rooms each run

**Status:** Accepted (2026-11-23)

## Context

Today the whole map is placed by hand in `game.tscn`. A roguelike needs each run to feel different. The options were:

- (a) Hand-built floors, the same every run.
- (b) Hand-built rooms arranged into a random layout each run.
- (c) Fully generated rooms.

## Decision

(b). Designers keep building individual rooms by hand, and each run arranges them into a new floor layout.

## Consequences

- Each room has to be built so it can connect to any neighbour. The details of how doors line up are still to be decided.
- `game.tscn` stops being the map and becomes the container the floor is built into.
- It costs more than (a), but every room built from now on has to follow the shared room rules, so deciding now avoids reworking rooms later.
