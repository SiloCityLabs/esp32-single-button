// Stacked preview. Not a printable part.
//   openscad -D 'cutaway=true' -o assembly.png assembly.scad
include <design.scad>

cutaway = false;
show_board = true;

$fn = 60;

module stacked() {
  color("#E78EA5") retro_base();
  color("#F2A6B8") translate([0, 0, seat_z]) retro_clamp();
  color("#4A4A4A") retro_button();
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
  stacked();