// openscad -o models/base.stl base.scad
include <design.scad>

$fn = $preview ? 60 : 200;

// Camera aimed front and center at the USB-C post (+Y)
$vpr = [65, 0, 180];
$vpt = [0, 0, seat_z / 2];
$vpd = 150;

if ($preview) {
  rugged_base_colored();
} else {
  rugged_base();
}