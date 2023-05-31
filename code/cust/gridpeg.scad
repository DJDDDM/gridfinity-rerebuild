// PEGSTR - Pegboard Wizard
// Initial design by Marius Gheorghescu, November 2014
// Improved by DJDDDM, Mai 2023

// preview[view:north, tilt:bottom diagonal]

include <../src/gridpeg.scad>

/// Pegboard

// hight of the holder multiples of hole_spacing = 25.4
holder_height = 25.4; //[0:25.4:254]

/* [printer settings] */
wall_line_width = 0.6;
wall_line_count = 2;
wall_thickness = 2 * wall_line_count * wall_line_width;

rotate_model_y = 0; //[-180:180]

/* [Hidden] */

// Constants
//  board dimensions imperial system given in mm
hole_spacing = 25.4;
hole_size = 6.0035;
board_thickness = 5;

epsilon = 0.1;
arbitrary_big_value = 100;

//Arranging

pin_height = 1.5 * board_thickness;
pin_clip_height_reduction = board_thickness * 0.25;

clip_height = 2 * hole_size + 2;

outer_wall_x_distance = wall_thickness + board_thickness / 2 - epsilon;

holder_total_z = round(holder_height / hole_spacing) * hole_spacing;




/// Gridfinity Baseplate

/* [Gridfinity Baseplate] */
/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;

/* [General Settings] */
// number of bases along x-axis
gridx = 2;
// number of bases along y-axis
gridy = 2;
/* [Hidden] */
// base unit
length = 42;

/* [Screw Together Settings - Defaults work for M3 and 4-40] */
// screw diameter
d_screw = 3.35;
// screw head diameter
d_screw_head = 5;
// screw spacing distance
screw_spacing = .5;
// number of screws per grid block
n_screws = 1; // [1:3]

/* [Fit to Drawer] */
// minimum length of baseplate along x (leave zero to ignore, will automatically fill area if gridx is zero)
distancex = 0;
// minimum length of baseplate along y (leave zero to ignore, will automatically fill area if gridy is zero)
distancey = 0;

// where to align extra space along x
fitx = 0; // [-1:0.1:1]
// where to align extra space along y
fity = 0; // [-1:0.1:1]

/* [Styles] */

// baseplate styles
style_plate = 0; // [0: thin, 1:weighted, 2:skeletonized, 3: screw together, 4: screw together minimal]

// enable magnet hole
enable_magnet = true;

// hole styles
style_hole = 2; // [0:none, 1:contersink, 2:counterbore]

// ===== IMPLEMENTATION ===== //
screw_together = (style_plate == 3 || style_plate == 4);

holder_total_x = length * gridy;
grid_total_x = length * gridx;

gridfinity_pegboard();

