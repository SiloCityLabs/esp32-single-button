include <../assets/common.scad>

// ---------------------------------------------------------
// RETRO FUTURIST PARAMETERS
// ---------------------------------------------------------

/* [Clamp Double Taper Profile] */
chamfer_run   = 2.0;               // Outer chamfer radial run (mm)
chamfer_rise  = 2.0;               // Outer chamfer vertical rise (mm)
taper_ratio   = 2.0 / 10.0;        // Conical taper slope (10 run : 2 rise)

// Button top face Z in clamp local coordinates (seat_z = 0)
button_top_z  = tip_rest + flange_t + face_h - seat_z;

// Clamp inner lip height matches button top height (flush, not lower than button)
clamp_lip_z   = button_top_z;

// Derived profile dimensions
r_chamfer     = outer_r - chamfer_run;                             // 29.0 mm
z_inner       = clamp_lip_z;                                       // ~5.65 mm
z_chamfer     = z_inner - (r_chamfer - opening_r) * taper_ratio;   // ~4.48 mm
z_outer       = z_chamfer - chamfer_rise;                          // ~2.48 mm

// Surface Z height as a function of radius r
function clamp_surf_z(r) =
  (r >= r_chamfer) ? (z_outer + (outer_r - r) * (chamfer_rise / chamfer_run)) :
  (z_inner - (r - opening_r) * taper_ratio);

/* [Concentric Ribs] */
rib_count     = 4;
rib_spacing   = 1.25;
rib_start_r   = opening_r + 1.0;
groove_d      = 0.60;
groove_w      = 0.95;

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

module retro_clamp_body() {
  rotate_extrude($fn = 160)
    polygon([
      [0, 0],
      [outer_r, 0],
      [outer_r, z_outer],
      [r_chamfer, z_chamfer],
      [opening_r, z_inner],
      [0, z_inner]
    ]);
}

module retro_screw_clearance() {
  z_head_floor = clamp_surf_z(screw_r) - screw_head_h;
  for (a = screw_angles)
    rotate([0, 0, a])
      translate([screw_r, 0, 0]) {
        // Through-bore for screw shank
        translate([0, 0, -eps])
          cylinder(d = screw_clear_d, h = z_inner + 10, $fn = 24);
        // Recessed counterbore for screw head
        translate([0, 0, z_head_floor])
          cylinder(d = screw_head_d, h = z_inner + 10, $fn = 32);
      }
}

module retro_clamp() {
  difference() {
    // Solid clamp body with double tapered top profile
    retro_clamp_body();

    // 1. Internal cavity for button flange travel
    translate([0, 0, -eps])
      difference() {
        cylinder(r = flange_clear_r, h = lip_z + eps);
        // Retain solid boss around screw holes for screw pilot alignment
        for (a = screw_angles)
          rotate([0, 0, a])
            translate([screw_r, 0, 0])
              translate([0, 0, -eps])
                cylinder(d = screw_clear_d + 4, h = z_inner + 10);
      }

    // 2. Central opening for button cap
    translate([0, 0, lip_z - eps])
      cylinder(r = opening_r, h = z_inner - lip_z + 2 * eps);

    // 3. Screw shank holes and recessed head counterbores
    retro_screw_clearance();

    // 4. Concentric decorative ribs on tapered face
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

    // Skip cutting over the USB tunnel and PCB front corners (65 to 115 degrees)
    if (!(angle >= 65 && angle <= 115)) {
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

module retro_top_ribs() {
  for (i = [0 : rib_count - 1]) {
    r = rib_start_r + (i * rib_spacing);
    // Ensure grooves stay on the 10:2 tapered conical face
    if (r < r_chamfer - (groove_w / 2)) {
      z_at_r = clamp_surf_z(r);
      translate([0, 0, z_at_r])
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
