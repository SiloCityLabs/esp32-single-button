// Stacked preview. Not a printable part.
// openscad -D 'cutaway=true' -o assembly.png assembly.scad
include <design.scad>

// --- View & Render Controls ---
cutaway     = false;
show_board  = true;
view_usb    = true;
exploded    = false;
explode_gap = 18;

$fn = $preview ? 60 : 200;

$vpr = [65, 0, 0];
$vpt = [0, 0, seat_z / 2 + (exploded ? explode_gap : 0)];
$vpd = exploded ? 240 : 150;

module stacked() {
  exp_board = exploded ? explode_gap * 0.75 : 0;
  exp_btn   = exploded ? explode_gap * 1.50 : 0;
  exp_clamp = exploded ? explode_gap * 2.25 : 0;

  // 1. Base (Two-tone)
  rugged_base_colored();

  // 2. Electronics ghost
  if (show_board) {
    translate([0, 0, exp_board]) {
      color("darkgreen", 0.35) pcb_ghost();
      color("dimgray", 0.4) xiao_ghost();
      color("olive", 0.4) battery_ghost();
    }
  }

  // 3. Button Actuator
  translate([0, 0, exp_btn]) {
    color("#141414") rugged_button();
    color("#FF2020") translate([0, 0, seat_z + clamp_h + 0.1]) cylinder(r = 1.8, h = 0.5, $fn = 24);
  }

  // 4. Clamp (Two-tone elevated)
  translate([0, 0, seat_z + exp_clamp]) {
    rugged_clamp_colored();
  }
}

rotate([0, 0, view_usb ? 180 : 0]) {
  if (cutaway)
    difference() {
      stacked();
      translate([-80, 0, -5]) cube([80, 120, 120]);
    }
  else
    stacked();
}