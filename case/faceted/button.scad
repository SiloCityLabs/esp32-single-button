// Center cap. Stem tip on the bed, flat face up.
// The flange is wider than the stem: turn on supports from the build plate only.
//   openscad -o models/button.stl button.scad
include <design.scad>

$fn = $preview ? 60 : 200;

translate([0, 0, -tip_rest])
  faceted_button();
