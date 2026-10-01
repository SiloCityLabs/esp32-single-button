// Perimeter ring. Holds the cap by its rim.
// Oriented lip-down on the bed. No supports.
//   openscad -o clamp.stl clamp.scad
include <common.scad>
$fn = 64;

rotate([180, 0, 0])
  translate([0, 0, -clamp_h])
    clamp();
