// Two-piece mold for stamping sheet packaging around base_body().
// Blank cylinder, cup cut splits the halves (draft taper), hump nests the product.
// Preview uses fn below. For a dense STL: ./build.sh [fn]
//   openscad -o mold.stl -D 'fn_override=200' mold.scad
include <../libraries/BOSL2_submodule/std.scad>
include <common.scad>

// -D cannot reliably override Customizer-assigned vars (openscad#2037).
// build.sh sets fn_override; sentinel means "use the preview default".
fn_override = "stupid_hack";
fn = (fn_override != undef && fn_override != "stupid_hack") ? fn_override : 40;
$fn = fn;

mold_r = outer_r + 20;
mold_h = seat_z + 25;
cup_clear = 8;
draft_deg = 3;
cup_h = seat_z + 10;
cup_r_top = outer_r + cup_clear;
cup_r_bot = cup_r_top - cup_h * tan(draft_deg);
cup_z = mold_h - cup_h;
sheet_thickness = 0.8;
// Roundovers so the sheet does not tear. Narrow end positive, wide end negative (fillet).
cup_round = 3.0;
hump_h = seat_z;
hump_r_bot = outer_r;
hump_r_top = hump_r_bot - hump_h * tan(draft_deg);
hump_round = cup_round;
clamp_base_t = 8;  // wide flange on the upper for clamping
visual_move = 10;  // space the halves apart in preview
// avoid z-fighting
fudge = 0.01;
positiveColor = "burlywood";
negativeColor = [1, 0, 0, 0.5];

module blank() {
  cylinder(r = mold_r, h = mold_h);
}

// Parting volume. Wider at the open (top) end for draft.
// gap insets the male by sheet_thickness in radius and height.
// Rounding softens the stamp edges; clamp base stays sharp separately.
module cup(gap = 0) {
  translate([0, 0, cup_z + gap])
    cyl(
      r1 = cup_r_bot - gap,
      r2 = cup_r_top - gap,
      h = cup_h - gap + fudge,
      rounding1 = cup_round,
      rounding2 = -cup_round,
      anchor = BOTTOM
    );
}

// Raised form the sheet wraps over so base_body() sits in the stamped nest.
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
      // Wide clamp base. Same OD as the lower mold.
      color(positiveColor)
      translate([0, 0, mold_h])
        cylinder(r = mold_r, h = clamp_base_t);
    }

    color(negativeColor)
    // align with the top surface
    translate([0,0,sheet_thickness*2-fudge])
    hump(sheet_thickness);
  }
}


mold_lower();


translate([2 * mold_r + visual_move, 0, 0])
mold_upper();
