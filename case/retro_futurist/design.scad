include <../assets/common.scad>

// ---------------------------------------------------------
// RETRO FUTURIST STYLING
// ---------------------------------------------------------

module retro_base() {
  difference() {
    base();

    // Vertical pill vents around the base perimeter only
    retro_vents(z_start = 4, z_height = seat_z - 8);
  }
}

module retro_clamp() {
  difference() {
    clamp();

    // Concentric U-grooves on the top face only (sides remain solid)
    retro_top_ribs();
  }
}

module retro_button() {
  button_solid();
}

// ---------------------------------------------------------
// STYLING TOOLS
// ---------------------------------------------------------

module retro_vents(z_start, z_height) {
  vent_count = 36;
  vent_w = 2.0;
  cut_depth = 1.2;

  for (i = [0 : vent_count - 1]) {
    angle = i * (360 / vent_count);

    // Skip cutting over the USB tunnel (70 to 110 degrees)
    if (!(angle > 70 && angle < 110)) {
      rotate([0, 0, angle])
        translate([outer_r - cut_depth, 0, z_start + z_height/2])
          hull() {
            translate([0, 0, z_height/2 - vent_w/2])
              rotate([0, 90, 0]) cylinder(d=vent_w, h=cut_depth + eps * 2, $fn=20);
            translate([0, 0, -(z_height/2 - vent_w/2)])
              rotate([0, 90, 0]) cylinder(d=vent_w, h=cut_depth + eps * 2, $fn=20);
          }
    }
  }
}

module retro_top_ribs() {
  rib_count = 5;
  rib_spacing = 1.4;
  start_r = opening_r + 1.2;

  for (i = [0 : rib_count - 1]) {
    r = start_r + (i * rib_spacing);
    if (r < outer_r - 1) {
      translate([0, 0, clamp_h])
        rotate_extrude($fn=120)
          translate([r, 0, 0])
            circle(d=0.8, $fn=20);
    }
  }
}