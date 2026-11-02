// Center cap. Printed face down on the bed (no supports needed).
// openscad -o models/button.stl button.scad
include <design.scad>

$fn = $preview ? 60 : 200;

button_total_h = flange_t - eps + face_h;

translate([0, 0, button_total_h])
  rotate([0, 180, 0])
    translate([0, 0, -tip_rest])
      retro_button();
