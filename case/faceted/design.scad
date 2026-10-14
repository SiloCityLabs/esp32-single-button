include <../assets/common.scad>

// ---------------------------------------------------------
// PARAMETERS & EQUAL-SPACING MATH
// ---------------------------------------------------------

tri_leg     = 7.0;  // Leg length for isosceles right triangle (mm)
cut_depth   = 1.4;  // Radial depth into circular wall (mm)
num_tri     = 12;   // Number of triangles around perimeter

// Exact angular sizes (degrees)
theta_usb = 2 * asin((usb_w / 2) / outer_r);
theta_tri = 2 * asin((tri_leg / 2) / outer_r);
theta_gap = (360 - theta_usb - (num_tri * theta_tri)) / (num_tri + 1);

// Vertical center of base wall
z_mid = seat_z / 2;

// ---------------------------------------------------------
// 1. BASE MODULE (CIRCULAR WITH RECESSED ISOSCELES TRIANGLES)
// ---------------------------------------------------------

module isosceles_right_triangle_cutter() {
  // 2D Isosceles Right Triangle (legs = tri_leg, 90-degree corner at bottom-left)
  // Centered at (0, 0)
  pts = [
    [-tri_leg/2, -tri_leg/2],
    [ tri_leg/2, -tri_leg/2],
    [-tri_leg/2,  tri_leg/2]
  ];

  rotate([90, 0, 90])
    linear_extrude(height = cut_depth + eps * 2)
      polygon(pts);
}

module faceted_base_cuts() {
  // USB port center is at +Y (90 deg)
  usb_center = 90;
  start_angle = (usb_center + theta_usb / 2) + theta_gap;

  for (i = [0 : num_tri - 1]) {
    angle = start_angle + i * (theta_tri + theta_gap) + (theta_tri / 2);

    rotate([0, 0, angle])
      translate([outer_r - cut_depth, 0, z_mid])
        isosceles_right_triangle_cutter();
  }
}

module faceted_base() {
  difference() {
    base(); // Standard circular base from common.scad

    // Recessed isosceles right triangles facing uniform direction
    faceted_base_cuts();
  }
}

// ---------------------------------------------------------
// 2. CLAMP MODULE (CIRCULAR PERIMETER WITH LOW-POLY TOP FACETS)
// ---------------------------------------------------------

module faceted_clamp_body() {
  bevel_drop = 2.4;
  rim_r      = opening_r + 1.2;
  top_z      = clamp_h;
  mid_z      = clamp_h - bevel_drop;
  segments   = 16;

  intersection() {
    // Keep outer envelope strictly circular
    cylinder(r = outer_r, h = clamp_h, $fn = 120);

    union() {
      // Inner structural wall around button hole
      cylinder(r = rim_r, h = top_z, $fn = 120);

      // Triangulated facets between inner rim and outer perimeter
      for (i = [0 : segments - 1]) {
        a1 = i * (360 / segments);
        a2 = (i + 1) * (360 / segments);
        z_outer = (i % 2 == 0) ? top_z : mid_z;

        hull() {
          // Inner circular apex anchor
          cylinder(r = rim_r, h = top_z, $fn = 60);

          // Outer perimeter edge segment
          rotate([0, 0, a1])
            translate([outer_r + 2, 0, 0])
              cylinder(r = 0.5, h = z_outer, $fn = 8);

          rotate([0, 0, a2])
            translate([outer_r + 2, 0, 0])
              cylinder(r = 0.5, h = (i % 2 == 0) ? mid_z : top_z, $fn = 8);
        }
      }
    }
  }
}

module faceted_clamp() {
  difference() {
    faceted_clamp_body();

    // Flange movement cavity
    translate([0, 0, -eps])
      difference() {
        cylinder(r = flange_clear_r, h = lip_z + eps);
        for (a = screw_angles)
          rotate([0, 0, a])
            translate([screw_r, 0, 0])
              translate([0, 0, -eps])
                cylinder(d = screw_clear_d + 4, h = clamp_h);
      }

    // Button opening
    translate([0, 0, lip_z - eps])
      cylinder(r = opening_r, h = lip_t + 2 * eps);

    // Screw clearance bores
    screw_clearance();
  }
}

// ---------------------------------------------------------
// 3. BUTTON MODULE
// ---------------------------------------------------------

module faceted_button() {
  button_solid();
}