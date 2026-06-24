---
title: "Fi collar charger plate"
description: "A 3D-printed Decora outlet faceplate that holds two Fi Series 3 dog-collar charging bases in flanking cradles, charges the collars in place, keeps the outlet usable, and swallows t…"
date: 2026-06-10
version: v2.2
tags: [pet, mounting, electronics]
material: PETG / PLA
print: { layer_height: 0.2mm, infill: 25%, supports: false }
license: CC-BY-NC-4.0
showcase: false
source: private
---

# Fi collar charger plate

A 3D-printed **Decora outlet faceplate** that holds **two Fi Series 3 dog-collar
charging bases** in flanking cradles, charges the collars in place, keeps the
outlet usable, and swallows the cables inside the cradle bodies.

![hero](images/plate-hero.png)

## What it mates with

- **Outlet:** standard single-gang **Decora / rocker** receptacle. Mounts with
  the existing two **6-32** strap screws, **3.812" (96.85 mm)** center-to-center.
  The Decora opening is left clear so the receptacle stays usable.
- **Chargers:** two round **Fi Series 3 charging bases** (the black pucks). The
  base is **magnetic** — the collar's module snaps onto the top face and is held
  by magnet while it charges. The holder grips the *base*; the base does the
  charging and collar retention. Powered by a micro-USB cable out of each base.
- **Power:** a small **USB wall brick plugs into this same outlet** (the opening
  is left clear for it — on a duplex receptacle one socket can stay free). Both
  base cables run inward to that brick, so there's no cable run down the wall.

## How it works

Each cradle is **one seamless hulled form**: a tilted cup blended smoothly into
a rounded foot pad on the plate — no flares or stuck-on boxes; the hull surface
itself is the blend. The cup leans back (`cradle_tilt`, default 30°) so the
charging face aims up-and-out; the magnetic base plus a thin lip keep everything
seated. The collar band drapes down the front.

**Geometry constraint (why 30° and why the cup floats):** a wide puck tilted
near a wall would physically extend *behind* the wall plane — at 45° a 67 mm
puck needs its rear edge ~22 mm inside the wall. The model auto-derives
`cup_lift` from the tilt so the entire recess clears the wall plane (+1 mm).
Versions before v1.6 missed this; their recesses were sheared off at the wall
and a real puck could never have seated. Raising `cradle_tilt` is allowed but
automatically grows the prow (45° → ~62 mm stick-out; 30° → ~48 mm).

**Retaining lip:** a thin inward **lip** (`lip_in`, default 1.3 mm) on the lower
half of the recess rim, with a gap at the bottom aligned with the cable slot.
Drop the puck in from the top; the lip catches its rim so it can't slide out.

**Cables / where they go:** the puck's micro-USB plug rides down a **slot in the
cup's lower wall** (`notch_w`) as the puck seats. The slot continues inside the
cradle body into a **hidden cable cavity** (`cav_*`) — coil the excess in there.
The tail exits a small **mouth on the cradle's inner side** and runs along a
shallow **groove** in the plate face to the USB brick in the outlet. Use a short
cable (6–12") so the cavity isn't overstuffed.

The mounting face is dead flat (everything is clipped at the wall plane), so it
sits flush on the outlet.

## Dimensions are ESTIMATED (Fi doesn't publish them)

Fi publishes no specs for the bare base puck — only the retail box
(170 × 110 × 63 mm). The values below are an **estimate** from product photos +
the box size, set at the top of
[src/fi-collar-charger-plate.scad](src/fi-collar-charger-plate.scad). The fit is
forgiving (magnetic retention + generous clearance), but a 20-second ruler check
of the real puck lets you tighten it to a true snug fit:

| Parameter    | Meaning                                   | Value (estimate)      |
|--------------|-------------------------------------------|-----------------------|
| `base_dia`   | outer diameter of the round Fi base       | **67 mm — estimate**  |
| `base_thick` | puck thickness / height                   | **13 mm — estimate**  |
| `base_clear` | radial fit clearance                      | 1.0 mm (generous)     |
| `cradle_tilt`| base face angle from vertical             | 30° (lift auto-derived) |

Re-export after editing: `just build` (or override headless, e.g.
`openscad -D 'base_dia=63' -D 'base_clear=0.5' -o out.stl src/...scad`).

## Size note (the honest trade-off)

A face-up puck held near a wall **inherently sticks out** — there is no way to
charge a collar face-up against a wall without a shelf-like protrusion, and the
wall-clearance constraint above makes the minimum protrusion a function of tilt.
At the 67 mm estimated size the plate comes out **~210 × 123 × 4 mm (8.3 × 4.8")**
and the cradles stand **~48 mm proud** at the rim front (30° tilt). Levers:

- **Smaller real `base_dia`** — quite possible; 67 mm is an estimate. Shrinks
  both the plate and the required lift.
- **Lower `cradle_tilt`** — flatter to the wall, smaller prow (magnetic
  retention means the collar stays on even at a low tilt).
- **Switch layout to stacked** (cups above the opening, not flanking) — a much
  narrower plate (~93 mm wide: cup + edge margins). This is a code change, not
  a parameter.

## Print settings (suggested — update after first print)

- Material: PETG or PLA+ (near an outlet; PETG tolerates warmth better).
- Layer height: 0.2 mm. Walls: 3+ perimeters. Infill: 15–25%. Solid model
  volume is ~280 cm³ (measured via trimesh) — the hulled cradles are chunky, so
  filament use is driven by infill; trust the slicer's estimate.
- **Orientation:** plate back (wall side) flat on the bed; cups face up. The
  hull prow is a smooth ~45–60° overhang — self-supporting. The hidden cable
  cavity ceiling bridges ~30 mm; droop in there is invisible. The cup rim's
  upper arc may want a touch of support at high `cradle_tilt`.
- Screws: reuse the outlet's existing 6-32 screws; `screw_clear`/`screw_head`
  are sized for a flat-head countersink on the front face.

## Build

```
just build      # export export/fi-collar-charger-plate.stl (high $fn)
just preview    # re-render images/*.png (needs xvfb on this headless host)
just dims       # print derived plate size / cup bore without exporting
just clean      # remove generated STL
```

BOSL2 is pulled from `~/.local/share/OpenSCAD/libraries` via `OPENSCADPATH`
(wired into the justfile).

Inspection renders: `-D section=1` slices a cup (YZ); `-D section=2` slices the
cable cavity (XZ).

## Status

**v1.6 — geometry rebuilt: each cradle is one hulled seamless form (cup + foot
pad), the cable cup is now an internal hidden cavity with an inner exit mouth,
and the wall-intersection flaw was found and fixed (`cup_lift` auto-derived so
the recess actually clears the wall; tilt default now 30°). Verified by a
3-agent adversarial audit (numeric transform recomputation + trimesh probes of
the STL + render inspection): recess clears the wall by 0.87 mm, chute→cavity
aperture 175 mm², mouth exits to open air, mesh watertight. The audit caught and
this version fixes: a lip strap bridging the cable slot (center=true cutter
bug), 0.16 mm cavity-corner membranes (pad roundover now buried in the plate),
a mouth-exit ledge, floating groove starts, and a 1 mm groove web (now 2 mm).**
Not yet printed; a ruler check of the real puck would let you tighten the fit.
See the table above.

Earlier: v1.5 flare experiment (superseded — the flare never matched the tilted
footprint and looked lumpy), v1.4 hollow-shell fix, v1.3 bins + lip, v1.2 inward
routing, v1.1 estimated dims, v1 first cut.
