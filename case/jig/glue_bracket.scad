// Assembly / gluing bracket for the rev1 single-button board and battery.
// Print floor-down. No supports.
//   openscad -o glue_bracket.stl glue_bracket.scad

include <../assets/common.scad>

/* [Preview / Rendering] */
$fn = $preview ? 48 : 120;

/* [Bracket Options] */
// Solid outer radius (matches base outer_r by default)
bracket_outer_r = outer_r;
// Include USB cutout for connector clearance / test plugging
include_usb_tunnel = true;
// Keep snap-in PCB retention tabs while glue/tape sets
include_pcb_tabs = true;
// Optional bottom push-out hole diameter under the battery (0 = solid floor)
push_hole_d = 0;

/* [Wire Channel] */
// Matches wire_notch() X/Y start in common.scad, extended through the +Y wall and top face
wire_slot_x = 13.0;
wire_slot_y = stack_y - 3.0;
wire_slot_w = 6.0;

module glue_bracket_body() {
  // Plain solid cylinder with flat bottom for maximum bed adhesion
  cylinder(r = bracket_outer_r, h = seat_z);
}

module extended_wire_slot() {
  slot_len = bracket_outer_r - wire_slot_y + 5.0;
  slot_h   = seat_z - floor_t + eps;
  translate([wire_slot_x, wire_slot_y, floor_t])
    cube([wire_slot_w, slot_len, slot_h]);
}

module battery_push_hole() {
  if (push_hole_d > 0) {
    translate([0, stack_y - battery_top - battery_y / 2, -eps])
      cylinder(d = push_hole_d, h = floor_t + 2 * eps, $fn = 36);
  }
}

module glue_bracket() {
  difference() {
    glue_bracket_body();

    // Battery pocket
    translate([0, 0, floor_t])
      linear_extrude(battery_d + eps + 10)
        battery_2d();

    // XIAO module recess beneath PCB
    translate([0, 0, pcb_z - xiao_d])
      linear_extrude(xiao_d + eps)
        offset(delta = xiao_gap) xiao_2d();

    // PCB cavity
    translate([0, 0, pcb_z])
      linear_extrude(seat_z - pcb_z + eps)
        offset(delta = pcb_gap) board_2d();

    // Extended battery wire channel (+Y through outer wall, open to top face)
    extended_wire_slot();

    // Optional USB-C tunnel clearance
    if (include_usb_tunnel)
      usb_tunnel();

    // Optional bottom push-out hole
    battery_push_hole();
  }

  if (include_pcb_tabs)
    pcb_tabs();
}

glue_bracket();
