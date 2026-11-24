# 3. Rooms fill one grid cell with a door on each side

**Status:** Accepted (2026-11-23)

## Context

ADR-0002 decided that each run assembles a Floor from hand-built Rooms, but left open how their doors line up. The options were:

- (a) A grid. Every Room fills one cell of the same size and has a door in the middle of each side, so any Room fits next to any other.
- (b) Rooms declare which sides have doors, and the layout only places Rooms whose doors fit.
- (c) A grid where big Rooms can span several cells (2×1, 2×2).

## Decision

(a). Every Room is 24×16 tiles, with a 2-tile door socket centred on each side. Neighbouring Rooms are joined by a 4-tile corridor. A Room declares its role (normal, Spawn Room or Ladder Room).

The layout is a random spanning tree over the grid cells, built with a disjoint set (Kruskal). The Ladder Room goes in the cell farthest from the Spawn Room. Sockets that don't lead to a neighbour are walled off when the Floor is built.

## Consequences

- The layout code stays simple, and any Room can go in any cell.
- The existing Rooms have to be rebuilt to the standard size. Every new Room follows the room template.
- All Rooms are the same size, so a big arena or a long hall can't be a single Room yet. (c) can be added later without breaking (a): a multi-cell Room is just a Room that fills more than one cell.
- A spanning tree has no loops, so there's exactly one path between any two Rooms. Loops can be added later by adding extra edges after the tree.
