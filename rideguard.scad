// ============================================================
//  RideGuard — mini fall-alert SOS device for cyclists
//  Parametric enclosure · printable · units in mm
//
//  Features modelled:
//   - Rounded shell, hollow, opens at the back (lid)
//   - Front: recessed CANCEL button + status LED hole
//   - Back lid: embossed logo, SIM slide-door, USB-C charge slot,
//     buzzer holes
//   - Side rail channel for a velcro/strap bike mount
//
//  Print (PLA, 0.2 mm layers, no supports needed):
//   shell  — front face down, opening up
//   lid    — flat, embossed side up
//   button — cap down
//   sim_door — flat
// ============================================================

/* [Render] */
// Which part to render
part = "assembly"; // [assembly, shell, lid, button, sim_door, all_parts]

/* [Body] */
body_w = 45;      // width  (x)
body_l = 35;      // length (y)
body_t = 18;      // thickness (z)
corner_r = 8;     // corner rounding
wall = 2.4;       // wall thickness

/* [Button] */
button_hole_d = 12;   // hole in front face
button_cap_d = 15;    // outer cap diameter

/* [Features] */
led_d = 3;            // status LED hole diameter
strap_gap = 2.6;      // channel width for strap
rail_t = 3;           // side rail thickness
rail_len = 16;        // side rail length (y)
sim_door_w = 20;      // SIM slide door width  (x)
sim_door_l = 15;      // SIM slide door length (y)
usb_slot_w = 9;       // USB-C slot width
usb_slot_h = 3.6;     // USB-C slot height
emboss = true;        // emboss logo text on lid

$fn = 48;
eps = 0.01;

// ------------------------------------------------------------
// Helpers
// ------------------------------------------------------------
// Rounded slab, centred in x/y, z from 0 to t
module rounded_slab(w, l, t, r) {
    hull()
        for (sx = [-1, 1], sy = [-1, 1], sz = [0, 1])
            translate([sx * (w / 2 - r), sy * (l / 2 - r), sz == 0 ? r : t - r])
                sphere(r);
}

module slot(w, l, t) { // rounded-end slot through z, centred
    hull()
        for (sx = [-1, 1])
            translate([sx * (w / 2 - l / 2 > 0 ? w / 2 - l / 2 : 0), 0, 0])
                cylinder(d = min(w, l), h = t, center = true);
}

// ------------------------------------------------------------
// Shell (front face at z=0, opening at z=body_t)
// ------------------------------------------------------------
module screw_post_positions() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * (body_w / 2 - wall - 4), sy * (body_l / 2 - wall - 4), 0])
            children();
}

module shell() {
    difference() {
        rounded_slab(body_w, body_l, body_t, corner_r);

        // hollow interior, open at the back
        translate([0, 0, wall])
            rounded_slab(body_w - 2 * wall, body_l - 2 * wall,
                         body_t, max(corner_r - wall, 2));

        // front face: cancel button hole (recessed ring handled below)
        translate([0, -6, -eps])
            cylinder(d = button_hole_d, h = wall + 2 * eps);

        // front face: LED hole
        translate([0, 9, -eps])
            cylinder(d = led_d, h = wall + 2 * eps);

        // side rail channel gaps: open through both x walls (top & bottom)
        // (channel is formed by the rails added outside; nothing to cut)

        // screw posts inside
        screw_post_positions() cylinder(d = 6, h = body_t);
    }

    // recessed bezel ring around the button
    translate([0, -6, 0])
        difference() {
            cylinder(d = button_hole_d + 6, h = 1.2);
            translate([0, 0, -eps]) cylinder(d = button_hole_d, h = 1.2 + 2 * eps);
        }

    // screw posts (added, not subtracted)
    screw_post_positions()
        difference() {
            cylinder(d = 6, h = body_t - wall);
            translate([0, 0, -eps]) cylinder(d = 2.2, h = body_t);
        }

    // side rails with strap channel
    for (sx = [-1, 1]) rail_assembly(sx);
}

module rail_assembly(sx) {
    x_inner = sx * (body_w / 2);          // shell side wall
    x_rail0 = x_inner + sx * strap_gap;   // rail inner face
    // rail wall (parallel to shell side, full height)
    translate([x_rail0 + sx * rail_t / 2, 0, body_t / 2])
        cube([rail_t, rail_len, body_t], center = true);
    // end tabs connecting rail to shell
    for (sy = [-1, 1])
        translate([x_inner + sx * (strap_gap / 2 + 0.5),
                   sy * (rail_len / 2 - 2.5), 4])
            cube([strap_gap + 1, 5, 8], center = true);
}

// ------------------------------------------------------------
// Lid (back panel) — printed flat, embossed side up
// ------------------------------------------------------------
lid_t = 2.4;

module lid() {
    lw = body_w - 2 * wall - 0.4;  // fits inside shell with clearance
    ll = body_l - 2 * wall - 0.4;
    lr = max(corner_r - wall - 0.2, 2);

    difference() {
        rounded_slab(lw, ll, lid_t, lr);

        // screw clearance holes (match shell posts)
        screw_post_positions() cylinder(d = 2.6, h = lid_t + 2);

        // USB-C charge slot near bottom edge
        translate([0, -ll / 2 + 6, -eps])
            cube([usb_slot_w, usb_slot_h, lid_t + 2 * eps], center = false)
                ;
        translate([0, -ll / 2 + 6, -eps])
            cube([usb_slot_w, usb_slot_h, lid_t + 2 * eps]);

        // buzzer holes (3x3 grid)
        for (ix = [-1, 0, 1], iy = [-1, 0, 1])
            translate([ix * 4, ll / 2 - 8 + iy * 4, -eps])
                cylinder(d = 2, h = lid_t + 2);
    }

    // SIM slide-door rails (two small guide ridges)
    for (sy = [-1, 1])
        translate([0, sy * (sim_door_l / 2 + 0.6), lid_t])
            cube([sim_door_w + 4, 1.2, 1.2], center = true);

    // embossed logo
    if (emboss)
        translate([0, 4, lid_t - eps])
            linear_extrude(0.6)
                text("RideGuard", size = 6, halign = "center",
                     valign = "center", font = "Liberation Sans:style=Bold");

    if (emboss)
        translate([0, -3.5, lid_t - eps])
            linear_extrude(0.5)
                text("SOS  ·  GPS  ·  SIM", size = 3, halign = "center",
                     valign = "center", font = "Liberation Sans");
}

// ------------------------------------------------------------
// Cancel button plunger — printed cap-down
// ------------------------------------------------------------
module button() {
    // cap (outer, domed slightly via hull)
    hull() {
        cylinder(d = button_cap_d, h = 1.4);
        translate([0, 0, 0.4]) cylinder(d = button_cap_d - 1.5, h = 1.6);
    }
    // retention flange (sits inside shell, behind the face)
    translate([0, 0, 1.6]) cylinder(d = button_hole_d + 3.6, h = 1);
    // stem towards the tactile switch on the PCB
    translate([0, 0, 2.6]) cylinder(d = button_hole_d - 3.5, h = wall + 3);
}

// ------------------------------------------------------------
// SIM slide door — printed flat
// ------------------------------------------------------------
module sim_door() {
    cube([sim_door_w, sim_door_l, 1.6], center = true);
    // finger notch grip
    translate([sim_door_w / 2 - 2.5, 0, 0])
        cylinder(d = 4, h = 2.6, center = true, $fn = 24);
    // visual "SIM" engraving
    translate([0, 0, 0.8])
        linear_extrude(0.4)
            text("SIM", size = 5, halign = "center", valign = "center",
                 font = "Liberation Sans:style=Bold");
}

// ------------------------------------------------------------
// Assembly (exploded view for presentation)
// ------------------------------------------------------------
module assembly() {
    color("DimGray") shell();
    translate([0, 0, body_t + 14]) color("FireBrick") lid();
    translate([0, -6, -6]) color("Crimson") rotate([180, 0, 0]) button();
    translate([0, body_l / 2 + 16, body_t / 2])
        color("Black") rotate([90, 0, 90]) sim_door();
}

// ------------------------------------------------------------
// Top-level render selection
// ------------------------------------------------------------
if (part == "shell") shell();
else if (part == "lid") rotate([180, 0, 0]) lid();
else if (part == "button") button();
else if (part == "sim_door") sim_door();
else if (part == "all_parts") {
    // laid out for a single build plate
    shell();
    translate([0, body_l / 2 + 25, 0]) rotate([180, 0, 0]) lid();
    translate([0, -body_l / 2 - 20, 0]) button();
    translate([-body_w / 2 - 18, 0, 0]) sim_door();
}
else assembly();

echo(str("Shell footprint: ", body_w, " x ", body_l, " x ", body_t, " mm"));
