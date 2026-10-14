include <../assets/common.scad>

// ---------------------------------------------------------
// RUGGED VARIANT PARAMETERS (6-POST BASE)
// ---------------------------------------------------------

num_posts       = 6;
post_step       = 360 / num_posts;       // 60 deg between posts
post_span       = 24;                    // Angular width of red posts (deg)
panel_span      = post_step - post_span; // 36 deg for black panels
post_protrusion = 1.4;                   // Protrudes 1.4mm past outer_r

half_post_ang   = post_span / 2;         // 12 deg
half_panel_ang  = panel_span / 2;        // 18 deg

// Screws: Starts at back (270 deg) and alternates every other post. No screw in USB (90 deg)
rugged_screw_angles = [270, 30, 150];

// ---------------------------------------------------------
// 1. BASE MODULE
// ---------------------------------------------------------

// Smooth pill groove along a cylindrical arc
module panel_arc_groove(z, ang_span = 21.6) {
  half = ang_span / 2;
  union() {
    rotate([0, 0, -half])
      rotate_extrude(angle = ang_span, $fn = 80)
        translate([outer_r - 0.4, z])
          circle(d = 1.2, $fn = 16);

    // Rounded left cap
    rotate([0, 0, -half])
      translate([outer_r - 0.4, 0, z])
        sphere(d = 1.2, $fn = 16);

    // Rounded right cap
    rotate([0, 0, half])
      translate([outer_r - 0.4, 0, z])
        sphere(d = 1.2, $fn = 16);
  }
}

// 3 evenly spaced horizontal lines centered vertically and horizontally at 60% panel width
module base_horizontal_lines() {
  z_mid  = (2.0 + seat_z) / 2; // 7.125 mm
  z_step = 2.2;                // Vertical center-to-center spacing
  arc_w  = panel_span * 0.60;  // Exactly 60% width (~21.6 deg)

  for (i = [0 : num_posts - 1]) {
    ang = 90 + 30 + i * post_step; // Centered in the 6 panels: 120, 180, 240, 300, 0, 60 deg
    rotate([0, 0, ang]) {
      panel_arc_groove(z = z_mid + z_step, ang_span = arc_w); // Top line (9.325 mm)
      panel_arc_groove(z = z_mid,          ang_span = arc_w); // Middle line (7.125 mm)
      panel_arc_groove(z = z_mid - z_step, ang_span = arc_w); // Bottom line (4.925 mm)
    }
  }
}

// 6 Outer Armor Posts
module rugged_posts(overlap = 0) {
  r_post  = outer_r + post_protrusion;
  r_start = outer_r - overlap;

  difference() {
    union() {
      for (i = [0 : num_posts - 1]) {
        ang = 90 + i * post_step;
        rotate([0, 0, ang - half_post_ang])
          rotate_extrude(angle = post_span, $fn = 80)
            polygon([
              [r_start,       0],
              [r_post - 2.0,  0],
              [r_post,        2.0],
              [r_post,        seat_z],
              [r_start,       seat_z]
            ]);
      }
    }
    // Cut pass-through for the 90 deg USB-C front post
    usb_tunnel();
  }
}

// Black base core with internal features and panel grooves
module rugged_base_black() {
  difference() {
    union() {
      base();
      // Seal inherited screw holes at 90, 210, and 330 so they remain completely solid
      for (a = [90, 210, 330]) {
        rotate([0, 0, a])
          translate([screw_r, 0, seat_z - 8.0])
            cylinder(d = screw_clear_d + 1.2, h = 8.0 + eps, $fn = 24);
      }
    }

    usb_tunnel();
    wire_notch();
    base_horizontal_lines();

    // Screw holes for the 3 active fasteners ONLY (270 back, 30, 150)
    for (a = rugged_screw_angles) {
      rotate([0, 0, a])
        translate([screw_r, 0, seat_z - 8.0])
          cylinder(d = screw_clear_d, h = 8.0 + eps, $fn = 24);
    }
  }
}

module rugged_base_red() {
  rugged_posts(overlap = 0);
}

// Two-tone disjoint preview (Zero Z-fighting)
module rugged_base_colored() {
  color("#1E1E1E") rugged_base_black();
  color("#C02026") rugged_base_red();
}

// Single watertight union for STL export / slicing (0.5mm overlap guarantees manifold union)
module rugged_base() {
  union() {
    rugged_base_black();
    rugged_posts(overlap = 0.5);
  }
}

// ---------------------------------------------------------
// 2. CLAMP MODULE (UNTOUCHED)
// ---------------------------------------------------------

module clamp_raised_bumpers(bw = 13.5) {
  for (i = [0 : 5]) {
    rotate([0, 0, 90 + i * 60])
      intersection() {
        cylinder(r = outer_r, h = clamp_h + 1.4, $fn = 120);
        translate([opening_r + 1.2, -bw / 2, lip_z])
          cube([outer_r, bw, (clamp_h - lip_z) + 1.4]);
      }
  }
}

module clamp_top_grooves() {
  for (r = [opening_r + 3.0, opening_r + 5.0, opening_r + 7.0]) {
    if (r < outer_r - 2.7) {
      translate([0, 0, clamp_h])
        difference() {
          cylinder(r = r + 0.45, h = 0.8, center = true, $fn = 120);
          cylinder(r = r - 0.45, h = 1.0, center = true, $fn = 120);
        }
    }
  }
}

module rugged_clamp() {
  difference() {
    union() {
      clamp();
      clamp_raised_bumpers();
      for (a = [90, 210, 330]) {
        rotate([0, 0, a])
          translate([screw_r, 0, lip_z - eps])
            cylinder(d = screw_head_d + 1.2, h = clamp_h + 1.4, $fn = 32);
      }
    }
    clamp_top_grooves();
    for (a = [30, 150, 270]) {
      rotate([0, 0, a])
        translate([screw_r, 0, 0]) {
          translate([0, 0, (clamp_h + 1.4) - screw_head_h])
            cylinder(d = screw_head_d, h = screw_head_h + 5, $fn = 32);
          translate([0, 0, -eps])
            cylinder(d = screw_clear_d, h = clamp_h + 10, $fn = 32);
        }
    }
  }
}

// ---------------------------------------------------------
// 3. BUTTON MODULE
// ---------------------------------------------------------

module rugged_button() {
  button_solid();
}