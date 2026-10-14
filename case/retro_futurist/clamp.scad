// Perimeter ring. Holds the cap by its rim.
// Oriented lip-down on the bed. No supports.
// openscad -o models/clamp.stl clamp.scad
include <design.scad>

$fn = $preview ? 60 : 200;

rotate([180, 0, 0])
  translate([0, 0, -clamp_h])
    retro_clamp();