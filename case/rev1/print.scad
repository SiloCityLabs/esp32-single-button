// The three parts on the bed. Base and clamp match their part files.
// The button is flipped so the flat face is on the bed, sitting below the base.
//   openscad -o print.png print.scad
include <common.scad>
$fn = 48;

gap = 10;
// Flat face of the button, in assembly coordinates.
face_top = flange_bottom_rest + flange_t + face_h - eps;

module base_print() {
  base();
}

module clamp_print() {
  rotate([180, 0, 180])
    translate([0, 0, -clamp_h])
      clamp();
}

module button_print() {
  // Flat face on the bed, stem up.
  rotate([180, 0, 0])
    translate([0, 0, -face_top])
      button_solid();
}

color("grey")
  base_print();

color("grey")
  translate([2 * outer_r + gap, 0, 0])
    clamp_print();

color("red")
  translate([0, -(outer_r + flange_r + gap), 0])
    button_print();
