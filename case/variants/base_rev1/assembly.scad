include <../../core/puck_core.scad>
use <base.scad>
use <clamp.scad>

cutaway = false;
show_board = true;

module stacked() {
  color("white") base();
  color("ghostwhite") translate([0, 0, seat_z]) rotate([180, 0, 0]) translate([0, 0, -clamp_h]) clamp();
  color("ivory") core_button();
  if (show_board) {
    color("darkgreen", 0.35) pcb_ghost();
    color("dimgray", 0.4)    xiao_ghost();
    color("olive", 0.4)      battery_ghost();
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