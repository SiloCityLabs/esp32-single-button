// Center cap. Stem tip on the bed, flat face up.
// The flange is wider than the stem: turn on supports from the build plate only.
//   openscad -o button.stl button.scad
include <common.scad>
$fn = 64;

translate([0, 0, -tip_rest])
  button_solid();
