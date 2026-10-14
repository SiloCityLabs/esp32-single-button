// Perimeter ring. Holds the cap by its rim.
// Oriented lip-down on the bed. No supports.
// openscad -o models/clamp.stl clamp.scad
include <design.scad>

$fn = $preview ? 60 : 200;

faceted_clamp();