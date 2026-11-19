// Perimeter ring. Holds the cap by its rim.
// Flat underside sits directly on bed; elevated crowns point up. No supports needed.
// openscad -o models/clamp.stl clamp.scad
include <design.scad>

$fn = $preview ? 60 : 200;

$vpr = [65, 0, 180];
$vpt = [0, 0, clamp_h / 2];
$vpd = 140;

if ($preview) {
  rugged_clamp_colored();
} else {
  rugged_clamp();
}