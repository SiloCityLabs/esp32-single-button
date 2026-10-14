// Circular base. Print floor-down. No supports.
// openscad -o models/base.stl base.scad
include <design.scad>

$fn = $preview ? 60 : 200;

faceted_base();
