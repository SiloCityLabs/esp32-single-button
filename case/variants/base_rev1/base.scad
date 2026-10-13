include <../../core/puck_core.scad>

module rev1_base_exterior() {
  rad = 2;
  minkowski() {
    translate([0, 0, rad])
      cylinder(r = outer_r - rad, h = seat_z - rad);
    difference() {
      sphere(r = rad);
      translate([-rad * 2, -rad * 2, 0])
        cube([rad * 4, rad * 4, rad * 2]);
    }
  }
}

module base() {
  difference() {
    rev1_base_exterior();
    core_cavities();
  }
  pcb_tabs();
}

base();