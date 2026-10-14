include <../assets/common.scad>

// ---------------------------------------------------------
// RUGGED VARIANT PARAMETERS (4-SECTOR BASE)
// ---------------------------------------------------------

num_posts       = 4;
post_step       = 360 / num_posts;   // 90 deg
post_span       = 26;                // Angular width of red posts (deg)
panel_span      = post_step - post_span; // 64 deg for black panels
post_protrusion = 1.4;               // Red posts protrude 1.4mm past outer_r

half_post_ang   = post_span / 2;     // 13 deg
half_panel_ang  = panel_span / 2;    // 32 deg

// ---------------------------------------------------------
// 1. BASE MODULE
// ---------------------------------------------------------

// Smooth pill groove along a cylindrical arc
module panel_arc_groove(z, ang_span = 32) {
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

// 3 evenly spaced horizontal lines centered vertically and horizontally
module base_horizontal_lines() {
  z_mid  = (2.0 + seat_z) / 2; // 7.125 mm
  z_step = 2.2;                // Vertical center-to-center spacing
  arc_w  = panel_span * 0.50;  // Exactly 50% width (~32 deg)

  for (i = [0 : num_posts - 1]) {
    ang = 45 + i * post_step; // Centered horizontally at 45, 135, 225, 315 deg
    rotate([0, 0, ang]) {
      panel_arc_groove(z = z_mid + z_step, ang_span = arc_w); // Top line (9.325 mm)
      panel_arc_groove(z = z_mid,          ang_span = arc_w); // Middle line (7.125 mm)
      panel_arc_groove(z = z_mid - z_step, ang_span = arc_w); // Bottom line (4.925 mm)
    }
  }
}

// 4 Outer Armor Post protrusions (extending past outer_r)
module post_protrusions() {
  r_post = outer_r + post_protrusion;
  difference() {
    union() {
      for (i = [0 : num_posts - 1]) {
        ang = 90 + i * post_step;
        rotate([0, 0, ang - half_post_ang])
          rotate_extrude(angle = post_span, $fn = 80)
            polygon([
              [outer_r - 0.5, 0],
              [r_post - 2.0,  0],
              [r_post,        2.0],
              [r_post,        seat_z],
              [outer_r - 0.5, seat_z]
            ]);
      }
    }
    // Cut USB tunnel through the 90 deg front post
    usb_tunnel();
  }
}

// Post sector clearance cutter (used to prevent preview Z-fighting)
module post_cutout_mask() {
  for (i = [0 : num_posts - 1]) {
    ang = 90 + i * post_step;
    rotate([0, 0, ang - half_post_ang])
      rotate_extrude(angle = post_span, $fn = 80)
        translate([outer_r - 0.5, -eps])
          square([post_protrusion + 5, seat_z + 2 * eps]);
  }
}

// Single watertight union for STL export and slicing
module rugged_base() {
  difference() {
    union() {
      base();
      post_protrusions();
    }
    usb_tunnel();
    wire_notch();
    base_horizontal_lines();
  }
}

// ---------------------------------------------------------
// 2. TWO-TONE PREVIEW COLOR MODULES
// ---------------------------------------------------------

module rugged_base_black() {
  difference() {
    base();
    base_horizontal_lines();
    usb_tunnel();
    wire_notch();
    post_cutout_mask(); // Removes the post regions so black does not overlap red
  }
}

module rugged_base_colored() {
  color("#1E1E1E") rugged_base_black();
  color("#C02026") post_protrusions();
}

// ---------------------------------------------------------
// 3. CLAMP MODULE (UNTOUCHED)
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
// 4. BUTTON MODULE
// ---------------------------------------------------------

module rugged_button() {
  button_solid();
}