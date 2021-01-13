include <lib/screw_holes.scad>

$fn = 64;

// ============================================================================
// parts
// ============================================================================
renderBox = false;
renderLid = false;
renderKnob = false;
renderTestPlate = false;

// ============================================================================
// box dimensions (mm)
// ============================================================================
box_width = 125;    // width
box_depth = 125;    // depth
box_height = 25;    // height
wall_thickness = 2; // wall thickness (to be used for walls, top and lid)
corner_size = 10;   // rounded corner size

// ============================================================================
// volume knob (mm)
// ============================================================================
pot_diameter = 7.5;         // potentiometer hole diameter
pot_shaft_diameter = 6;     // potentiometer shaft diameter
pot_shaft = 14;             // potentiometer shaft length
knob_diameter = box_height - 5; // volume knob diameter
knob_sink = 3;              // difference between the outer circle and inner circle on the volume knob

// ============================================================================
// connectors (mm)
// ============================================================================
/* power button */
pw_btn_width = 9;           // switch width
pw_btn_height = 14;         // switch height
pw_btn_margin_right = 15;   // distance between edge of box and power button

/* dc power connector */
pw_conn_diameter = 8 + 0.2; // power connector hole diameter 

/* speaker connector */
spk_width = 56;             // speaker connector width
spk_height = 14;            // speaker connector height
spk_margin_right = 15;      // distance between edge of box and speaker connector

/* speaker screws */
spk_screw_diameter = 2.7;   // speaker connector screws diameter
spk_screw_margin = 2;       // margin between connector hole and opening

// ============================================================================
// lid options (mm)
// ============================================================================
/* lid screws */
screw_sz = M2_5;        // screw size
/* lid grid gap */
lid_grid_depth = 2;


// ============================================================================
// internal variables
// ============================================================================

/* location - enclosure body*/
body = [box_depth, box_width, box_height];

/* location - potentiometer */
potentiometer = [body[0] - wall_thickness, body[1] / 2, body[2] / 2];

/* location - power switch*/
pw_bottom_margin = (box_height - pw_btn_height) / 2;
pw_switch = [0, pw_btn_margin_right, pw_bottom_margin];

/* location - power connector */
pw_connector = [0, pw_switch[1] + pw_btn_width + 10, body[2] / 2];

/* location - speaker */
spk_connector = [0, body[1] - spk_margin_right - spk_width, (body[2] - spk_height) / 2];
spk_gutter = spk_screw_diameter + spk_screw_margin;

/* location - lid */
lid = [box_depth - (wall_thickness * 2), box_width - (wall_thickness * 2), wall_thickness];


// size is a vector [w, h, d]
module roundedBox(size, radius)
{
    rot = [[0, 0, 0], [90, 0, 90], [90, 90, 0]];

    cube(size - [2 * radius, 0, 0], true);
    cube(size - [0, 2 * radius, 0], true);
    for (x = [radius - size[0] / 2, - radius + size[0] / 2],
        y = [radius - size[1] / 2, - radius + size[1] / 2]) {
        translate([x, y, 0]) cylinder(r = radius, h = size[2], center = true);
    }
}

// outer enclosure
module outer_box(size) {
    translate([size[0] / 2, size[1] / 2, size[2] / 2]) roundedBox(size, 10);
}

// inner enclosure
module inner_box(size, cut)
{
    difference() {
        cube(size);
        cube([cut, cut, size[2]]);
        translate([0, size[1] - cut, 0]) cube([cut, cut, size[2]]);
        translate([size[0] - cut, 0, 0]) cube([cut, cut, size[2]]);
        translate([size[0] - cut, size[1] - cut, 0]) cube([cut, cut, size[2]]);

        // middle supports
        x_pos = size[0] / 2 - cut / 2;
        translate([x_pos, 0, 0]) cube([cut, cut, size[2]]);
        translate([x_pos, size[1] - cut,0]) cube([cut, cut, size[2]]);
    }
}

// speaker connector
module speaker_connector(width, height, thickness) {

    /* screw holes */
    translate([0, 0, height / 2]) rotate([0, 90, 0]) cylinder(d = spk_screw_diameter, h = thickness);
    translate([0, width, height / 2]) rotate([0, 90, 0]) cylinder(d = spk_screw_diameter, h = thickness);

    /* connector hole */
    gutter = spk_screw_margin + spk_screw_diameter;
    translate([0, gutter, 0]) cube([thickness, width - (gutter * 2), height]);
}

// amplifier enclosure
module enclosure() {
    difference() {
        /* outer shell */
        translate([0, 0, 0]) outer_box(body);

        /* empty body area */
        inner = body - [wall_thickness * 2, wall_thickness * 2, wall_thickness];
        translate([wall_thickness, wall_thickness, wall_thickness]) inner_box(inner, corner_size);

        // screw shaft
        half_corner = corner_size / 2;
        shaft_depth = body[2] / 2;
        x_mid = (body[0] / 2);
        y_l = wall_thickness + half_corner;
        y_r = body[1] - wall_thickness - half_corner;
        x_l = wall_thickness + half_corner;
        x_r = body[0] - wall_thickness - half_corner;

        translate([x_l, y_l, body[2]]) rotate([0, 180, 0]) screw_hole(DIN963, screw_sz, shaft_depth);
        translate([x_l, body[1] - y_l, body[2]]) rotate([0, 180, 0]) screw_hole(DIN963, screw_sz, shaft_depth);
        translate([x_r, y_l, body[2]]) rotate([0, 180, 0]) screw_hole(DIN963, screw_sz, shaft_depth);
        translate([x_r, body[1] - y_l, body[2]]) rotate([0, 180, 0]) screw_hole(DIN963, screw_sz, shaft_depth);
        translate([x_mid, y_l, body[2]]) rotate([0, 180, 0]) screw_hole(DIN963, screw_sz, shaft_depth);
        translate([x_mid, y_r, body[2]]) rotate([0, 180, 0]) screw_hole(DIN963, screw_sz, shaft_depth);

        /* lid groove */
        translate([wall_thickness, wall_thickness, body[2] - wall_thickness])
        outer_box([body[0] - wall_thickness * 2, body[1] - wall_thickness * 2, wall_thickness]);

        /* pot hole */
        translate(potentiometer) rotate([0, 90, 0]) cylinder(d = pot_diameter, h = wall_thickness);

        /* switch hole */
        translate(pw_switch) cube([wall_thickness, pw_btn_width, pw_btn_height]);

        /* dc power hole */
        translate(pw_connector) rotate([0, 90, 0]) cylinder(d = pw_conn_diameter, h = wall_thickness);

        /* speaker connector */
        translate(spk_connector) speaker_connector(spk_width, spk_height, wall_thickness);

        /* speaker connector cut for lid */
        translate(spk_connector + [0, spk_gutter, spk_height])
        cube([wall_thickness, spk_width - spk_gutter * 2, (body[2] - spk_height) / 2]);
    }
}

// enclosure lid
module enclosure_lid() {

    union() {
        difference() {
            /* lid */
            translate([lid[0] / 2, lid[1] / 2, lid[2] / 2]) roundedBox(lid, 10);

            /* slits */
            union() {
                cell_size = lid_grid_depth + 3;
                grills = floor((lid[0] - (corner_size * 2)) / cell_size);
                for (i = [0:grills]) {
                    translate([i * cell_size + corner_size, corner_size, 0])
                    cube([lid_grid_depth, lid[1] - corner_size * 2, wall_thickness]);
                }
            }

            /* screw holes */
            half_corner = corner_size / 2;
            x_mid = lid[0] / 2;
            translate([half_corner, half_corner, 0]) screw_hole(DIN963, screw_sz, wall_thickness);
            translate([1 + half_corner, lid[1] - half_corner, 0]) screw_hole(DIN963, screw_sz, wall_thickness);
            translate([lid[0] - half_corner, half_corner, 0]) screw_hole(DIN963, screw_sz, wall_thickness);
            translate([lid[0] - half_corner, lid[1] - half_corner, 0]) screw_hole(DIN963, screw_sz, wall_thickness);
            translate([x_mid, half_corner, 0]) screw_hole(DIN963, screw_sz, wall_thickness);
            translate([x_mid, lid[1] - half_corner, 0]) screw_hole(DIN963, screw_sz, wall_thickness);
        }

        /* central block */
        patch = [0, (lid[1] / 2) - (corner_size / 2), 0];
        translate(patch) cube([lid[0], corner_size, wall_thickness]);

        /* speaker connector lid */
        translate([ - wall_thickness, spk_margin_right + spk_gutter - wall_thickness, 0]) cube([wall_thickness, spk_width - spk_gutter * 2, (body[2] - spk_height) / 2 + wall_thickness]);
    }
}

// volume knob
module knob() {
    union() {
        difference() {
            translate([0, 0, 0]) cylinder(d = knob_diameter, h = pot_shaft + wall_thickness + knob_sink);
            translate([0, 0, pot_shaft + wall_thickness]) cylinder(d = knob_diameter - wall_thickness, h = knob_sink);
            translate([0, 0, wall_thickness]) cylinder(d = knob_diameter - wall_thickness, h = pot_shaft);
        }
        difference() {
            translate([0, 0, 0]) cylinder(d = pot_diameter + wall_thickness, h = pot_shaft + wall_thickness);
            translate([0, 0, wall_thickness]) cylinder(d = pot_shaft_diameter, h = pot_shaft);
        }
    }
}

// connector test plate
module test_plate() {
    difference() {
        translate([0, 0, 0]) cube([25, 50, wall_thickness]);
        translate([5, 5, 0]) cube([2, 2, 2]);

        /* pot hole */
        translate([12.5, 10, 0]) cylinder(d = pot_diameter, h = wall_thickness);

        /* switch hole */
        translate([(25 - pw_btn_height)/ 2, 20, 0]) cube([pw_btn_height, pw_btn_width, wall_thickness]);

        /* dc power hole */
        translate([12.5, 40, 0]) cylinder(d = pw_conn_diameter, h = wall_thickness);
    }
}

// ============================================================================
// main
// ============================================================================

if (renderBox) {
    translate([0,0,0]) enclosure();
}

if (renderLid) {
    translate([0,0,0]) enclosure_lid();
}

if (renderKnob) {
    translate([0,0,0]) knob();
}

if (renderTestPlate) {
    translate([0,0,0]) test_plate();
}
