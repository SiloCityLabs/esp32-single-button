include <../assets/common.scad>

// ---------------------------------------------------------
// PARAMETERS
// ---------------------------------------------------------

num_posts       = 6;
post_step       = 360 / num_posts;
post_span       = 24;
panel_span      = post_step - post_span;
post_protrusion = 1.4;
clamp_lift      = 1.4;

half_post_ang   = post_span / 2;
half_panel_ang  = panel_span / 2;

// Fastener locations: 270 deg (rear), 30 deg, 150 deg
rugged_screw_angles = [270, 30, 150];

// Fillet and clearance parameters
base_fillet_r  = 2.0;
r_base_bot     = outer_r - base_fillet_r;
clamp_flange_r = is_undef(flange_r) ? (opening_r + 1.8) : (flange_r + 0.5);
screw_boss_d   = screw_head_d + 2.2;

// ---------------------------------------------------------
// BASE MODULE
// ---------------------------------------------------------

// Horizontal cylindrical groove with rounded spherical end caps
module panel_arc_groove(z, ang_span = 21.6) {
  half = ang_span / 2;
  union() {
    rotate([0, 0, -half])
      rotate_extrude(angle = ang_span, $fn = 80)
        translate([outer_r - 0.4, z])
          circle(d = 1.2, $fn = 16);

    rotate([0, 0, -half])
      translate([outer_r - 0.4, 0, z])
        sphere(d = 1.2, $fn = 16);

    rotate([0, 0, half])
      translate([outer_r - 0.4, 0, z])
        sphere(d = 1.2, $fn = 16);
  }
}

// Three horizontal accent grooves per panel
module base_horizontal_lines() {
  z_mid  = (base_fillet_r + seat_z) / 2;
  z_step = 2.2;
  arc_w  = panel_span * 0.60;

  for (i = [0 : num_posts - 1]) {
    ang = 90 + 30 + i * post_step;
    rotate([0, 0, ang]) {
      panel_arc_groove(z = z_mid + z_step, ang_span = arc_w);
      panel_arc_groove(z = z_mid,          ang_span = arc_w);
      panel_arc_groove(z = z_mid - z_step, ang_span = arc_w);
    }
  }
}

// 2D radial profile for armor posts following the bottom fillet
function post_profile_points(overlap = 0) = concat(
  [[outer_r + post_protrusion, seat_z]],
  [[outer_r + post_protrusion, base_fillet_r]],
  [for (a = [80 : -10 : 0]) [(r_base_bot + post_protrusion) + base_fillet_r * sin(a), base_fillet_r - base_fillet_r * cos(a)]],
  [for (a = [0 : 10 : 90]) [(r_base_bot - overlap) + base_fillet_r * sin(a), base_fillet_r - base_fillet_r * cos(a)]],
  [[outer_r - overlap, seat_z]]
);

// Protruding armor posts around the base perimeter
module rugged_posts(overlap = 0) {
  difference() {
    union() {
      for (i = [0 : num_posts - 1]) {
        ang = 90 + i * post_step;
        rotate([0, 0, ang - half_post_ang])
          rotate_extrude(angle = post_span, $fn = 80)
            polygon(post_profile_points(overlap = overlap));
      }
    }
    usb_tunnel();
  }
}

// Base core body including internal cavities and panel grooves
module rugged_base_black() {
  difference() {
    base();

    usb_tunnel();
    wire_notch();
    base_horizontal_lines();

    for (a = rugged_screw_angles) {
      rotate([0, 0, a])
        translate([screw_r, 0, seat_z - 8.0])
          cylinder(d = screw_clear_d, h = 8.0 + eps, $fn = 24);
    }
  }
}

// Base armor posts
module rugged_base_red() {
  rugged_posts(overlap = 0);
}

// Base two-color preview
module rugged_base_colored() {
  color("#1E1E1E") rugged_base_black();
  color("#C02026") rugged_base_red();
}

// Unified base solid for manufacturing export
module rugged_base() {
  union() {
    rugged_base_black();
    rugged_posts(overlap = 0.5);
  }
}

// ---------------------------------------------------------
// CLAMP MODULE
// ---------------------------------------------------------

// Concentric arc grooves along the clamp panel upper face
module clamp_panel_grooves() {
  groove_span = panel_span - 4;
  half = groove_span / 2;

  for (i = [0 : num_posts - 1]) {
    ang = 90 + 30 + i * post_step;
    rotate([0, 0, ang - half]) {
      for (r = [opening_r + 2.8, opening_r + 4.8]) {
        if (r < outer_r - 1.2) {
          rotate_extrude(angle = groove_span, $fn = 60)
            translate([r, clamp_h])
              circle(d = 0.75, $fn = 16);
        }
      }
    }
  }
}

// Clamp panel sectors with button clearance and surface grooves
module rugged_clamp_black() {
  difference() {
    cylinder(r = outer_r, h = clamp_h, $fn = 120);

    translate([0, 0, -eps])
      cylinder(r = opening_r, h = clamp_h + 2 * eps, $fn = 80);

    translate([0, 0, -eps])
      cylinder(r = clamp_flange_r, h = lip_z + eps, $fn = 80);

    for (i = [0 : num_posts - 1]) {
      ang = 90 + i * post_step;
      rotate([0, 0, ang - half_post_ang])
        rotate_extrude(angle = post_span, $fn = 60)
          square([outer_r + post_protrusion + 5, clamp_h + 2 * eps]);
    }

    clamp_panel_grooves();
  }
}

// Raised clamp armor posts with fastener counterbores and underside bosses
module rugged_clamp_red(overlap = 0) {
  r_post  = outer_r + post_protrusion;
  r_inner = opening_r - overlap;

  difference() {
    union() {
      for (i = [0 : num_posts - 1]) {
        ang = 90 + i * post_step;
        rotate([0, 0, ang - half_post_ang])
          rotate_extrude(angle = post_span, $fn = 80)
            polygon([
              [r_inner,       0],
              [r_post,        0],
              [r_post,        clamp_h + clamp_lift - 1.0],
              [r_post - 1.0,  clamp_h + clamp_lift],
              [r_inner + 1.2, clamp_h + clamp_lift],
              [r_inner,       clamp_h]
            ]);
      }

      for (a = rugged_screw_angles) {
        rotate([0, 0, a])
          translate([screw_r, 0, 0])
            cylinder(d = screw_boss_d, h = clamp_h + clamp_lift, $fn = 32);
      }
    }

    translate([0, 0, -eps])
      cylinder(r = opening_r, h = clamp_h + clamp_lift + 2 * eps, $fn = 80);

    difference() {
      translate([0, 0, -eps])
        cylinder(r = clamp_flange_r, h = lip_z + eps, $fn = 80);

      for (a = rugged_screw_angles) {
        rotate([0, 0, a])
          translate([screw_r, 0, -2 * eps])
            cylinder(d = screw_boss_d, h = lip_z + 4 * eps, $fn = 32);
      }
    }

    for (a = rugged_screw_angles) {
      rotate([0, 0, a])
        translate([screw_r, 0, 0]) {
          translate([0, 0, (clamp_h + clamp_lift) - screw_head_h])
            cylinder(d = screw_head_d, h = screw_head_h + 5, $fn = 32);

          translate([0, 0, -eps])
            cylinder(d = screw_clear_d, h = clamp_h + clamp_lift + 10, $fn = 32);
        }
    }
  }
}

// Clamp two-color preview
module rugged_clamp_colored() {
  color("#1E1E1E") rugged_clamp_black();
  color("#C02026") rugged_clamp_red(overlap = 0);
}

// Unified clamp solid for manufacturing export
module rugged_clamp() {
  union() {
    rugged_clamp_black();
    rugged_clamp_red(overlap = 0.4);
  }
}

// ---------------------------------------------------------
// BUTTON MODULE
// ---------------------------------------------------------

module rugged_button() {
  button_solid();
}