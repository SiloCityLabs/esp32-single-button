// Laid out flat for single-plate printing
// openscad -o models/print.stl print.scad
include <design.scad>

$fn = $preview ? 60 : 200;

color("#E6E6E6") organic_base();

translate([outer_r * 2 + 15, 0, 0])
  color("#E6E6E6") organic_clamp();

translate([0, outer_r * 2 + 15, 0])
  color("#141414") organic_button();