// =============================================================================
// Fi collar charger plate — flanking cradles on a Decora outlet faceplate
// -----------------------------------------------------------------------------
// Mounts to a standard single-gang DECORA receptacle using the two 6-32 strap
// screws (3.812" / 96.85 mm vertical c-c). The Decora opening stays clear so a
// small USB brick can plug into the outlet. Two cradles flank the opening; each
// is ONE seamless hulled form: a tilted cup (charging face up-and-out) blending
// smoothly into a rounded base pad on the plate. The Fi base puck drops into the
// cup and a thin lip captures its rim. The puck's cable rides down a slot in
// the cup's lower wall into a HOLLOW CAVITY inside the cradle body, then exits
// through a slot in the plate BACK FACE into the wall box — no groove across
// the plate front, no sharp inner-mouth bend (~30° curve max from cup axis).
//
// The holder grips the BASE; the base (magnetic) does the charging + collar
// retention. Only fit-critical inputs are the puck's own dimensions.
//
// Build:   just build        (STL)     |  Preview: just preview  (PNG)
// Override any param headless:  openscad -D 'base_dia=44' -o out.stl <src>
// Inspect: -D section=1 (YZ slice through a cup), -D section=2 (XZ slice
//          through the cable cavity).
// =============================================================================

include <BOSL2/std.scad>

/* [Fi base puck — measured with calipers] */
// Outer diameter of the round Fi Series 3 base puck (mm). Measured: 44 mm.
base_dia      = 44;
// Puck thickness / height (mm). Measured: 11 mm.
base_thick    = 11;

/* [Fit] */
// Radial clearance around the puck (mm). Tightened to 0.5 now that we have
// a real measurement; adjust ±0.2 for printer tolerance.
base_clear    = 0.5;

/* [Cradle] */
// Base FACE angle from VERTICAL: 0 = faces straight out from wall, 90 = faces
// straight up. NOTE: tilting a wide puck near a wall forces the cup outward —
// the model auto-derives `cup_lift` so the recess fully clears the wall plane
// (at 45 deg the prow would stick out ~62 mm; 30 deg lands at ~48 mm).
cradle_tilt   = 30;      // deg
// How deep the puck sits into the cup. Keep < base_thick so the charging face
// stays exposed for the collar.
cup_depth     = 9;       // mm
cradle_wall   = 3.2;     // mm  cup side wall
floor_th      = 2.8;     // mm  cup floor thickness
cup_round     = 2.5;     // mm  rounding on the cup body edges (soft rim)

/* [Base pad — the cradle's foot; the hull from cup to pad IS the seamless blend] */
pad_d         = 42;      // mm  pad diameter on the plate
pad_y         = -36;     // mm  pad center, below the cup (toward plate bottom)
pad_h         = 14;      // mm  pad height
pad_round     = 5;       // mm  pad edge rounding

/* [Charger retaining lip — thin catch over the puck rim] */
lip_in        = 1.3;     // mm  inward overhang over the puck rim
lip_h         = 1.4;     // mm  lip thickness (down from the cup rim)
lip_gap_w     = 18;      // mm  gap in the lip at the bottom (puck/cable slot)

/* [Cable — slot down cup wall into cavity, exits through plate BACK face] */
notch_w       = 14;      // mm  slot width in the cup's lower wall (plug rides down)
cav_w         = 30;      // mm  internal cable cavity width  (x)
cav_len       = 36;      // mm  internal cable cavity length (y)
cav_h         = 10;      // mm  cavity height above the plate front
mouth_w       = 14;      // mm  back-plate exit slot width (x); cable exits rearward

/* [Decora plate] */
plate_th      = 4.0;     // mm  faceplate slab thickness
plate_corner  = 6;       // mm  rounded outer corners
opening_w     = 33.3;    // mm  Decora opening width  (1.31")
opening_h     = 66.8;    // mm  Decora opening height (2.63")
opening_r     = 4;       // mm  opening corner radius
screw_spacing = 96.85;   // mm  6-32 strap screw c-c, vertical (3.812")
screw_clear   = 4.0;     // mm  6-32 shank clearance hole
screw_head    = 8.0;     // mm  countersink head diameter (flat-head)
edge_margin   = 9;       // mm  plate material around the cradles/screws
gap           = 4;       // mm  clearance between Decora opening and a cradle

/* [Quality] */
$fn           = 48;      // bump to 96+ for the final export

// ---- derived ----------------------------------------------------------------
cup_id        = base_dia + 2*base_clear;          // cup inner bore
cup_od        = cup_id + 2*cradle_wall;           // cup outer
cup_h         = cup_depth + floor_th;             // cup total height
// Lift the cup out along its own axis until the recess floor's rear edge sits
// in FRONT of the wall plane (+1 mm along the axis, ~0.87 mm normal to the
// wall). Without this, a tilted wide puck physically intersects the wall — the
// flaw in every version before v1.6.
cup_lift      = max(0, (cup_id/2)*tan(cradle_tilt) - floor_th + 1);
assert(cup_depth < base_thick,
       "cup_depth must stay below base_thick so the charging face is exposed");
off_x         = opening_w/2 + gap + cup_od/2;     // cradle center, off the midline
cav_y         = -32;                              // cavity center (y)
plate_w       = 2*(off_x + cup_od/2) + 2*edge_margin;
plate_h       = screw_spacing + 2*(screw_head/2 + edge_margin);
eps           = 0.02;

echo(str("== Fi collar charger plate =="));
echo(str("  cup bore (puck+clear): ", cup_id, " mm   cup outer: ", cup_od, " mm"));
echo(str("  cup_lift: ", cup_lift, " mm (auto, keeps recess in front of wall)"));
echo(str("  stick-out at rim front: ~",
         plate_th + (cup_lift + cup_h)*cos(cradle_tilt) + (cup_od/2)*sin(cradle_tilt),
         " mm proud of the wall (upper bound; rim rounding trims ~1 mm)"));
echo(str("  PLATE: ", plate_w, " x ", plate_h, " x ", plate_th, " mm",
         "  (", plate_w/25.4, " x ", plate_h/25.4, " in)"));

// ---- frames ------------------------------------------------------------------
// Cup-local tilted frame: origin at the BOTTOM CENTER of the (lifted) cup,
// +Z along the cup axis (tilted back by cradle_tilt so it aims up-and-out).
// The lift keeps the whole recess in front of the wall plane.
module in_cup_frame() {
    translate([0, 0, plate_th])
        rotate([-cradle_tilt, 0, 0])
            translate([0, 0, cup_lift])
                children();
}

// Place children at a cradle position. The local +X axis is the INNER side
// (toward the outlet); the right cradle is mirrored so its mouth also faces in.
module at_cradle(sx) {
    translate([sx*off_x, 0, 0]) {
        if (sx > 0) mirror([1, 0, 0]) children();
        else children();
    }
}

// ---- the model ----------------------------------------------------------------
module plate_blank() {
    translate([0, 0, plate_th/2])
        cuboid([plate_w, plate_h, plate_th],
               rounding = plate_corner, edges = "Z");
}

module decora_opening() {
    translate([0, 0, -eps])
        linear_extrude(plate_th + 2*eps)
            rect([opening_w, opening_h], rounding = opening_r);
}

module screw_holes() {
    for (s = [-1, 1])
        translate([0, s*screw_spacing/2, 0]) {
            translate([0, 0, -eps])
                cylinder(h = plate_th + 2*eps, d = screw_clear);
            translate([0, 0, plate_th - (screw_head-screw_clear)/2])
                cylinder(h = (screw_head-screw_clear)/2 + eps,
                         d1 = screw_clear, d2 = screw_head);
        }
}

// The whole cradle body is ONE convex hull: tilted cup blended into the base
// pad. No flares, no stuck-on boxes — the hull surface IS the seamless blend.
module cradle_solid() {
    hull() {
        in_cup_frame()
            cyl(h = cup_h, d = cup_od, rounding = cup_round, anchor = BOTTOM);
        // pad sunk by pad_round so its bottom roundover is buried in the plate:
        // at the plate face the pad presents its FULL radius, keeping ≥2 mm of
        // wall around the cable cavity corners (was a 0.16 mm membrane)
        translate([0, pad_y, plate_th - pad_round])
            cyl(h = pad_h + pad_round, d = pad_d, rounding = pad_round, anchor = BOTTOM);
    }
}

// Puck recess, cut along the tilted axis. The puck rests on the floor.
module recess_cut() {
    in_cup_frame()
        translate([0, 0, floor_th])
            cylinder(h = cup_h + 8, d = cup_id);
}

// One straight slot does double duty: the notch in the cup's lower wall (the
// plug rides down it as the puck seats) continuing down inside the hull body
// to break into the cable cavity. Local-frame prism along the cup axis.
module chute_cut() {
    y0 = -(cup_od/2 + 0.5);          // just past the outer wall face
    y1 = -(cup_id/2) + 8;            // 8 mm into the recess
    z0 = -cup_lift - 10;             // reaches down through the lift into the cavity
    z1 = floor_th + cup_depth + 2;   // fully open at the rim
    in_cup_frame()
        translate([0, (y0+y1)/2, (z0+z1)/2])
            cube([notch_w, y1 - y0, z1 - z0], center = true);
}

// Internal cable cavity: a hidden hollow inside the cradle body, floor = the
// plate front. Slightly sunk (0.01) to avoid a coplanar face with the plate.
module cavity_cut() {
    translate([0, cav_y, plate_th + cav_h/2 - 0.01])
        cuboid([cav_w, cav_len, cav_h + 0.02], rounding = 4,
               edges = "ALL", except = BOTTOM);
}

// Cable exits through the BACK face of the plate (z = 0) into the wall box.
// Replaces the old inner-side mouth + front-face groove: no sharp bend, no
// groove visible on the plate front. Slot is centered at cav_y so it connects
// directly to the cavity floor.
module back_plate_exit() {
    translate([0, cav_y, -eps])
        linear_extrude(plate_th + 2*eps)
            rect([mouth_w, 18], rounding = 2);
}

// Thin retaining lip on the lower half of the recess rim, gap at the bottom
// aligned with the cable slot. Added after all cuts so it survives them.
module lip() {
    in_cup_frame()
        difference() {
            intersection() {
                translate([0, 0, cup_h - lip_h - 0.6])
                    difference() {
                        cylinder(h = lip_h, d = cup_id + 0.6);
                        translate([0, 0, -eps])
                            cylinder(h = lip_h + 2*eps, d = cup_id - 2*lip_in);
                    }
                translate([-cup_od, -cup_od, 0]) cube([2*cup_od, cup_od, cup_h*2]);
            }
            // gap cutter CENTERED on the lip ring's mid-height so it removes
            // the full ring height (a center=true cube anchored at the ring
            // base previously left a 0.7 mm strap bridging the slot)
            translate([0, -cup_id/2, cup_h - 0.6 - lip_h/2])
                cube([lip_gap_w, 20, lip_h + 2], center = true);
        }
}

// Remove everything behind the wall plane (z < 0) so the mounting face is flat.
module back_clip() {
    translate([0, 0, -1000]) cube([4000, 4000, 2000], center = true);
}

module fi_charger_plate() {
    union() {
        difference() {
            union() {
                plate_blank();
                for (s = [-1, 1]) at_cradle(s) cradle_solid();
            }
            decora_opening();
            screw_holes();
            for (s = [-1, 1]) at_cradle(s) {
                recess_cut();
                chute_cut();
                cavity_cut();
                back_plate_exit();
            }
            back_clip();
        }
        difference() {
            for (s = [-1, 1]) at_cradle(s) lip();
            back_clip();
        }
    }
}

// section: 0 = full model, 1 = YZ slice through the left cup, 2 = XZ slice
// through the cable cavity (set via -D for inspection renders).
section = 0;
if (section == 1)
    intersection() {
        fi_charger_plate();
        translate([-off_x, 0, 60]) cube([1.5, 400, 400], center = true);
    }
else if (section == 2)
    intersection() {
        fi_charger_plate();
        translate([0, cav_y, 60]) cube([400, 1.5, 400], center = true);
    }
else
    fi_charger_plate();
