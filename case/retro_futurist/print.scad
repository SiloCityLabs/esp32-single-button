// The three parts on the bed. Base and clamp match their part files.
// The button is flipped so the flat face is on the bed, sitting below the base.
// openscad -o models/print.3mf print.scad
include <design.scad>

$fn = $preview ? 60 : 200;

gap = 10;
// Flat face of the button, in assembly coordinates.
face_top = tip_rest + flange_t + face_h - eps;

module base_print() {
  retro_base();
}

module clamp_print() {
  rotate([180, 0, 180])
    translate([0, 0, -clamp_h])
      retro_clamp();
}

module button_print() {
  // Flat face on the bed, stem up.
  rotate([180, 0, 0])
    translate([0, 0, -face_top])
      retro_button();
}

color("grey")
  base_print();

color("grey")
  translate([2 * outer_r + gap, 0, 0])
    clamp_print();

color("red")
  translate([0, -(outer_r + flange_r + gap), 0])
    button_print();