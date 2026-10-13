include <../../core/puck_core.scad>
use <base.scad>
use <clamp.scad>

gap = 10;
face_top = tip_rest + flange_t + face_h - eps;

// Base
color("grey") base();

// Clamp (bed orientation)
color("grey")
  translate([2 * outer_r + gap, 0, 0])
    rotate([0, 0, 180])
      clamp();

// Button (face on bed)
color("red")
  translate([0, -(outer_r + flange_r + gap), 0])
    rotate([180, 0, 0])
      translate([0, 0, -face_top])
        core_button();