// preview[view:north, tilt:bottom diagonal]

/// Pegboard Item

include <../src/pegboard.scad>

// hight of the holder multiples of hole_spacing = 25.4
holder_height = 25.4;  //[0:25.4:254]
holder_total_x = 25.4; //[0:25.4:254]
//makes pins smaller by this amount:
reduce_pin_diameter = 0.25;

/* [printer settings] */
wall_line_width = 0.6;
wall_line_count = 2;
wall_thickness = wall_line_count * wall_line_width;

rotate_model_y = 0; //[-180:180]

/* [Dock] */

dock_height = 30;
dock_diameter = 6.35;
dock_distance = 25;
dock_amount = 2;

arbitrary_big_value = 100;

/* [Hidden] */

// Constants
//  board dimensions imperial system given in mm
hole_spacing = 25.4;
hole_size = 7;
pin_diameter = hole_size - reduce_pin_diameter;
board_thickness = 5;

pin_height = board_thickness;
pin_clip_height_reduction = board_thickness * 0.25 * 0;
clip_height = 2 * hole_size + 2;

epsilon = 0.00000001;

outer_wall_x_distance = wall_thickness + board_thickness / 2 - epsilon;

holder_total_z = round(holder_height / hole_spacing) * hole_spacing;



$fn = 32;

rotate([ 0, rotate_model_y, 0 ]) item();