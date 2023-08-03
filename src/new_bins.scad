include <BOSL2/rounding.scad>
include <BOSL2/std.scad>

$fn = $preview ? 30 : 30;

// gridfinity standard
general_standard_path = "../model/gridfinity_standard/general.json";
bin_standard_path = "../model/gridfinity_standard/bin.json";
lip_standard_path = "../model/gridfinity_standard/lip.json";
upper_standard_path = "../model/gridfinity_standard/upper.json";
bottom_standard_path = "../model/gridfinity_standard/bottom.json";
block_standard_path = "../model/gridfinity_standard/block.json";
front_standard_path = "../model/gridfinity_standard/front.json";

// helpers
math_constants_path = "../model/math_constants.json";

// changeables
input_path = "../model/gridfinity_input.json";

// gridfinity standard
standard = import(general_standard_path);
bin = import(bin_standard_path);
lip = import(lip_standard_path);
upper = import(upper_standard_path);
bottom = import(bottom_standard_path);
block = import(block_standard_path);
front = import(front_standard_path);

// alternatives
// lipless
lipless_lip = import("../model/gridfinity_alternatives/lipless/lip.json");
lipless_upper = import("../model/gridfinity_alternatives/lipless/upper.json");

// label
closeable_label = import("../model/gridfinity_alternatives/closeable/label.json");

// helpers
math = import(math_constants_path);
printer = import("../model/printer/gridfinity.json");

// changeables
input = import(input_path);

function lip_height() = lip.height1 + lip.height2 + lip.height3;

function x_length() = standard.length * input.units.x;
function y_length() = standard.length * input.units.y;
function total_height() = standard.length * input.units.z + bin.lip_height;

gridfinity_bin();

module gridfinity_bin()
{
    difference()
    {
        datum_plane() position(BOT) lip(lip) position(BOT) upper(upper, closeable_label) position(BOT) middle()
            position(BOT) bottom()
        {
            position(FWD + BOT) front(front);
            position(BOT) block(block);
        }

        clearance();
    }
}

module front(model)
{
    slope_height = bin.height_unit * (input.units.z - 1);
    slope_radius = min(slope_height, model.slope_radius);
    front_length = x_length() - 2 * bin.wall_thickness;

    back(bin.wall_thickness) wall() attach(BACK, FRONT) slope();

    module wall()
    {
        cuboid(size = [ front_length, model.spacer_distance, slope_height ], anchor = BOT + FWD) children();
    }

    module slope()
    {
        diff() cuboid(size = [ front_length, slope_radius, slope_radius ]) position(BOT + BACK) tag("remove")
            xcyl(h = front_length, r = slope_radius, anchor = BOT);
    }
}

module clearance()
{
    up(bin.lip_height)
        rect_tube(h = total_height(), size = [ x_length() + 2 * math.epsilon, y_length() + 2 * math.epsilon ],
                  wall = standard.clearance, rounding = standard.outer_rounding, anchor = TOP);
}

module block(model)
{
    //TODO: use 3 solids instead of solid - 3 profiles
    main(model);

    module profile(model = model)
    {
        down(2 * math.epsilon) first_part() attach(BOT, TOP, math.epsilon) second_part() attach(BOT, TOP, math.epsilon)
            third_part();

        module first_part()
        {
            profile_part(height = model.height1, bottom_width = model.width1, top_width = model.width0 + math.epsilon)
                children();
        }

        module second_part()
        {
            profile_part(height = model.height2, bottom_width = model.width2, top_width = model.width1) children();
        }

        module third_part()
        {
            profile_part(height = model.height3, bottom_width = model.width3, top_width = model.width2) children();
        }

        module profile_part(height, bottom_width, top_width)
        {
            if (height > 0 && bottom_width > 0 && top_width > 0)
            {
                rect_tube(h = height, size = standard.length, isize1 = standard.length - 2 * bottom_width,
                          isize2 = standard.length - 2 * top_width, rounding = standard.outer_rounding, anchor = TOP)
                    children();
            }
            else
            {
                children();
            }
        }
    }

    module main(model)
    {
        diff("hole profile") top() attach(BOT, TOP)
            grid_copies(spacing = standard.length, n = [ input.units.x, input.units.y ]) center()
        {
            attach(TOP, BOT) tag("hole") hole_distributor() hole();
            position(TOP) tag("profile") profile(model);
        }

        module top()
        {
            cuboid(size = [ x_length(), y_length(), model.height0 ], rounding = standard.outer_rounding, edges = "Z",
                   anchor = TOP) children();
        }

        module center()
        {
            cuboid(size = [ standard.length, standard.length, model.height1 + model.height2 + model.height3 ],
                   rounding = standard.outer_rounding, edges = "Z", anchor = TOP) children();
        }

        module hole_distributor()
        {
            down(bin.height_unit) grid_copies(spacing = 26, size = [ standard.length, standard.length ]) children();
        }

        module hole()
        {
            union()
            {
                screw_hole();
                magnet_hole();
            }
        }

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

module bottom()
{
    first_part() position(BOT) second_part() children();

    module first_part()
    {
        wall_part(height = bottom.height1, bottom_width = bin.wall_thickness, top_width = bin.wall_thickness)
            children();
    }

    module second_part()
    {
        cuboid(size = [ x_length(), y_length(), bottom.height2 ], rounding = standard.outer_rounding, edges = "Z")
            children();
    }
}

module middle()
{
    if (input.units.z > 3)
    {
        first_part() children();
    }
    else
    {
        attachable(orient = DOWN)
        {
            fake_attachable();
            children();
        }
    }

    module first_part()
    {
        height = bin.height_unit * (input.units.z - 3);
        wall_part(height = height, bottom_width = bin.wall_thickness, top_width = bin.wall_thickness) children();
    }
}

module upper(model, label)
{
    if (is_def(label))
    {
        upper_with_label() children();
    }
    else
    {
        upper_without_label() children();
    }

    module upper_with_label()
    {
        label_height = label.label.z + label.cover.z + label.clearance.z + label.holder.z;
        first_part() attach(BOT, TOP) second_part() attach(BOT, TOP) third_part() children();

        module first_part()
        {
            label_y_length = y_length() - 2 * model.width0;
            diff("wall_hole") wall_part(height = label_height, bottom_width = model.width1, top_width = model.width0)
            {
                position(LEFT + TOP) right(model.width0) single_holder(LEFT);
                position(RIGHT + TOP) left(model.width0) single_holder(RIGHT);
                position(BOT) label();
                position(RIGHT + TOP + BACK) down(label.holder.z) fwd(model.width0) tag("wall_hole") wall_hole();
                children();
            }

            module label()
            {
                hole_x = x_length() - 2 * model.width0 - 2 * label.holder.x;
                diff(remove = "hole indent", keep = "string") label_plane()
                {
                    position(FRONT) tag("hole") label_hole();
                    position(BOT + FRONT) tag("indent") label_indent();
                    position(BOT + FRONT) tag("string") label_string();
                }

                module label_plane()
                {
                    cuboid(size = [ x_length(), y_length(), label.label.z ], rounding = standard.outer_rounding,
                           edges = "Z", anchor = BOT) children();
                }

                module label_indent()
                {

                    cuboid(size = [ hole_x, y_length(), 2 * printer.layer_height ], anchor = BOT + FWD);
                }

                module label_hole()
                {
                    back(model.width0)
                        cuboid(size = [ hole_x, label.hole.y, label.label.z + math.epsilon ], anchor = FWD);
                }

                module label_string()
                {
                    cuboid(size = [ 2 * printer.line_width, y_length(), 2 * printer.layer_height ], anchor = BOT + FWD);
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
                    spacer_x_length = (x_length() - 2 * model.width0 - label.cover.x - label.clearance.x) / 2;
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
        first_part() attach(BOT, TOP) second_part() attach(BOT, TOP) third_part() children();

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
    first_part() attach(BOT, TOP) second_part() attach(BOT, TOP) third_part() children();

    module first_part()
    {
        path = rect(size = [ x_length() - 2 * model.width1, y_length() - 2 * model.width1 ],
                    rounding = standard.outer_rounding - model.width1);
        shape = safe_rounded_triangle_path(width = model.width1, height = model.height1,
                                           radius = model.upper_rounding_radius);
        if (is_path(shape) == true)
        {
            path_sweep(shape = shape, path = path, closed = true, anchor = TOP) children();
        }
        else
        {
            attachable()
            {
                fake_attachable();
                children();
            }
        };
    }

    module second_part()
    {
        wall_part(height = model.height2, bottom_width = model.height2, top_width = model.height1) children();
    }

    module third_part()
    {
        wall_part(height = model.height3, bottom_width = model.width3, top_width = model.width2) children();
    }
}

module wall_part(height, bottom_width, top_width)
{
    if (height > 0 && bottom_width > 0 && top_width > 0)
    {
        rect_tube(h = height, size = [ x_length(), y_length() ],
                  isize1 = [ x_length() - 2 * bottom_width, y_length() - 2 * bottom_width ],
                  isize2 = [ x_length() - 2 * top_width, y_length() - 2 * top_width ],
                  rounding = standard.outer_rounding, anchor = TOP) children();
    }
    else
    {
        children();
    }
}

function safe_rounded_triangle_path(width, height, radius) = (width > 0 && height > 0)
                                                                 ? rounded_triangle_path(width = width, height = height,
                                                                                         radius = radius)
                                                                 : [[ 0, 0 ]];

function rounded_triangle_path(width, height,
                               radius) = let(straight_tip = [ [ 0, 0 ], [ width, 0 ], [ width, height ] ])
    round_corners(straight_tip, radius = [ 0, 0, radius ]);

module fake_attachable()
{
    % cube(math.epsilon);
}

module datum_plane()
{
    cube(math.epsilon) children();
}