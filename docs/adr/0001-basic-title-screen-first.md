# 1. Basic title screen first, in-world title scene later

**Status:** Accepted (2026-11-23)

## Context

The original start screen was vibe-coded filler and is being scrapped. We want a title screen that looks like part of the game, but the game loop (rooms, combat, floors) isn't working yet.

## Decision

Build a basic title screen now: a title, Play and Quit buttons, and a slot for a full background image added later.

**Later:** replace the background with a small live scene built from the game's own tileset (maybe with idle characters), so the title screen looks just like the game.

## Consequences

- The title screen won't block the loop rework.
- The image slot is what lets the in-world scene drop in later without a redesign.
