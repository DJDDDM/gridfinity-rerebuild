include <BOSL2/rounding.scad>
include <BOSL2/std.scad>

dock_path = "../model/pegboard_dock_hooks.json";
printer_path = "../model/printer_settings.json";
pinboard_path = "../model/pegboard_pinboard.json";
pegboard_standard_path =  "../model/pegboard_standard.json";

dock = import(dock_path);
printer = import(printer_path);
pinboard = import(pinboard_path);
pegboard_standard = import(pegboard_standard_path);

$fn = printer.fn;
item();

module item()
{
    pinboard_board() attach(TOP,BOT) dock();
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
        nail(h = dock.heights[index], d = dock.diameters[index]-4*printer.wall_thickness);
    }

}

module clipped_pin()
{
    clearance = 2 * printer.skin_line_height;
    difference()
    {
        tag("pin") cylinder(d1 = pinboard.pin_diameter, d2 = pinboard.pin_diameter / 2, h = pegboard_standard.board_thickness + clearance, anchor = CENTER) position(TOP + FWD)
        {
            conv_hull()
            {
                color_this("green") cuboid(size =
                                               [
                                                   pinboard.pin_diameter / 2,
                                                   0.5 * (pegboard_standard.board_thickness * 0.5 + pinboard.pin_diameter),
                                                   pinboard.pin_diameter / 4,
                                               ],
                                           anchor = BACK + BOTTOM);

                cylinder(h = pinboard.pin_diameter / 4, d = pinboard.pin_diameter / 2, anchor = FWD + BOTTOM);
            }
        }
        nail(h = pegboard_standard.board_thickness + clearance, d = pinboard.pin_diameter - 4 * printer.wall_thickness,
             d2 = pinboard.pin_diameter / 2 - 4 * printer.wall_thickness);
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
        linear_sweep(region = octagon(id = pinboard.pin_diameter, realign = true), h = pegboard_standard.board_thickness);
        nail(h = pegboard_standard.board_thickness, d = pinboard.pin_diameter - 4 * printer.wall_thickness);
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
        color_this("green") zcyl(h = 2 * printer.wall_thickness, d = pinboard.pin_diameter) children();
    }
    else
    {
        color_this("red") linear_sweep(region = octagon(id = pinboard.pin_diameter, realign = true), h = 2 * printer.wall_thickness, center = true)
            children();
    }
}

module pinboard_position()
{
    up(0.5 * pegboard_standard.board_thickness) tag_conv_hull(tag = "board", keep = "pin")
        grid_copies(spacing = pegboard_standard.hole_spacing, n = [pinboard.columns,pinboard.rows]) children();
}

module pinboard_board()
{
    attachable(size = [ pegboard_standard.hole_spacing * pinboard.columns + pinboard.pin_diameter, pegboard_standard.hole_spacing * pinboard.columns + pinboard.pin_diameter, 2 * printer.wall_thickness + pegboard_standard.board_thickness ])
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