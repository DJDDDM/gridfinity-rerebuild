include <BOSL2/rounding.scad>
include <BOSL2/std.scad>

$fn = $preview ? 30 : 30;

// gridfinity standard
general_standard_path = "../model/gridfinity_standard/general.json";
bin_standard_path = "../model/gridfinity_standard/bin.json";
lip_standard_path = "../model/gridfinity_standard/lip.json";
block_standard_path = "../model/gridfinity_standard/block.json";
front_standard_path = "../model/gridfinity_standard/front.json";

// helpers
math_constants_path = "../model/math_constants.json";

// changeables
input_path = "../model/gridfinity_input.json";

// gridfinity standard
standard = import(general_standard_path);
bin = import(bin_standard_path);
standard_lip = import("../model/gridfinity_standard/lip.json");
standard_upper = import("../model/gridfinity_standard/upper.json");
standard_bottom = import("../model/gridfinity_standard/bottom.json");
standard_block = import("../model/gridfinity_standard/block.json");
standard_front = import("../model/gridfinity_standard/front.json");

// alternatives
// lipless
lipless_lip = import("../model/gridfinity_alternatives/lipless/lip.json");
lipless_upper = import("../model/gridfinity_alternatives/lipless/upper.json");

// closeable
closeable_label = import("../model/gridfinity_alternatives/closeable/label.json");

// flat
flat_bottom = import("../model/gridfinity_alternatives/flat/bottom.json");
flat_block = import("../model/gridfinity_alternatives/flat/block.json");

// hollow
hollow_block = import("../model/gridfinity_alternatives/hollow/block.json");

// helpers
math = import(math_constants_path);
printer = import("../model/printer/gridfinity.json");

// input
input = import(input_path);

lip = standard_lip;
label = closeable_label;
upper = standard_upper;
bottom = flat_bottom;
front = standard_front;
block = hollow_block;

// TODO: use variables instead of 0 parameter functions for performance
function lip_height() = lip.height1 + lip.height2 + lip.height3;
function x_length() = standard.length * input.units.x - 2 * standard.clearance;
function y_length() = standard.length * input.units.y - 2 * standard.clearance;
function total_height() = (bin.height_unit * input.units.z) + lip_height();

lip_height = lip_height();
x_length = x_length();
y_length = y_length();
total_height = total_height();
outer_rounding = standard.outer_rounding - standard.clearance;

// start = TOP; end = BOT
start_lip = 0;
start_upper = start_lip + lip_height;
start_middle = (input.units.z > 3) ? start_upper + bin.height_unit * (input.units.z - 3) : start_upper;
start_bottom = (input.units.z > 2) ? start_middle + bin.height_unit : start_middle;
start_block = start_bottom + bin.height_unit;

end_lip = start_upper;
end_upper = start_middle;
end_middle = start_bottom;
end_bottom = start_block;
end_block = start_block + bin.height_unit;

gridfinity_bin();

module gridfinity_bin()
{
    down(start_lip) lip(lip);
    down(start_upper) upper(upper, label);
    down(start_middle) middle();
    down(start_bottom) bottom(bottom);
    down(start_block) block(block);
    anti_clearance();
}

module front(model, additional_height = 0, additional_length = 0)
{
    slope_height = bin.height_unit * (input.units.z - 1) + additional_height;
    echo(slope_height);
    slope_radius = slope_height;
    front_length = x_length - 2 * bin.wall_thickness + additional_length;

    back(bin.wall_thickness) up(slope_height) wall() position(BACK + TOP) slope();

    module wall()
    {
        cuboid(size = [ front_length, model.spacer_distance, printer.skin.height ], anchor = TOP + FWD) children();
    }

    module slope()
    {
        back(slope_radius + printer.skin.height) render() difference()
        {
            pie_slice(h = front_length, r = slope_radius + printer.skin.height, ang = 90, orient = LEFT, spin = 180,
                      anchor = CENTER);
            pie_slice(h = front_length, r = slope_radius, ang = 90, orient = LEFT, spin = 180, anchor = CENTER);
        }
    }
}

// This is needed for fixing mesh errors resulting in non flat walls
module anti_clearance()
{
    wall_part(height = start_block, bottom_width = bin.wall_thickness, top_width = bin.wall_thickness);
}

module block(model)
{
    if (is_undef(model.type))
        standard_block() children();
    else if (model.type == "standard")
        standard_block() children();
    else if (model.type == "flat")
        standard_block() children();
    else if (model.type == "hollow")
        hollow_block() children();

    module standard_block()
    {
        diff("hole") top() position(BOT) grid_copies(spacing = standard.length, n = [ input.units.x, input.units.y ])
            center() position(BOT) tag("hole") grid_copies(spacing = 26, size = [ standard.length, standard.length ])
                hole();

        module top()
        {
            if (is_undef(model.type))
                standard_top() children();
            else if (model.type == "standard")
                standard_top() children();
            else if (model.type == "flat")
                flat_top() children();

            module standard_top()
            {
                cuboid(size = [ x_length, y_length, model.height0 ], rounding = outer_rounding, edges = "Z",
                       anchor = TOP) children();
            }

            module flat_top()
            {
                // tag is needed for z fighting
                height = model.height0 - printer.skin.height;
                wall_part(height = height, bottom_width = bin.wall_thickness, top_width = bin.wall_thickness)
                    position(BOT) tag("keep") skin()
                {
                    position(BOT + FWD) front(front, additional_height = model.height0);
                    tag("") children();
                }

                module skin()
                {
                    tag("keep") cuboid(size = [ x_length, y_length, printer.skin.height ], rounding = outer_rounding,
                                       edges = "Z", anchor = TOP) tag("") children();
                }
            }
        }

        module center()
        {
            center_part(height = model.height1, top_width = model.width0, bottom_width = model.width1) position(BOT)
                center_part(height = model.height2, top_width = model.width1, bottom_width = model.width2) position(BOT)
                    center_part(height = model.height3, top_width = model.width2, bottom_width = model.width3)
                        children();

            module center_part(height, bottom_width, top_width)
            {
                full = [ standard.length, standard.length ];
                prismoid(h = height, size1 = full - 2 * [ bottom_width, bottom_width ],
                         rounding1 = standard.outer_rounding - bottom_width, size2 = full - 2 * [ top_width, top_width ],
                         rounding2 = standard.outer_rounding - top_width, anchor = TOP) children();
            }
        }

        module hole()
        {
            screw_hole();
            magnet_hole();
            module screw_hole()
            {
                zcyl(h = model.screw_depth, d = model.screw_diameter, anchor = BOT);
            }

            module magnet_hole()
            {
                zcyl(h = model.magnet_depth, d = model.magnet_diameter, anchor = BOT);
            }
        }
    }

    module hollow_block()
    {
        hollow_part(height = model.height0, bottom_width = model.width0, top_width = model.width0);
        down(model.height0) hollow_part(height = model.height1, bottom_width = model.width1, top_width = model.width0);
        down(model.height0 + model.height1)
            hollow_part(height = model.height2, bottom_width = model.width2, top_width = model.width1);
        down(model.height0 + model.height1 + model.height2)
            full_part(height = model.height3, bottom_width = model.width3, top_width = model.width2) position(UP + FWD)
                fwd(model.width3) front(front, additional_height = model.height0 + model.height1 + model.height2,
                                        additional_length = -2 * (model.width3 - bin.wall_thickness));

        module hollow_part(height, bottom_width, top_width)
        {
            bottom_val = max(bottom_width - standard.clearance, 0);
            top_val = max(top_width - standard.clearance, 0);
            full = [ x_length, y_length];
            bottom = [bottom_val, bottom_val];
            top = [top_val, top_val];
            rect_tube(h = height, size1 =  full - 2 * bottom,
                      rounding1 = outer_rounding - bottom_val,
                      size2 = full - 2 * top,
                      rounding2 = outer_rounding - top_val, wall = bin.wall_thickness, anchor = TOP);
        }

        module full_part(height, bottom_width, top_width)
        {
            prismoid(h = height, size1 = [ x_length + 2 * standard.clearance, y_length + 2 * standard.clearance] - 2 * [ bottom_width, bottom_width ],
                     rounding1 = standard.outer_rounding - bottom_width,
                     size2 = [ x_length + 2 * standard.clearance, y_length + 2 * standard.clearance ] - 2 * [ top_width, top_width ],
                     rounding2 = standard.outer_rounding - top_width, anchor = TOP) children();
        }
    }
}

module bottom(model)
{
    if (is_undef(model.type))
        standard_bottom();
    else if (model.type == "standard")
        standard_bottom();
    else if (model.type == "flat")
        flat_bottom();

    module flat_bottom()
    {
        height = (input.units.z >= 3) ? bin.height_unit : 0;
        wall_part(height = height, bottom_width = bin.wall_thickness, top_width = bin.wall_thickness);
    }

    module standard_bottom()
    {
        first_part() position(BOT) second_part() position(BOT + FWD) front(front);

        module first_part()
        {
            wall_part(height = model.height1, bottom_width = bin.wall_thickness, top_width = bin.wall_thickness)
                children();
        }

        module second_part()
        {
            cuboid(size = [ x_length(), y_length(), model.height2 ], rounding = standard.outer_rounding, edges = "Z")
                children();
        }
    }
}

module middle()
{
    wall_part(height = bin.height_unit * (input.units.z - 3), bottom_width = bin.wall_thickness,
              top_width = bin.wall_thickness);
}

module upper(model, label)
{
    if (is_def(label))
    {
        upper_with_label();
    }
    else
    {
        upper_without_label();
    }

    module upper_with_label()
    {
        label_height = label.label.z + label.cover.z + label.clearance.z + label.holder.z;
        first_part() position(BOT) second_part() position(BOT) third_part();

        module first_part()
        {
            width = model.width0 - standard.clearance;

            label_x_length = x_length - 2 * width;
            label_y_length = y_length - 2 * width;

            diff("wall_hole") wall_part(height = label_height, bottom_width = model.width1, top_width = model.width0)
            {
                position(LEFT + TOP) right(width) single_holder(LEFT);
                position(RIGHT + TOP) left(width) single_holder(RIGHT);
                position(BOT) label();
                position(RIGHT + TOP + BACK) down(label.holder.z) fwd(width + (label.cover.y / 2)) tag("wall_hole")
                    wall_hole();
                children();
            }

            module label()
            {
                hole_x = label_x_length - 2 * label.holder.x;
                diff(remove = "hole indent", keep = "string") label_plane()
                {
                    position(FRONT) tag("hole") label_hole();
                    position(BOT + FRONT) tag("indent") label_indent();
                    position(BOT + FRONT) tag("string") label_string();
                }

                module label_plane()
                {
                    cuboid(size = [ x_length, y_length, label.label.z ], rounding = outer_rounding, edges = "Z",
                           anchor = BOT) children();
                }

                module label_indent()
                {

                    cuboid(size = [ hole_x, y_length, 2 * printer.layer_height ], anchor = BOT + FWD);
                }

                module label_hole()
                {
                    back(width) cuboid(size = [ hole_x, label.hole.y, label.label.z + math.epsilon ], anchor = FWD);
                }

                module label_string()
                {
                    cuboid(size = [ 2 * printer.line_width, y_length, 2 * printer.layer_height ], anchor = BOT + FWD);
                }
            }

            module wall_hole()
            {
                cube(size = [ upper.width1, label.cover.y, label.cover.z ] + label.clearance,
                     anchor = RIGHT + TOP + BACK);
            }

            module single_holder(pos)
            {
                cuboid(size = [ label.holder.x, label_y_length, label.holder.z ], anchor = TOP + pos)
                {
                    position(BOT - pos) support();
                    position(BOT + pos) spacer();
                }

                module spacer()
                {
                    spacer_x_length = (label_x_length - label.cover.x - label.clearance.x) / 2;
                    spacer_height = label.cover.z + label.clearance.z;
                    cuboid(size = [ spacer_x_length, label_y_length, spacer_height ], anchor = TOP + pos);
                }

                module support()
                {
                    down(printer.support.offset.z) cuboid(
                        [
                            printer.support.line_width, label_y_length - 3 * printer.support.offset.y,
                            label.cover.z + label.clearance.z - 2 * printer.support.offset.z
                        ],
                        anchor = TOP - pos);
                }
            }
        }

        module second_part()
        {
            height = min(model.height2, bin.height_unit - label_height);
            wall_part(height = height, bottom_width = model.width2, top_width = model.width1) children();
        }

        module third_part()
        {
            height = min(model.height3, bin.height_unit - label_height - model.height2);
            wall_part(height = height, bottom_width = model.width3, top_width = model.width2) children();
        }
    }

    module upper_without_label()
    {
        first_part() attach(BOT, TOP) second_part() attach(BOT, TOP) third_part();

        module first_part()
        {
            wall_part(height = model.height1, bottom_width = model.width1, top_width = model.width0) children();
        }

        module second_part()
        {
            wall_part(height = model.height2, bottom_width = model.width2, top_width = model.width1) children();
        }

        module third_part()
        {
            wall_part(height = model.height3, bottom_width = model.width3, top_width = model.width2) children();
        }
    }
}

module lip(model)
{
    first_part();
    down(model.height1) second_part();
    down(model.height1 + model.height2) third_part();

    module first_part()
    {
        width = model.width1 - standard.clearance;
        height = model.height1;
        rounding = model.upper_rounding_radius;
        path = rect(size = [ x_length - 2 * width, y_length - 2 * width ], rounding = outer_rounding - width);
        shape = safe_rounded_triangle_path(width = width, height = height, radius = rounding);
        // the height of the rounded shape is to low, so we need to scale it back to its original size
        scaling_factor = height / last(shape).y;
        corrected_shape = scale([ 1, scaling_factor, 1 ], p = shape);

        if (is_path(corrected_shape) == true)
        {
            path_sweep(shape = corrected_shape, path = path, closed = true, anchor = TOP);
        }
    }

    module second_part()
    {
        wall_part(height = model.height2, bottom_width = model.height2, top_width = model.height1);
    }

    module third_part()
    {
        wall_part(height = model.height3, bottom_width = model.width3, top_width = model.width2);
    }
}

module wall_part(height, bottom_width, top_width)
{
    if (height > 0 && bottom_width > standard.clearance && top_width > standard.clearance)
    {
        rect_tube(
            h = height, size = [ x_length(), y_length() ],
            isize1 =
                [
                    x_length() - 2 * (bottom_width - standard.clearance),
                    y_length() - 2 * (bottom_width - standard.clearance)
                ],
            isize2 =
                [
                    x_length() - 2 * (top_width - standard.clearance), y_length() - 2 * (top_width - standard.clearance)
                ],
            rounding = outer_rounding, anchor = TOP) children();
    }
    else
    {
        attachable()
        {
            fake_attachable();
            children();
        }
    }
}

function safe_rounded_triangle_path(width, height, radius) = (width > 0 && height > 0)
                                                                 ? rounded_triangle_path(width = width, height = height,
                                                                                         radius = radius)
                                                                 : [[ 0, 0 ]];

function rounded_triangle_path(width, height,
                               radius) = let(straight_tip = [ [ 0, 0 ], [ width, 0 ], [ width, height ] ])
    round_corners(straight_tip, radius = [ 0, 0, radius * 1 ]);

module fake_attachable()
{
    % cube(math.epsilon);
}

module datum_plane()
{
    cube(math.epsilon) children();
}