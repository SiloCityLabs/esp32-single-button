// openscad -o models/base.stl base.scad
include <design.scad>

$fn = $preview ? 60 : 200;

$vpr = [65, 0, 180];
$vpt = [0, 0, seat_z / 2];
$vpd = 150;

color("#2A2A2A") organic_base();