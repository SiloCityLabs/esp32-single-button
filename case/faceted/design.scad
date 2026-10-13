include <../assets/common.scad>

// ---------------------------------------------------------
// FACETED PARAMETERS ($fn=8)
// ---------------------------------------------------------

oct_r = outer_r / cos(180 / 8); // Circumscribed radius so inner wall clearance is preserved

// ---------------------------------------------------------
// BASE
// ---------------------------------------------------------

module faceted_base_body() {
  // Octagonal base with a clean bottom 45-degree chamfer
  chamfer_h = 1.6;
  hull() {
    translate([0, 0, 0])
      cylinder(r = oct_r - chamfer_h, h = eps, $fn = 8);
    translate([0, 0, chamfer_h])
      cylinder(r = oct_r, h = eps, $fn = 8);
    translate([0, 0, seat_z])
      cylinder(r = oct_r, h = eps, $fn = 8);
  }
}

module faceted_base() {
  difference() {
    faceted_base_body();

    // Internal cavities from common.scad
    translate([0, 0, floor_t])
      linear_extrude(battery_d + eps + 10)
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
  pcb_tabs();
}

// ---------------------------------------------------------
// CLAMP
// ---------------------------------------------------------

module faceted_clamp_body() {
  // Chamfered / low-poly faceted top ring
  // Slopes down from the inner circular opening to the octagonal perimeter
  bevel_drop = 1.8;

  hull() {
    // Outer perimeter octagon at clamp baseline
    translate([0, 0, 0])
      cylinder(r = oct_r, h = clamp_h - bevel_drop, $fn = 8);

    // Inner rim apex circle surrounding the button opening
    translate([0, 0, clamp_h - eps])
      cylinder(r = opening_r + 1.2, h = eps, $fn = 16);
  }
}

module faceted_clamp() {
  difference() {
    faceted_clamp_body();

    // Flange movement cavity
    translate([0, 0, -eps])
      difference() {
        cylinder(r = flange_clear_r, h = lip_z + eps);
        for (a = screw_angles)
          rotate([0, 0, a])
            translate([screw_r, 0, 0])
              translate([0, 0, -eps])
                cylinder(d = screw_clear_d + 4, h = clamp_h);
      }

    // Circular button pass-through opening
    translate([0, 0, lip_z - eps])
      cylinder(r = opening_r, h = lip_t + 2 * eps);

    // Screw clearance bores
    screw_clearance();
  }
}

// ---------------------------------------------------------
// BUTTON
// ---------------------------------------------------------

module faceted_button() {
  button_solid();
}