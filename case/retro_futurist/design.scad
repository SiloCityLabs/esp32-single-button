include <../assets/common.scad>

// ---------------------------------------------------------
// RETRO FUTURIST STYLING
// ---------------------------------------------------------

module retro_base() {
  difference() {
    base();

    // Centered on the visible vertical flat face between fillet and parting line
    retro_vents(slot_len = 6.5, z_center = (seat_z + 2.0) / 2);
  }
}

module retro_clamp() {
  difference() {
    clamp();

    // Soft round-over on top outer perimeter edge
    clamp_top_edge_fillet(r = 1.2);

    // Balanced split-depth concentric ribs
    retro_top_ribs();
  }
}

module retro_button() {
  button_solid();
}

// ---------------------------------------------------------
// STYLING TOOLS
// ---------------------------------------------------------

module retro_vents(slot_len = 6.5, z_center = 7.125) {
  vent_count  = 36;
  vent_w      = 1.8;
  cut_depth   = 1.2;
  half_travel = (slot_len - vent_w) / 2;

  for (i = [0 : vent_count - 1]) {
    angle = i * (360 / vent_count);

    // Skip cutting over the USB tunnel (70 to 110 degrees)
    if (!(angle > 70 && angle < 110)) {
      rotate([0, 0, angle])
        translate([outer_r - cut_depth, 0, z_center])
          hull() {
            translate([0, 0, half_travel])
              rotate([0, 90, 0])
                cylinder(d = vent_w, h = cut_depth + eps * 2, $fn = 24);
            translate([0, 0, -half_travel])
              rotate([0, 90, 0])
                cylinder(d = vent_w, h = cut_depth + eps * 2, $fn = 24);
          }
    }
  }
}

module clamp_top_edge_fillet(r = 1.2) {
  // Fillet cutter removing the sharp outer corner at clamp_h
  translate([0, 0, clamp_h])
    rotate_extrude($fn = 160)
      translate([outer_r, 0, 0])
        difference() {
          translate([-r - eps, -r - eps, 0])
            square([r + 2 * eps, r + 2 * eps]);
          translate([-r, -r, 0])
            circle(r = r, $fn = 32);
        }
}

module retro_top_ribs() {
  rib_count   = 5;
  rib_spacing = 1.35;
  start_r     = opening_r + 1.2;
  groove_d    = 0.60; // Split difference depth (between 0.40 and 0.85)
  groove_w    = 0.95; // Balanced width

  for (i = [0 : rib_count - 1]) {
    r = start_r + (i * rib_spacing);
    // Ensure grooves stay clear of the outer corner fillet
    if (r < outer_r - 1.2 - groove_w) {
      translate([0, 0, clamp_h])
        rotate_extrude($fn = 160)
          translate([r, 0, 0])
            hull() {
              translate([0, eps, 0])
                square([groove_w, eps * 2], center = true);
              translate([0, -groove_d + (groove_w / 4), 0])
                circle(d = groove_w / 2, $fn = 16);
            }
    }
  }
}