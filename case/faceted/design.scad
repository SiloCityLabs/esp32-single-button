include <../assets/common.scad>

// ---------------------------------------------------------
// PARAMETERS & MATH
// ---------------------------------------------------------

// Base side triangles
tri_leg   = 6.5;   // Leg height and base of side right triangles (mm)
cut_depth = 1.4;   // Radial recess depth into wall (mm)
k_side    = 5;     // Number of triangles on EACH side
rear_w    = 8.0;   // Base width of the rear connected triangle (mm)

// Angular calculations
theta_usb  = 2 * asin((usb_w / 2) / outer_r);
theta_tri  = 2 * asin((tri_leg / 2) / outer_r);
theta_rear = 2 * asin((rear_w / 2) / outer_r);
theta_gap  = (180 - (theta_usb / 2) - (theta_rear / 2) - (k_side * theta_tri)) / (k_side + 1);

z_mid = seat_z / 2;

// Clamp Relief Parameters (Aggressive Diamond Geometry)
z_foundation = 3.6;  // Continuous solid perimeter height (well above lip_z = 2.25)
z_peak_out   = 5.5;  // High outer facet peak
z_val_out    = 3.6;  // Low outer facet valley (meets foundation with zero gap)
z_peak_in    = 4.6;  // High inner facet peak
z_val_in     = 3.6;  // Low inner facet valley
rim_r        = opening_r + 1.0;

// ---------------------------------------------------------
// 1. BASE MODULE
// ---------------------------------------------------------

// Left side cutter: Right angle faces away from USB
module cutter_left() {
  pts = [
    [-tri_leg/2, -tri_leg/2],
    [ tri_leg/2, -tri_leg/2],
    [ tri_leg/2,  tri_leg/2]
  ];
  rotate([90, 0, 90])
    linear_extrude(height = cut_depth + eps * 2)
      polygon(pts);
}

// Right side cutter: Mirrored, right angle faces away from USB
module cutter_right() {
  pts = [
    [-tri_leg/2, -tri_leg/2],
    [ tri_leg/2, -tri_leg/2],
    [-tri_leg/2,  tri_leg/2]
  ];
  rotate([90, 0, 90])
    linear_extrude(height = cut_depth + eps * 2)
      polygon(pts);
}

// Rear connected keystone: Symmetric triangle centered at 270 deg
module cutter_rear_connected() {
  pts = [
    [-rear_w/2, -tri_leg/2],
    [ rear_w/2, -tri_leg/2],
    [ 0,         tri_leg/2]
  ];
  rotate([90, 0, 90])
    linear_extrude(height = cut_depth + eps * 2)
      polygon(pts);
}

module faceted_base_cuts() {
  usb_center = 90;

  // Left side stream (90 to 270 deg)
  for (i = [0 : k_side - 1]) {
    ang = usb_center + (theta_usb / 2) + theta_gap + (i * (theta_tri + theta_gap)) + (theta_tri / 2);
    rotate([0, 0, ang])
      translate([outer_r - cut_depth, 0, z_mid])
        cutter_left();
  }

  // Right side stream (90 down to -90 / 270 deg)
  for (i = [0 : k_side - 1]) {
    ang = usb_center - ((theta_usb / 2) + theta_gap + (i * (theta_tri + theta_gap)) + (theta_tri / 2));
    rotate([0, 0, ang])
      translate([outer_r - cut_depth, 0, z_mid])
        cutter_right();
  }

  // Connected triangle at the rear (270 deg)
  rotate([0, 0, 270])
    translate([outer_r - cut_depth, 0, z_mid])
      cutter_rear_connected();
}

module faceted_base() {
  difference() {
    base();
    faceted_base_cuts();
  }
}

// ---------------------------------------------------------
// 2. WATERTIGHT FACETED CLAMP MODULE (NO GAPS / FULLY CLOSED SIDES)
// ---------------------------------------------------------

module faceted_clamp_body() {
  n_sectors   = 16;
  step        = 360 / n_sectors;
  r_out_ext   = outer_r + 3.0; // Extends past outer_r for clean circular intersection
  z_anchor    = 3.0;           // Anchored deep inside the solid foundation

  intersection() {
    // Guarantees the outer perimeter is 100% circular with zero chording
    cylinder(r = outer_r, h = z_peak_out + 5, $fn = 120);

    union() {
      // 1. Solid continuous foundation cylinder (closes all side walls)
      cylinder(r = outer_r, h = z_foundation, $fn = 120);

      // 2. Solid inner collar around the button hole
      cylinder(r = rim_r, h = z_peak_in, $fn = 120);

      // 3. 32 Interlocking Facet Prisms
      for (i = [0 : n_sectors - 1]) {
        a1 = i * step;
        a2 = (i + 1) * step;

        z_o1 = (i % 2 == 0) ? z_peak_out : z_val_out;
        z_o2 = ((i + 1) % 2 == 0) ? z_peak_out : z_val_out;

        z_i1 = (i % 2 == 0) ? z_val_in : z_peak_in;
        z_i2 = ((i + 1) % 2 == 0) ? z_val_in : z_peak_in;

        // Facet Triangle A: Outer-biased
        hull() {
          translate([r_out_ext * cos(a1), r_out_ext * sin(a1), z_o1]) sphere(r = 0.05, $fn = 6);
          translate([r_out_ext * cos(a2), r_out_ext * sin(a2), z_o2]) sphere(r = 0.05, $fn = 6);
          translate([rim_r     * cos(a2), rim_r     * sin(a2), z_i2]) sphere(r = 0.05, $fn = 6);

          // Deep downward anchors
          translate([r_out_ext * cos(a1), r_out_ext * sin(a1), z_anchor]) sphere(r = 0.05, $fn = 6);
          translate([r_out_ext * cos(a2), r_out_ext * sin(a2), z_anchor]) sphere(r = 0.05, $fn = 6);
          translate([rim_r     * cos(a2), rim_r     * sin(a2), z_anchor]) sphere(r = 0.05, $fn = 6);
        }

        // Facet Triangle B: Inner-biased
        hull() {
          translate([r_out_ext * cos(a1), r_out_ext * sin(a1), z_o1]) sphere(r = 0.05, $fn = 6);
          translate([rim_r     * cos(a1), rim_r     * sin(a1), z_i1]) sphere(r = 0.05, $fn = 6);
          translate([rim_r     * cos(a2), rim_r     * sin(a2), z_i2]) sphere(r = 0.05, $fn = 6);

          translate([r_out_ext * cos(a1), r_out_ext * sin(a1), z_anchor]) sphere(r = 0.05, $fn = 6);
          translate([rim_r     * cos(a1), rim_r     * sin(a1), z_anchor]) sphere(r = 0.05, $fn = 6);
          translate([rim_r     * cos(a2), rim_r     * sin(a2), z_anchor]) sphere(r = 0.05, $fn = 6);
        }
      }
    }
  }
}

module faceted_clamp() {
  difference() {
    faceted_clamp_body();

    // Internal flange movement cavity
    translate([0, 0, -eps])
      difference() {
        cylinder(r = flange_clear_r, h = lip_z + eps);
        for (a = screw_angles)
          rotate([0, 0, a])
            translate([screw_r, 0, 0])
              translate([0, 0, -eps])
                cylinder(d = screw_clear_d + 4, h = clamp_h + 10);
      }

    // Button opening
    translate([0, 0, lip_z - eps])
      cylinder(r = opening_r, h = z_peak_out + 10);

    // Screw clearance bores through peak facets
    for (a = screw_angles)
      rotate([0, 0, a])
        translate([screw_r, 0, 0]) {
          translate([0, 0, -eps])
            cylinder(d = screw_clear_d, h = z_peak_out + 10);
          translate([0, 0, clamp_h - screw_head_h])
            cylinder(d = screw_head_d, h = z_peak_out + 10);
        }
  }
}

// ---------------------------------------------------------
// 3. BUTTON MODULE
// ---------------------------------------------------------

module faceted_button() {
  button_solid();
}