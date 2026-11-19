// The three parts on the bed. Base and clamp match their part files.
// The button is flipped so the flat face is on the bed, sitting below the base.
// openscad -o models/print.3mf print.scad
include <design.scad>

$fn = $preview ? 60 : 200;

gap = 10;
face_top = tip_rest + flange_t + face_h - eps;

module base_print() {
  faceted_base();
}

module clamp_print() {
  // Flat mating interface sits directly on the bed, facets point upward
  faceted_clamp();
}

module button_print() {
  rotate([180, 0, 0])
    translate([0, 0, -face_top])
      faceted_button();
}

color("#2B2B2B") base_print();
color("#3C3C3C") translate([2 * outer_r + gap, 0, 0]) clamp_print();
color("#1E1E1E") translate([0, -(outer_r + flange_r + gap), 0]) button_print();