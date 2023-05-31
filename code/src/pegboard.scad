include <BOSL2/rounding.scad>
include <BOSL2/std.scad>

dock_path = "../model/pegboard_dock_hooks.json";
dock = import(dock_path);

module item()
{
    pinboard() attach(TOP,BOT) dock();
}

module dock()
{
    xcopies(spacing = dock.spacing, n = dock.amount)
    {
        hook(type = dock.hook_type, index = $idx);
    }
}

module hook(type, index){
    if (type == "skewed_hook"){
        skewed_hook(index = index);
    } else {
        echo(type);
        assert(false, "should not have reached here");
    }
}

module skewed_hook(index)
{
    skew(ayz = -20) difference(){
        zcyl(h = dock.heights[index], d = dock.diameters[index]);
        nail(h = dock.heights[index], d = dock.diameters[index]-4*wall_thickness);
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
        color_this("green") zcyl(h = 2 * wall_thickness, d = pin_diameter) children();
    }
    else
    {
        color_this("red") linear_sweep(region = octagon(id = pin_diameter, realign = true), h = 2 * wall_thickness, center = true)
            children();
    }
}

module pinboard_position()
{
    up(0.5 * board_thickness) tag_conv_hull(tag = "board", keep = "pin")
        grid_copies(spacing = hole_spacing, n = [4,2]) children();
}

module pinboard()
{
    attachable(size = [ holder_total_x + pin_diameter, holder_height + pin_diameter, 2 * wall_thickness + board_thickness ])
    {
        union()
        {
            pinboard_position() pinboard_cylinders($row == 0) attach(BOT, BOT)
            {
                tag("pin") pin($row == 0);
            }
        }
        children();
    };
}