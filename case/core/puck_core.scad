// ============================================================================
// Core Puck Geometry & Electronics Clearances
// Shared by all enclosure variants. Origin is PCB center.
// ============================================================================

// --- Curve Resolution ---
$fn = $preview ? 60 : 200;

// --- Body Dimensions ---
outer_r      = 31.0;
stack_y      = 6.0;
floor_t      = 1.5;
pcb_t        = 1.6;
pcb_gap      = 0.45;

// --- Battery Cavity ---
battery_x    = 38.0;
battery_y    = 25.1;
battery_top  = -0.01;
battery_d    = 8.0;

// --- XIAO RP2040 / ESP32S3 Pocket ---
xiao_w       = 20.0;
xiao_body_y0 = 0.0;
xiao_body_y1 = 22.4;
xiao_usb_w   = 12.0;
xiao_usb_y1  = 23.3;
xiao_d       = 3.5;

// --- Button Mechanics ---
switch_h     = 1.8;
tip_gap      = 0.35;
tip_d        = 4.0;
tip_straight = 1.6;
travel       = 1.0;
flange_r     = 26.0;
flange_t     = 1.25;
face_r       = 23.0;
face_h       = 3.4;
opening_r    = 23.15;

// --- Clamp Hardware & Retaining Lip ---
lip_t          = 1.8;
screw_r        = 27.0;
screw_angles   = [-210, 270, -330];
screw_clear_d  = 3.3;
screw_pilot_d  = 3.0;
screw_pilot_h  = 8.0;
screw_head_d   = 5.4;
screw_head_h   = 1.5;

// --- USB Tunnel ---
usb_w        = 10.0;
usb_h        = 5.0;
usb_drop     = 2.35;
usb_y0       = 12.0;

// --- Overlap Epsilon ---
eps          = 0.05;

// --- Derived Calculations ---
pcb_z          = floor_t + battery_d;
pcb_top        = pcb_z + pcb_t;
switch_top     = pcb_top + switch_h;
tip_rest       = switch_top + tip_gap;
seat_z         = tip_rest - travel;
lip_z          = flange_t + travel;
clamp_h        = lip_z + lip_t;
flange_clear_r = flange_r + 0.55;

board_pts = [
  [-17.78, -21.95],
  [ 17.91, -21.95],
  [ 20.23, -19.55],
  [ 20.18,  10.67],
  [  8.89,  21.95],
  [ -9.02,  21.95],
  [-20.23,  10.67],
  [-20.15, -19.55]
];

// --- 2D Profiles ---
module board_2d() {
  translate([0, stack_y]) polygon(board_pts);
}

module battery_2d() {
  translate([0, stack_y - battery_top - battery_y / 2])
    square([battery_x, battery_y], center = true);
}

module xiao_2d() {
  translate([0, stack_y]) {
    translate([0, (xiao_body_y0 + xiao_body_y1) / 2])
      square([xiao_w, xiao_body_y1 - xiao_body_y0], center = true);
    translate([0, (xiao_body_y1 - 1.2 + xiao_usb_y1) / 2])
      square([xiao_usb_w, xiao_usb_y1 - (xiao_body_y1 - 1.2)], center = true);
  }
}

// --- Negative Subtraction Cutouts ---
module core_cavities() {
  // Battery pocket
  translate([0, 0, floor_t])
    linear_extrude(battery_d + eps + 10)
      battery_2d();

  // XIAO pocket
  translate([0, 0, pcb_z - xiao_d])
    linear_extrude(xiao_d + eps)
      xiao_2d();

  // PCB tray
  translate([0, 0, pcb_z])
    linear_extrude(seat_z - pcb_z + eps)
      offset(delta = pcb_gap) board_2d();

  // USB breakout
  cz = pcb_z - usb_drop;
  translate([-usb_w / 2, usb_y0 + stack_y, cz - usb_h / 2])
    cube([usb_w, outer_r - (usb_y0 + stack_y) + 4, usb_h]);

  // Wire clearance
  translate([13, stack_y - 3, pcb_z - 8])
    cube([6, 15, 8 + eps]);

  // Pilot screw holes
  for (a = screw_angles)
    rotate([0, 0, a])
      translate([screw_r, 0, seat_z - screw_pilot_h])
        cylinder(d = screw_pilot_d, h = screw_pilot_h + eps);
}

// PCB retention tabs (positive feature inside base)
module pcb_tabs() {
  z0 = pcb_top + 0.35;
  h = 0.75;
  translate([-21.6, stack_y - 5, z0]) cube([1.8, 10, h]);
  translate([19.8,  stack_y - 5, z0]) cube([1.8, 10, h]);
}

// Clamp screw pass-throughs
module clamp_screw_cutouts() {
  for (a = screw_angles)
    rotate([0, 0, a])
      translate([screw_r, 0, 0]) {
        translate([0, 0, -eps])
          cylinder(d = screw_clear_d, h = clamp_h + 2 * eps);
        translate([0, 0, clamp_h - screw_head_h])
          cylinder(d = screw_head_d, h = screw_head_h + eps);
      }
}

// Plunger button module
module core_button() {
  difference() {
    union() {
      translate([0, 0, tip_rest])
        cylinder(r = flange_r, h = flange_t);
      translate([0, 0, tip_rest + flange_t - eps])
        cylinder(r = face_r, h = face_h);
      translate([0, 0, tip_rest])
        cylinder(d = tip_d, h = tip_straight + eps);
    }
    translate([0, 0, -5.75])
      cylinder(d = 40, h = 20);
    for (a = screw_angles)
      rotate([0, 0, a])
        translate([screw_r, 0, 0])
          translate([0, 0, -eps])
            cylinder(d = screw_clear_d + 4.5, h = 15);
  }
}

// Assembly ghost components
module pcb_ghost() {
  translate([0, 0, pcb_z]) linear_extrude(pcb_t) board_2d();
}

module battery_ghost() {
  translate([0, 0, floor_t + 0.4])
    linear_extrude(battery_d - 2.2)
      offset(delta = -0.7) battery_2d();
}

module xiao_ghost() {
  translate([0, 0, pcb_z - xiao_d + 0.35])
    linear_extrude(xiao_d - 0.7)
      offset(delta = -0.4) xiao_2d();
}