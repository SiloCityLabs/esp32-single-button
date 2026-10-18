// Two-piece mold for stamping sheet packaging around base_body().
// Rectangular blank + cup (draft taper); circular hump nests the product.
// Preview uses fn below. For a dense STL: ./build.sh [fn]
//   openscad -o mold.stl -D 'fn_override=200' mold.scad
include <../libraries/BOSL2_submodule/std.scad>
include <common.scad>

// -D cannot reliably override Customizer-assigned vars (openscad#2037).
// build.sh sets fn_override; sentinel means "use the preview default".
fn_override = "stupid_hack";
fn = (fn_override != undef && fn_override != "stupid_hack") ? fn_override : 40;
$fn = fn;

sheet_thickness = 0.8;
draft_deg = 7;
// Roundovers so the sheet does not tear. Narrow end positive, wide end negative (fillet).
cup_round = 4.9;
cup_round_z = 22;
// outer_r = 31; // common.scad
// box size: 85mm
// these mold margins need to come down, or the bottom shouldn't have rounding
mold_margin_x = 20;
mold_margin_y = 20;
mold_x = 2 * (outer_r + mold_margin_x);
mold_y = 2 * (outer_r + mold_margin_y);
mold_h = seat_z + 25;
cup_h = seat_z + 10;
// Cup plateau fills the blank; leave cup_round for the rim fillet on each side.
cup_x_top = mold_x - 2 * cup_round;
cup_y_top = mold_y - 2 * cup_round;
cup_x_bot = cup_x_top - 2 * cup_h * tan(draft_deg);
cup_y_bot = cup_y_top - 2 * cup_h * tan(draft_deg);
cup_z = mold_h - cup_h;
hump_h = seat_z;
hump_r_bot = outer_r;
hump_r_top = hump_r_bot - hump_h * tan(draft_deg);
hump_round = 3.9;
clamp_base_t = 8;  // wide flange on the upper for clamping
visual_move = 10;  // space the halves apart in preview
// avoid z-fighting
fudge = 0.01;
positiveColor = "burlywood";
negativeColor = [1, 0, 0, 0.5];

module blank() {
  cuboid([mold_x, mold_y, mold_h], anchor = BOTTOM);
}

// Rectangular parting volume. Wider at the open (top) end for draft.
// gap insets the male by sheet_thickness in XY and height.
// Rounding softens the stamp edges; clamp base stays sharp separately.
module cup(gap = 0) {
  // rounded_prism centers 2d+height at z=0; use path3d so the floor sits at cup_z.
  x_bot = cup_x_bot - 2 * gap;
  y_bot = cup_y_bot - 2 * gap;
  x_top = cup_x_top - 2 * gap;
  y_top = cup_y_top - 2 * gap;
  h = cup_h - gap + fudge;
  translate([0, 0, cup_z + gap])
    rounded_prism(
      path3d(rect([x_bot, y_bot]), 0),
      path3d(rect([x_top, y_top]), h),
      joint_bot = cup_round,
      joint_top = -cup_round,
      joint_sides = cup_round_z,
      k = 0.92
    );
}

// Circular raised form the sheet wraps over so base_body() sits in the nest.
// Opposite the cup: wide bottom (negative fillet), narrow top (positive roundover).
// gap expands for upper clearance by sheet_thickness (radius + height).
module hump(gap = 0) {
  translate([0, 0, cup_z - gap])
    cyl(
      r1 = hump_r_bot + gap,
      r2 = hump_r_top + gap,
      h = hump_h + gap,
      rounding1 = -hump_round,
      rounding2 = hump_round,
      anchor = BOTTOM
    );
}

// Female die: blank minus cup, plus the product hump on the cup floor.
// Cup rounding fillets the cavity floor and the open rim.
module mold_lower() {
  difference() {
    color(positiveColor)
    blank();

    color(negativeColor)
    cup();
  }
  color(positiveColor)
  hump();
}

// Male punch: cup plug shrunk by sheet_thickness, cleared for hump + sheet.
// Wide base matches lower OD so the halves can be clamped.
module mold_upper() {
  difference() {
    union() {
      intersection() {
        color(positiveColor)
        blank();
        color(positiveColor)
        cup(sheet_thickness);
      }
      // Wide clamp base. Same footprint as the lower mold.
      color(positiveColor)
      translate([0, 0, mold_h])
        cuboid([mold_x, mold_y, clamp_base_t], anchor = BOTTOM);
    }

    color(negativeColor)
    // align with the top surface
    translate([0,0,sheet_thickness*2-fudge])
    hump(sheet_thickness);
  }
}


mold_lower();


translate([mold_x + visual_move, 0, 0])
mold_upper();
