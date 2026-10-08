// Stacked preview. Not a printable part.
//   openscad -D 'cutaway=true' -o assembly.png assembly.scad
include <common.scad>

cutaway = false;
show_board = true;

$fn = 60;

module stacked() {
  color("white") base();
  color("ghostwhite") translate([0, 0, seat_z]) clamp();
  color("ivory") button_solid();
  if (show_board) {
    color("darkgreen", 0.35) pcb_ghost();
    color("dimgray", 0.4) xiao_ghost();
    color("olive", 0.4) battery_ghost();
  }
}

if (cutaway)
  color("grey")
    difference() {
      stacked();
      translate([-80, 0, -5]) cube([80, 120, 80]);
    }
else
  color("grey")
    stacked();
