# Fi collar charger plate

A 3D-printed **Decora outlet faceplate** that holds **two Fi Series 3 dog-collar
charging bases** in flanking cradles, charges the collars in place, keeps the
outlet usable, and routes the micro-USB cables down to a single exit.

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

Each base sits in a cup cradle that **leans back** (`cradle_tilt`, default 45°)
so the charging face aims **up-and-out**. Because the base is magnetic, the
collar module snaps on and stays put regardless of tilt — the lean is mostly for
presentation and band clearance. The collar band drapes down the front of the
plate.

**Cables / where they go:** each base's micro-USB cable exits a **notch on the
cup's inner side** and drops into a **groove** in the front face that runs down
alongside the Decora opening to the bottom-center. There, two **wind-posts**
flank the lower mounting screw (the screw stays accessible between them) — coil
any excess cable around the posts, then the short tails reach up into the opening
to the **USB brick** plugged into the outlet. Use a short cable (6–12") so there
is little slack to manage.

The wall side is clipped dead flat (the tilted cups blend into the plate via a
skirt that is sheared off at the wall plane), so it mounts flush.

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
| `cradle_tilt`| base face angle from vertical             | 45°                   |

Re-export after editing: `just build` (or override headless, e.g.
`openscad -D 'base_dia=63' -D 'base_clear=0.5' -o out.stl src/...scad`).

## Size note (the honest trade-off)

A face-up puck held near a wall **inherently sticks out** — there is no way to
charge a collar face-up against a wall without a shelf-like protrusion. At the
67 mm estimated size the plate comes out **~210 × 123 × 4 mm (8.3 × 4.8")** and
the cups stand **~35–45 mm proud** of the wall. Levers to shrink it:

- **Smaller real `base_dia`** — quite possible; 67 mm is an estimate.
- **Lower `cradle_tilt`** — flatter to the wall, less protrusion (magnetic
  retention means the collar stays on even at a low tilt).
- **Switch layout to stacked** (cups above the opening, not flanking) — a much
  narrower plate (~75 mm wide). This is a code change, not a parameter.

## Print settings (suggested — update after first print)

- Material: PETG or PLA+ (near an outlet; PETG tolerates warmth better).
- Layer height: 0.2 mm. Walls: 3+ perimeters. Infill: 20–30%.
- **Orientation:** plate back (wall side) flat on the bed; cups face up. The
  skirt ramp behind each cup prints as a self-supporting overhang at 45°; at
  higher `cradle_tilt` the cup's upper lip may want a little support.
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

## Status

**v1.2 — cable routing reworked for a USB brick in this same outlet: inner-side
notches, grooves down to bottom-center, two wind-posts for slack. Rendered +
manifold (`Simple: yes`).** Not yet printed; a ruler check of the real puck
would let you tighten the fit. See the table above.
