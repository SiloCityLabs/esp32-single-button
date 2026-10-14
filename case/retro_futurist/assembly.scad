// Stacked preview. Not a printable part.
//   openscad -D 'cutaway=true' -o assembly.png assembly.scad
include <design.scad>

// --- View & Render Controls ---
cutaway    = false;
show_board = true;
view_usb   = true;  // Set true to orient the USB-C port front and center

// Resolution: 60 for F5 interactive preview, 200 for F6 CGAL compile
$fn = $preview ? 60 : 200;

// Camera position
$vpr = [65, 0, 0];
$vpt = [0, 0, seat_z / 2];
$vpd = 150;

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

// Physically rotate model 180 degrees when view_usb=true so port faces forward
rotate([0, 0, view_usb ? 180 : 0]) {
  if (cutaway)
    difference() {
      stacked();
      translate([-80, 0, -5]) cube([80, 120, 80]);
    }
  else
    stacked();
}