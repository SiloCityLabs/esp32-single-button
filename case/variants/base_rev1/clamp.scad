include <../../core/puck_core.scad>

module clamp() {
  difference() {
    cylinder(r = outer_r, h = clamp_h);

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

    // Center hole for button face
    translate([0, 0, lip_z - eps])
      cylinder(r = opening_r, h = lip_t + 2 * eps);

    clamp_screw_cutouts();
  }
}

rotate([180, 0, 0])
  translate([0, 0, -clamp_h])
    clamp();