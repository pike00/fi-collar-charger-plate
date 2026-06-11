// =============================================================================
// Fi collar charger plate — flanking cradles on a Decora outlet faceplate
// -----------------------------------------------------------------------------
// Mounts to a standard single-gang DECORA receptacle using the two 6-32 strap
// screws (3.812" / 96.85 mm vertical c-c). The Decora opening stays clear so the
// outlet remains usable. Two tilted cradles flank the opening (left + right);
// each cradle grips a round Fi charging BASE puck and tilts its charging face
// up-and-out so the collar module seats by gravity and stays put while charging.
// The collar band drapes down the front; the base's micro-USB cable exits a
// notch and routes down a front-face channel to the bottom edge.
//
// The holder grips the BASE; the base does the charging + collar retention.
// So the only fit-critical numbers are the puck's own dimensions  ->  MEASURE.
//
// Build:   just build        (STL)     |  Preview: just preview  (PNG)
// Override any param headless:  openscad -D 'base_dia=58' -o out.stl <src>
// =============================================================================

include <BOSL2/std.scad>

/* [Fi base puck — ESTIMATED (not published anywhere); confirm with a ruler) */
// Outer diameter of the round Fi Series 3 base puck (mm).
// ESTIMATE: reads just under a hockey puck (76mm) in the photo; retail box
// interior (110mm) easily contains it. Replace with a caliper reading to nail
// the snug fit. The S3 base is MAGNETIC (collar snaps to its top), so a couple
// mm of slop here is harmless.
base_dia      = 67;
// Puck thickness / height (mm). ESTIMATE for a thin magnetic charging disc.
base_thick    = 13;
// (cable routing is fixed: each base's cable exits the cup's INNER side and
// heads toward the USB brick plugged into this outlet — see Cable management.)

/* [Fit] */
// Radial clearance around the puck (mm). Slightly generous (1.0) because the
// diameter is estimated and the base is magnetically retained — tighten to
// 0.4-0.6 once you have a real measurement for a true snug fit.
base_clear    = 1.0;

/* [Cradle] */
// Base FACE angle from VERTICAL: 0 = faces straight out from wall (collar
// falls), 90 = faces straight up (max stick-out). The cup leans back by this
// much so the charging face aims up-and-out. Lower = flatter to wall + less
// protrusion but the collar relies more on the base's own recess to stay put;
// higher = collar held by gravity but the shelf sticks out further.
cradle_tilt   = 45;      // deg
// How deep the puck sits into the cup (grip). Keep < base_thick so the
// charging face stays exposed for the collar.
cup_depth     = 9;       // mm
cradle_wall   = 3.2;     // mm  side wall of the cup
floor_th      = 2.8;     // mm  cup floor thickness
skirt         = 30;      // mm  solid blend that roots the cup into the plate;
                         //     anything behind the wall plane is clipped flat
center_hole   = 22;      // mm  hole in the cup floor (saves plastic, lets a
                         //     bottom-exit cable pass, makes seating visible)
cable_notch_w = 12;      // mm  width of the cable exit notch in the cup wall

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

/* [Charger retaining lip — captures the puck so it can't slide out] */
lip_in        = 1.3;     // mm  how far the lip overhangs inward over the puck rim (thin)
lip_h         = 1.4;     // mm  lip thickness (depth down from the cup rim)
lip_gap_w     = 18;      // mm  gap left in the lip at the bottom for the cable

/* [Seamless rounding — blend everything into one molded-looking piece] */
rim_chamfer   = 2.0;     // mm  chamfer softening the cup's top outer rim
seamless_base = true;    // add a flared fillet where cups + bins meet the plate
flare_r       = 3.5;     // mm  radius of that base fillet

/* [Cable management — a hollow cup below each charger swallows the cable] */
cc_w          = 52;      // mm  cable cup width (x)
cc_h          = 22;      // mm  cable cup height (y)
cc_z          = 15;      // mm  how far the cable cup stands proud of the plate
cc_wall       = 2.6;     // mm  cable cup wall thickness
channel_w     = 7;       // mm  width of the tail groove from cup to the brick
channel_d     = 3.0;     // mm  depth of that groove (plate is 4 mm)

/* [Quality] */
$fn           = 48;      // bump to 96+ for the final export

// ---- derived ----------------------------------------------------------------
cup_id        = base_dia + 2*base_clear;          // cup inner bore
cup_od        = cup_id + 2*cradle_wall;           // cup outer
cup_h         = cup_depth + floor_th;             // cup total height
off_x         = opening_w/2 + gap + cup_od/2;     // cradle center, off the midline
cc_cy         = -(cup_od/2 + cc_h/2 - 2);         // cable cup center, just below cup
plate_w       = 2*(off_x + cup_od/2) + 2*edge_margin;
plate_h       = screw_spacing + 2*(screw_head/2 + edge_margin);
eps           = 0.02;

echo(str("== Fi collar charger plate =="));
echo(str("  cup bore (puck+clear): ", cup_id, " mm   cup outer: ", cup_od, " mm"));
echo(str("  PLATE: ", plate_w, " x ", plate_h, " x ", plate_th, " mm",
         "  (", plate_w/25.4, " x ", plate_h/25.4, " in)"));

// ---- the model --------------------------------------------------------------
module plate_blank() {
    // rounded slab, wall side at z=0, front face at z=plate_th
    translate([0, 0, plate_th/2])
        cuboid([plate_w, plate_h, plate_th],
               rounding = plate_corner, edges = "Z");
}

module decora_opening() {
    // through cut, centered
    translate([0, 0, -eps])
        linear_extrude(plate_th + 2*eps)
            rect([opening_w, opening_h], rounding = opening_r);
}

module screw_holes() {
    for (s = [-1, 1])
        translate([0, s*screw_spacing/2, 0]) {
            // shank
            translate([0, 0, -eps])
                cylinder(h = plate_th + 2*eps, d = screw_clear);
            // flat-head countersink on the FRONT face (z = plate_th)
            translate([0, 0, plate_th - (screw_head-screw_clear)/2])
                cylinder(h = (screw_head-screw_clear)/2 + eps,
                         d1 = screw_clear, d2 = screw_head);
        }
}

// A cradle built upright (axis = +Z, opening up) at the origin. The solid
// extends DOWN into a long skirt (negative Z) so that after the caller tilts
// it, the skirt fully overlaps the plate; everything behind the wall plane is
// later clipped flat. The puck bore + floor hole stay in positive Z so they
// never break through to the wall side.
module one_cradle() {
    union() {
        difference() {
            union() {
                cyl(h = cup_h, d = cup_od, chamfer2 = rim_chamfer, anchor = BOTTOM); // cup, softened rim
                translate([0, 0, -skirt]) cylinder(h = skirt + eps, d = cup_od); // stem
            }
            // puck recess (open top) — the puck rests on the floor at z=floor_th
            translate([0, 0, floor_th]) cylinder(h = cup_h, d = cup_id);
            // HOLLOW the stem below the floor so the cradle is a shell, not a
            // solid wedge. Leaves a wall ring that reaches down to the plate.
            translate([0, 0, -skirt - eps]) cylinder(h = skirt + eps, d = cup_id);
            // hole through the floor so the cable can pass from the recess down
            // into the hollow stem and on to the cable cup below
            translate([0, 0, -eps]) cylinder(h = floor_th + 2*eps, d = center_hole);
            // cable notch through the DOWN (-Y) wall; the lip leaves a gap here
            translate([0, -cup_od/2, floor_th + cup_depth/2])
                cube([cable_notch_w, cradle_wall*3, cup_depth + 2*eps], center = true);
        }
        cup_lip();   // added AFTER the recess cut so it survives, overhanging inward
    }
}

// Retaining lip: a small inward overhang on the LOWER half of the cup rim, so
// the puck drops in from the open top and is then captured. A gap at the very
// bottom clears the cable notch.
module cup_lip() {
    difference() {
        intersection() {
            translate([0, 0, cup_h - lip_h])
                difference() {
                    cylinder(h = lip_h + eps, d = cup_id);
                    translate([0, 0, -eps]) cylinder(h = lip_h + 3*eps, d = cup_id - 2*lip_in);
                }
            // keep only y < 0 (the lower half of the rim)
            translate([-cup_od, -cup_od, cup_h - lip_h - eps])
                cube([cup_od*2, cup_od, lip_h + 3*eps]);
        }
        // gap at the bottom for the cable notch
        translate([0, -cup_od/2, cup_h - lip_h - eps])
            cube([lip_gap_w, cup_od, lip_h + 3*eps], center = true);
    }
}

module cradle_at(sx) {
    // Pivot at the plate front face, lean the cup back so its opening aims
    // up-and-out. The skirt swings behind the plate and is clipped flat.
    translate([sx*off_x, 0, plate_th])
        rotate([-cradle_tilt, 0, 0])
            one_cradle();
}

// A rounded groove cut into the front face along a polyline of [x,y] points.
module groove(pts) {
    for (i = [0:len(pts)-2])
        hull() for (p = [pts[i], pts[i+1]])
            translate([p[0], p[1], plate_th - channel_d])
                cylinder(h = channel_d + eps, d = channel_w);
}

// Hollow cable cup below each charger: a forward-protruding bin, open at the
// top to receive the cable from the cup above, solid front wall to hide it.
module cable_cup_shell(sx) {
    translate([sx*off_x, cc_cy, plate_th + cc_z/2])
        cuboid([cc_w, cc_h, cc_z], rounding = 4, edges = "ALL", except = BOTTOM);
}

module cable_cup_cut(sx) {
    ix = cc_w - 2*cc_wall;
    // hollow interior: bottom + side + front walls, OPEN top; plate is the back
    translate([sx*off_x - ix/2, cc_cy - cc_h/2 + cc_wall, plate_th - eps])
        cube([ix, cc_h, cc_z - cc_wall + eps]);
    // tail-exit notch in the INNER side wall near the top (toward the brick)
    translate([sx*(off_x - cc_w/2), cc_cy + cc_h/2 - 7, plate_th + cc_z*0.45])
        cube([cc_wall*3, 9, 9], center = true);
}

// Short groove carrying the tail from the cable cup's inner-top out to the
// Decora opening, where the USB brick is plugged in.
module tail_groove(sx) {
    start = [sx*(off_x - cc_w/2),    cc_cy + cc_h/2 - 7];
    endp  = [sx*(opening_w/2 + 2),   -opening_h/2 - 2];
    groove([start, endp]);
}

// Approximate footprint of the protruding features on the plate (cheap explicit
// shapes, not a costly projection): a Y-stretched ellipse for each tilted cup
// plus a rounded rect for each bin. The two overlap, so per side it is one blob.
module footprint_2d() {
    for (s = [-1, 1]) {
        translate([s*off_x, -6]) scale([1, 1.35]) circle(d = cup_od);   // tilted cup shadow
        translate([s*off_x, cc_cy]) square([cc_w, cc_h], center = true); // bin
    }
}

// A flared fillet that grows out of the plate around that footprint, tapering up
// to meet the features — so the cups and bins look molded into the plate instead
// of glued on. Minkowski of the (cheap) footprint with a cone.
module base_flare() {
    translate([0, 0, plate_th - eps])
        minkowski() {
            linear_extrude(height = eps) footprint_2d();
            cylinder(h = flare_r, r1 = flare_r, r2 = 0.01, $fn = 20);
        }
}

// Remove everything behind the wall plane (z < 0) so the mounting face is dead
// flat — the tilted cup skirts get sheared off here, blending into the plate.
module back_clip() {
    translate([0, 0, -1000]) cube([4000, 4000, 2000], center = true); // z in [-2000,0]
}

module fi_charger_plate() {
    difference() {
        union() {
            plate_blank();
            if (seamless_base) base_flare();
            for (s = [-1, 1]) cradle_at(s);
            for (s = [-1, 1]) cable_cup_shell(s);
        }
        decora_opening();
        screw_holes();
        for (s = [-1, 1]) cable_cup_cut(s);
        for (s = [-1, 1]) tail_groove(s);
        back_clip();
    }
}

section = false;   // set true (via -D) to render a YZ slice through the left cup
if (section)
    intersection() {
        fi_charger_plate();
        translate([-off_x, 0, 60]) cube([1.5, 400, 400], center = true);
    }
else
    fi_charger_plate();
