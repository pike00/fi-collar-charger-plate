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

/* [Fi base puck — MEASURE THESE THREE] */
// Outer diameter of the round Fi base puck (mm).            <-- MEASURE
base_dia      = 64;      // placeholder ~2.5in; replace with caliper reading
// Puck thickness / height (mm).                             <-- MEASURE
base_thick    = 14;      // placeholder; replace with caliper reading
// Where the micro-USB cable leaves the base: "side" or "bottom".  <-- MEASURE
cable_exit    = "side";

/* [Fit] */
// Radial clearance around the puck (mm). Bigger = looser. 0.4-0.8 typical FDM.
base_clear    = 0.6;

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

/* [Cable management] */
channel_w     = 7;       // mm  width of the front-face cable channel
channel_d     = 3.5;     // mm  depth of the channel
cable_clip    = true;    // add a snap-over bridge on each channel

/* [Quality] */
$fn           = 48;      // bump to 96+ for the final export

// ---- derived ----------------------------------------------------------------
cup_id        = base_dia + 2*base_clear;          // cup inner bore
cup_od        = cup_id + 2*cradle_wall;           // cup outer
cup_h         = cup_depth + floor_th;             // cup total height
off_x         = opening_w/2 + gap + cup_od/2;     // cradle center, off the midline
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
    difference() {
        union() {
            cylinder(h = cup_h, d = cup_od);                 // the cup
            translate([0, 0, -skirt]) cylinder(h = skirt + eps, d = cup_od); // skirt
        }
        // puck bore
        translate([0, 0, floor_th]) cylinder(h = cup_h, d = cup_id);
        // floor hole (kept above z=0 so it can't tunnel to the wall side)
        translate([0, 0, 0.6]) cylinder(h = cup_h, d = center_hole);
        // cable notch through the DOWN-slope wall (-Y local), open to the rim
        translate([0, -cup_od/2, floor_th + cup_depth/2])
            cube([cable_notch_w, cradle_wall*3, cup_depth + 2*eps], center = true);
    }
}

module cradle_at(sx) {
    // sx = -1 (left) or +1 (right). Pivot at the plate front face, lean the cup
    // back so its opening aims up-and-out. The skirt swings behind the plate and
    // is clipped flat by back_clip().
    translate([sx*off_x, 0, plate_th])
        rotate([-cradle_tilt, 0, 0])      // +Z opening tips toward +Y (up & out)
            one_cradle();
}

module cable_channel(sx) {
    // groove on the front face from under the cup down to the bottom edge
    x = sx*off_x;
    y0 = -cup_od/2;                 // just below the cup
    y1 = -plate_h/2 + eps;          // bottom edge
    translate([x, (y0+y1)/2, plate_th - channel_d/2 + eps])
        cube([channel_w, abs(y0 - y1), channel_d + eps], center = true);
}

module cable_clip_at(sx) {
    // a thin bridge spanning the channel to retain the cable
    x = sx*off_x;
    y = -plate_h/2 + 14;
    translate([x, y, plate_th + channel_d*0.2])
        difference() {
            cube([channel_w + 6, 3, channel_d + 3.2], center = true);
            translate([0, 0, -channel_d*0.5])
                cube([channel_w - 1.5, 5, channel_d + 1.5], center = true);
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
            for (s = [-1, 1]) cradle_at(s);
            if (cable_clip) for (s = [-1, 1]) cable_clip_at(s);
        }
        decora_opening();
        screw_holes();
        for (s = [-1, 1]) cable_channel(s);
        back_clip();
    }
}

fi_charger_plate();
