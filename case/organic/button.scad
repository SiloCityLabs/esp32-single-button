// openscad -o models/button.stl button.scad
include <design.scad>

$fn = $preview ? 60 : 200;

$vpr = [65, 0, 0];
$vpt = [0, 0, (seat_z + clamp_h) / 2];
$vpd = 110;

color("#E6E6E6") organic_button();