// Perimeter ring. Holds the cap by its rim.
// Flat underside sits directly on the bed; tapered top face points up. No supports needed.
// openscad -o models/clamp.stl clamp.scad
include <design.scad>

$fn = $preview ? 60 : 200;

retro_clamp();
