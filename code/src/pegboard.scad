include <BOSL2/rounding.scad>
include <BOSL2/std.scad>

dock_path = "../model/pegboard_dock_hooks.json";
dock = import(dock_path);

module item()
{
    pinboard() show_anchors();
}

module dock()
{

    xcopies(spacing = dock.spacing, n = dock.amount)
    {
        skewed_hook();
    }
}

module skewed_hook()
{
    cylinder(h = dock_height, d = dock_diameter);
}

module hook_position()
{
    translate([ -outer_wall_x_distance, 0, -0.5 * holder_total_z ]) rotate([ 0, -90, 0 ]) rotate([ 0, 20, 0 ])
        children();
}

module hook_offset()
{
    difference()
    {
        hook_position() translate([ 0, 0, -dock_height ]) cylinder(h = dock_height, d = dock_diameter);
        translate([ 0, -0.5 * arbitrary_big_value, 0.5 * arbitrary_big_value ]) pinboard_position()
            cube(arbitrary_big_value);
    }
}

module hook()
{
    hook_position()
    {
        cylinder(h = dock_height, d = dock_diameter);
    }
}

module clipped_pin()
{
    clearance = wall_line_width;
    difference()
    {
        tag("pin") cylinder(d1 = pin_diameter, d2 = pin_diameter / 2, h = board_thickness + clearance, anchor = CENTER,
                            $fn = 50) position(TOP + FWD)
        {
            conv_hull()
            {
                color_this("green") cuboid(size =
                                               [
                                                   pin_diameter / 2,
                                                   0.5 * (board_thickness * 0.5 + pin_diameter),
                                                   pin_diameter / 4,
                                               ],
                                           anchor = BACK + BOTTOM);

                cylinder(h = pin_diameter / 4, d = pin_diameter / 2, anchor = FWD + BOTTOM);
            }
        }
        nail(h = board_thickness + clearance, d = pin_diameter - 4 * wall_thickness,
             d2 = pin_diameter / 2 - 4 * wall_thickness);
    }
}

module nail(h, d, d2)
{
    second_diameter = (is_def(d2)) ? max(d2, 0) : d;
    color_this("blue") cylinder(d1 = d, d2 = second_diameter, h = h, anchor = CENTER);
}

module straight_pin()
{
    difference()
    {
        linear_sweep(region = octagon(id = pin_diameter, realign = true), h = board_thickness);
        nail(h = board_thickness, d = pin_diameter - 4 * wall_thickness);
    }
}

module pin(clip)
{
    if (clip)
    {
        clipped_pin();
    }
    else
    {
        straight_pin();
    }
}

module pinboard_cylinders(clipped)
{
    if (clipped)
    {
        color_this("green") cylinder(h = 2 * wall_thickness, d = pin_diameter) children();
    }
    else
    {
        color_this("red") linear_sweep(region = octagon(id = pin_diameter, realign = true), h = 2 * wall_thickness)
            children();
    }
}

module pinboard_position()
{
    down(wall_thickness + board_thickness/2) tag_conv_hull(tag = "board", keep = "pin children")
        grid_copies(spacing = hole_spacing, size = [ holder_total_x + epsilon, holder_height + epsilon ]) children();
}

module pinboard()
{
    attachable(size = [ holder_total_x + epsilon + pin_diameter, holder_height + epsilon + pin_diameter, 2 * wall_thickness + board_thickness ])
    {
        union()
        {
            pinboard_position() pinboard_cylinders($row == 0) attach(TOP, BOT)
            {
                tag("pin") pin($row == 0);
            }
        }
        children();
    };
}