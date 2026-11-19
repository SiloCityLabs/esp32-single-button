include <design.scad>

$fn = $preview ? 60 : 200;

gap = 10;
face_top = tip_rest + flange_t + face_h - eps;

module base_print() { rugged_base(); }
module clamp_print() { rugged_clamp(); } // Underside sits directly on the bed
module button_print() {
  rotate([180, 0, 0])
    translate([0, 0, -face_top])
      rugged_button();
}

color("#C02026") base_print();
color("#C02026") translate([2 * outer_r + gap, 0, 0]) clamp_print();
color("#1E1E1E") translate([0, -(outer_r + flange_r + gap), 0]) button_print();