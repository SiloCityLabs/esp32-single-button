// Two-piece mold for stamping sheet packaging around base_body().
// Blank cylinder, cup cut splits the halves (draft taper), hump nests the product.
//   openscad -o mold.stl mold.scad
include <common.scad>

$fn = 25;

mold_r = outer_r + 20;
mold_h = seat_z + 25;
cup_clear = 8;
draft_deg = 3;
cup_h = seat_z + 10;
cup_r_top = outer_r + cup_clear;
cup_r_bot = cup_r_top - cup_h * tan(draft_deg);
cup_z = mold_h - cup_h;
sheet_thickness = 0.8;
clamp_base_t = 8;  // wide flange on the upper for clamping
visual_move = 10;  // space the halves apart in preview
// avoid z-fighting
fudge = 0.01;

module blank() {
  cylinder(r = mold_r, h = mold_h);
}

// Parting volume. Wider at the open (top) end for draft.
// gap insets the male by sheet_thickness in radius and height.
module cup(gap = 0) {
  translate([0, 0, cup_z + gap])
    cylinder(
      r1 = cup_r_bot - gap,
      r2 = cup_r_top - gap,
      h = cup_h - gap + fudge
    );
}

// Raised form the sheet wraps over so base_body() sits in the stamped nest.
// gap expands the clearance volume by sheet_thickness (radius + height).
module hump(gap = 0) {
  translate([0, 0, cup_z - gap])
    if (gap > 0)
      minkowski() {
        base_body();
        cylinder(r = gap, h = fudge);
      }
    else
      base_body();
}

// Female die: blank minus cup, plus the product hump on the cup floor.
module mold_lower() {
  difference() {
    blank();
    cup();
  }
  hump();
}

// Male punch: cup plug shrunk by sheet_thickness, cleared for hump + sheet.
// Wide base matches lower OD so the halves can be clamped.
module mold_upper() {
  difference() {
    union() {
      intersection() {
        blank();
        cup(sheet_thickness);
      }
      // Wide clamp base. Same OD as the lower mold.
      translate([0, 0, mold_h])
        cylinder(r = mold_r, h = clamp_base_t);
    }
    hump(sheet_thickness);
  }
}

color("burlywood")
  mold_lower();
color("red", 0.4)
  cup();

color("burlywood")
  translate([2 * mold_r + visual_move, 0, 0])
    mold_upper();
color("red", 0.4)
  translate([2 * mold_r + visual_move, 0, 0])
    hump(sheet_thickness);
