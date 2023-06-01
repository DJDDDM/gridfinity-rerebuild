/// Pegboard Board

include <../src/pegboard_board.scad>

// how many holes in x including staggered holes
x_board_size = 101.6; //[25.4:25.4:254]
// how many holes in y including staggered holes
y_board_size = 101.6; //[25.4:25.4:254]
hole_extra_diameter = 0.50; //[0:0.01:5]
//shape of the holes
type = "single_circular"; //[single_circular, single_hexagonal, double_circular, double_hexagonal, double_octagonal, rowed_circular, rowed_hexagonal, quad_circular, quad_hexagonal ]

/* [printer settings] */
rotate_model_y = 0; //[-180:180]

arbitrary_big_value = 100;

$fn = 128;

/* [Hidden] */
// Constants
//  board dimensions imperial system given in mm
hole_spacing = 25.4; // including staggering
hole_size = 6;
board_thickness = 5;
wall_thickness = 1.2;

epsilon = 0.000000001;

rotate([ 0, rotate_model_y, 0 ]) pegboard_board(type);
