// Easy Button style case for the rev1 single-button board. All white.
//
// Three printable parts: base, button, clamp.
// Origin is the PCB center. +Y is USB. +Z is the button face.
// z = 0 is the outside of the base floor.
//
// OBJ mesh units are 0.254 mm. The PCB is about 40.5 x 43.9 mm and its
// corners sit at r ≈ 28.3 mm. The switch is dead center. The XIAO is on
// the back at the USB end (about y = 2 to 23).
//
// The cell's long side runs along X, same direction as the PCB width.
// outer_r is 32. The board, module, and battery are shifted toward USB
// only as far as that circle allows. The USB cut is a tunnel out through
// the wall.

// Body
outer_r = 31;
// Board and module, toward USB from the switch. The USB end needs wall left.
stack_y = 6;
floor_t = 1.5;
pcb_t = 1.6;
pcb_gap = 0.45;

// Battery
// 38 mm across the PCB width, 25 mm toward the tail of the board, plus wiggle.
battery_x = 38.0;
battery_y = 25.1;
battery_top = -0.01;    // Slight overlap to eliminate the wall between the battery and the module
battery_d = 8;     // under the PCB; 8 mm cell plus clearance

// XIAO
xiao_w = 18.8;
xiao_body_y0 = 0;
xiao_body_y1 = 22.4;
xiao_usb_w = 12.0;
xiao_usb_y1 = 23.3;
xiao_d = 3.5;

// Button
switch_h = 1.8;
tip_gap = 0.35;
tip_d = 4;
tip_straight = 1.6;
travel = 1.0;
flange_r = 26.0;
flange_t = 2.0;
face_r = 23.0;
face_h = 3.4;         // flat top, stands proud of the clamp lip
opening_r = 23.0;     // clamp hole the face passes through

// Clamp
lip_t = 1.8;
screw_r = 27;      // head stays inside outer_r, shaft stays outside the flange
screw_angles = [-210, 270, -330];
screw_clear_d = 3.3;
screw_pilot_d = 3.2;
screw_pilot_h = 8.0;
screw_head_d = 5.4;
screw_head_h = 1.5;

// USB
// Tunnel from the connector (inside the circle) out through the wall.
usb_w = 12.0;
usb_h = 7.0;
usb_drop = 2.35;
usb_y0 = 12;

eps = 0.05;

// --- derived ---
pcb_z = floor_t + battery_d;
pcb_top = pcb_z + pcb_t;
switch_top = pcb_top + switch_h;
tip_rest = switch_top + tip_gap;
seat_z = tip_rest - travel;
lip_z = flange_t + travel;                 // lip underside, relative to the clamp bottom
clamp_h = lip_z + lip_t;
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

module board_2d() {
  translate([0, stack_y])
    polygon(board_pts);
}

module battery_2d() {
  // +Y edge sits battery_top below the module.
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

module base() {
  difference() {
    base_body();
    translate([0, 0, floor_t])
      linear_extrude(battery_d + eps + 10) //extrude all the way out
        battery_2d();
    translate([0, 0, pcb_z - xiao_d])
      linear_extrude(xiao_d + eps)
        xiao_2d();
    translate([0, 0, pcb_z])
      linear_extrude(seat_z - pcb_z + eps)
        offset(delta = pcb_gap) board_2d();
    usb_tunnel();
    wire_notch();
    screw_pilots();
  }
  // pcb_tabs();
}

// Press the board past these. They keep it from falling out when the cap is off.
module pcb_tabs() {
  z0 = pcb_top + 0.35;
  h = 1.3;
  translate([-21.2, stack_y - 5, z0]) cube([1.8, 10, h]);
  translate([19.4, stack_y - 5, z0]) cube([1.8, 10, h]);
  // translate([-6, stack_y - 22.9, z0]) cube([12, 1.8, h]); //3rd tab, lets just exclude for now, maybe later?
}

module usb_tunnel() {
  cz = pcb_z - usb_drop;
  translate([-usb_w / 2, usb_y0 + stack_y, cz - usb_h / 2])
    cube([usb_w, outer_r - (usb_y0 + stack_y) + 2, usb_h]);
}

module wire_notch() {
  translate([13, stack_y - 3, pcb_z - 8])
    cube([6, 15, 8 + eps]);
}

module screw_pilots() {
  for (a = screw_angles)
    rotate([0, 0, a])
      translate([screw_r, 0, seat_z - screw_pilot_h])
        cylinder(d = screw_pilot_d, h = screw_pilot_h + eps);
}

// Outer wall. The bottom edge is a quarter-round of radius rad.
module base_body() {
  rad = 2;
  minkowski() {
    translate([0, 0, rad])
      cylinder(r = outer_r - rad, h = seat_z - rad);
    difference() {
      sphere(r = rad);
      translate([-rad * 2, -rad * 2, 0])
        cube([rad * 4, rad * 4, rad * 2]);
    }
  }
}

module clamp() {
  difference() {
    cylinder(r = outer_r, h = clamp_h);
    // Below the lip the flange has to move.
    translate([0, 0, -eps])
      cylinder(r = flange_clear_r, h = lip_z + eps);
    // Opening the face comes through.
    translate([0, 0, lip_z - eps])
      cylinder(r = opening_r, h = lip_t + 2 * eps);
    screw_clearance();
  }
}

module screw_clearance() {
  for (a = screw_angles)
    rotate([0, 0, a])
      translate([screw_r, 0, 0]) {
        translate([0, 0, -eps])
          cylinder(d = screw_clear_d, h = clamp_h + 2 * eps);
        // Head sits on the top face, the same face as the lip.
        translate([0, 0, clamp_h - screw_head_h])
          cylinder(d = screw_head_d, h = screw_head_h + eps);
      }
}

module button() {
  rad = 0.5;

  minkowski() {
    union() {
      translate([0, 0, tip_rest])
        cylinder(r = flange_r - (rad * 2), h = flange_t - (rad * 2));
      translate([0, 0, tip_rest + flange_t - eps])
        cylinder(r = face_r - (rad * 2), h = face_h - (rad * 2));
      translate([0, 0, tip_rest])
        cylinder(d = tip_d - 2*rad, h = tip_straight - rad + eps);
      translate([0, 0, tip_rest + tip_straight])
        cylinder(d = - 2*rad, h = tip_rest - tip_rest - tip_straight - rad + eps);
    }
    sphere(r = rad);
  }
}

module button_solid() {
  difference() {
    button();
    // led_dots();
  }
}

module led_dots() {
  for (p = [[0, -6.2], [-2.3, -5.4], [2.3, -5.4], [-4.2, -4.0], [4.2, -4.0]])
    translate([p[0], p[1], tip_rest + flange_t + 1.2])
      cylinder(d = 1.5, h = face_h);
}

module pcb_ghost() {
  translate([0, 0, pcb_z])
    linear_extrude(pcb_t)
      board_2d();
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

echo(str("seat ", seat_z, "  clamp ", seat_z, " to ", seat_z + clamp_h));
echo(str("battery ", battery_x, " x ", battery_y, "  top y ", battery_top));
echo(str("outer d ", outer_r * 2, "  face d ", face_r * 2));
