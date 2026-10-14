// Stacked preview. Not a printable part.
//   openscad -D 'cutaway=true' -o assembly.png assembly.scad
include <design.scad>

// --- View & Render Controls ---
cutaway     = false;
show_board  = true;
view_usb    = true;
exploded    = true; // Set true to see exploded component stack
explode_gap = 18;    // Vertical offset step (mm)

$fn = $preview ? 60 : 200;

// Camera configuration adapts dynamically when exploded
$vpr = [65, 0, 0];
$vpt = [0, 0, seat_z / 2 + (exploded ? explode_gap : 0)];
$vpd = exploded ? 240 : 150;

module stacked() {
  exp_board = exploded ? explode_gap * 0.75 : 0;
  exp_btn   = exploded ? explode_gap * 1.50 : 0;
  exp_clamp = exploded ? explode_gap * 2.25 : 0;

  // 1. Base (Ground level Z=0)
  color("#C02026") rugged_base_red();
  color("#1E1E1E") rugged_base_black();

  // 2. Internal board ghosts
  if (show_board) {
    translate([0, 0, exp_board]) {
      color("darkgreen", 0.35) pcb_ghost();
      color("dimgray", 0.4) xiao_ghost();
      color("olive", 0.4) battery_ghost();
    }
  }

  // 3. Button actuator
  translate([0, 0, exp_btn]) {
    color("#141414") rugged_button();
    color("#FF2020") translate([0, 0, seat_z + clamp_h + 0.1]) cylinder(r = 1.8, h = 0.5, $fn = 24);
  }

  // 4. Top Clamp
  translate([0, 0, seat_z + exp_clamp]) {
    color("#C02026") rugged_clamp_red();
    color("#1E1E1E") rugged_clamp_black();
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