include <../assets/common.scad>

// ---------------------------------------------------------
// PARAMETERS
// ---------------------------------------------------------

// Fastener locations: 270 deg (rear), 30 deg, 150 deg
organic_screw_angles = [270, 30, 150];

// Button flange pocket clearance radius
clamp_flange_r = is_undef(flange_r) ? (opening_r + 1.8) : (flange_r + 0.5);

// Structural boss diameter for fastener holes
screw_boss_d   = screw_head_d + 2.2;

// ---------------------------------------------------------
// BASE MODULE
// ---------------------------------------------------------

// Cylindrical base core with internal component mounts and fastener pilots
module organic_base() {
  difference() {
    base();

    usb_tunnel();
    wire_notch();

    // Fastener pilot holes at 270, 30, and 150 deg only
    for (a = organic_screw_angles) {
      rotate([0, 0, a])
        translate([screw_r, 0, seat_z - 8.0])
          cylinder(d = screw_clear_d, h = 8.0 + eps, $fn = 24);
    }
  }
}

// ---------------------------------------------------------
// BUTTON MODULE
// ---------------------------------------------------------

// Actuator button with center indicator recess
module organic_button() {
  difference() {
    button_solid();

    // Spherical center pip for light diffuser
    translate([0, 0, seat_z + clamp_h])
      sphere(r = 1.8, $fn = 32);
  }
}

// ---------------------------------------------------------
// CLAMP PLACEHOLDER MODULE
// ---------------------------------------------------------

// Baseline clamp ring holding the button assembly pending outer organic modeling
module organic_clamp() {
  difference() {
    cylinder(r = outer_r, h = clamp_h, $fn = 120);

    // Button central opening
    translate([0, 0, -eps])
      cylinder(r = opening_r, h = clamp_h + 2 * eps, $fn = 80);

    // Underside flange clearance pocket
    difference() {
      translate([0, 0, -eps])
        cylinder(r = clamp_flange_r, h = lip_z + eps, $fn = 80);

      // Preserve full circular wall around screw holes
      for (a = organic_screw_angles) {
        rotate([0, 0, a])
          translate([screw_r, 0, -2 * eps])
            cylinder(d = screw_boss_d, h = lip_z + 4 * eps, $fn = 32);
      }
    }

    // Counterbored fastener holes at 270, 30, and 150 deg
    for (a = organic_screw_angles) {
      rotate([0, 0, a])
        translate([screw_r, 0, 0]) {
          translate([0, 0, clamp_h - screw_head_h])
            cylinder(d = screw_head_d, h = screw_head_h + 5, $fn = 32);

          translate([0, 0, -eps])
            cylinder(d = screw_clear_d, h = clamp_h + 10, $fn = 32);
        }
    }
  }
}