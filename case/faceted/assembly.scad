// openscad -D 'cutaway=true' -o assembly.png assembly.scad
include <design.scad>

cutaway = false;
show_board = true;

$fn = 60;

module stacked() {
  color("#4CBB17") faceted_base();
  color("#3C3C3C") translate([0, 0, seat_z]) faceted_clamp();
  color("#1E1E1E") faceted_button();
  if (show_board) {
    color("darkgreen", 0.35) pcb_ghost();
    color("dimgray", 0.4) xiao_ghost();
    color("olive", 0.4) battery_ghost();
  }
}

if (cutaway)
  difference() {
    stacked();
    translate([-80, 0, -5]) cube([80, 120, 80]);
  }
else
  stacked();