include <../src/utility.scad>
include <BOSL2/std.scad>
include <standard.scad>

// ===== PARAMETERS ===== //

/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;

/* [General Settings] */
// number of bases along x-axis
gridx = 5;
// number of bases along y-axis
gridy = 5;
// bin height. See bin height information and "gridz_define" below.
gridz = 6;

/* [Compartments] */
// number of X Divisions (set to zero to have solid bin)
divx = 1;
// number of y Divisions (set to zero to have solid bin)
divy = 1;

/* [Height] */
// determine what the variable "gridz" applies to based on your use case
gridz_define = 0; // [0:gridz is the height of bins in units of 7mm increments - Zack's method,1:gridz is the internal
// height in millimeters, 2:gridz is the overall external height of the bin in millimeters]
// overrides internal block height of bin (for solid containers). Leave zero for default height. Units: mm
height_internal = 0;
// snap gridz height to nearest 7mm increment
enable_zsnap = false;

/* [Features] */
// the type of tabs
style_tab = 1; //[0:Full,1:Auto,2:Left,3:Center,4:Right,5:None]
// how should the top lip act
style_lip = 0; //[0: Regular lip, 1:remove lip subtractively, 2: remove lip and retain height]
// scoop weight percentage. 0 disables scoop, 1 is regular scoop. Any real number will scale the scoop.
scoop = 1; //[0:0.1:1]
// only cut magnet/screw holes at the corners of the bin to save uneccesary print time
only_corners = false;

/* [Base] */
style_hole = 3; // [0:no holes, 1:magnet holes only, 2: magnet and screw holes - no printable slit, 3: magnet and screw
// holes - printable slit]
// number of divisions per 1 unit of base along the X axis. (default 1, only use integers. 0 means automatically guess
// the right division)
div_base_x = 0;
// number of divisions per 1 unit of base along the Y axis. (default 1, only use integers. 0 means automatically guess
// the right division)
div_base_y = 0;

// ===== IMPLEMENTATION ===== //




























//color("tomato")
//{
//    gridfinityInit(gridx, gridy, height(gridz, gridz_define, style_lip, enable_zsnap));
//    gridfinityBase(gridx, gridy, l_grid, div_base_x, div_base_y, style_hole, only_corners = only_corners);
//}
//
//module gridfinityInit(gridx, gridy, h)
//{
//    $gxx = gridx;
//    $gyy = gridy;
//    $dh = h;
//    $dh0 = 0;
//    color("tomato")
//    {
//        difference()
//        {
//            color("firebrick") up(h_base)
//                cuboid([ gridx * grid_length, gridy * grid_length, h ], rounding = r_base, edges = "Z", anchor = BOT);
//            if (divx > 0 && divy > 0)
//                cutEqual(divx = divx, divy = divy, style_tab = style_tab, scoop_weight = scoop);
//        }
//        block_wall(gridx, gridy, grid_length);
//    }
//}
//
//module block_wall(gx, gy, l) {
//    translate([0,0,h_base]) 
//    sweep_rounded(gx*l-2*r_base-0.5-0.001, gy*l-2*r_base-0.5-0.001)
//    {
//            if (style_lip == 0)
//                color_this("green") profile_wall();
//            else
//                profile_wall2();
//        }
//}
//
//
//
//module cutEqual(divx, divy, style_tab = 1, scoop_weight = 1)
//{
//    for (i = [0:divx - 1])
//        for (j = [0:divy - 1])
//            cut(x = i * gridx / divx, y = j * gridy / divy, w = gridx / divx, h = gridy / divy, t = style_tab,
//                s = scoop_weight);
//}
//
//module cut(x, y, w, h, t, s)
//{
//    down(height(gridz, gridz_define, style_lip, enable_zsnap) + h_base) cut_move(x, y, w, h)
//        block_cutter(min(x, gridx), min(y, gridy), min(w, gridx - x), min(h, gridy - y), t, s);
//}
//
//module block_cutter(x,y,w,h,t,s) {
//    
//}
//
//
//$gxx = gridx;
//$gyy = gridy;
//$dh = height(gridz, gridz_define, style_lip, enable_zsnap);
//$dh0 = 0;
//
//// w scales in x direction
//// h scales in y direction
////block_cutter(x = 0, y = 0, w = 1, h = 1, t = style_tab, s = scoop);
//
//!profile_wall();