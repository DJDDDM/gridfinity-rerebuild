include <BOSL2/rounding.scad>
include <BOSL2/std.scad>

$fn = 30;

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
printer = import("../model/printer/fine.json");

// changeables
input = import(input_path);

function lip_height() = lip.height1 + lip.height2 + lip.height3;

function x_length() = standard.length * input.units.x;
function y_length() = standard.length * input.units.y;
function total_height() = standard.length * input.units.z + bin.lip_height;

//gridfinity_bin();

upper(upper, closeable_label);

module gridfinity_bin()
{
    difference()
    {
        datum_plane() attach(BOT, TOP) lip(lip) attach(BOT, TOP) upper(upper, closeable_label) attach(BOT, TOP) middle()
            attach(BOT, TOP) bottom()
        {
            front(model = front);
            block(model = block);
        }

        clearance();
    }
}

module front(model)
{
    offset_to_grid = (y_length() - standard.length) / 2;
    offset_to_outer_backwall = bin.wall_thickness + model.spacer_distance;
    back(offset_to_outer_backwall - offset_to_grid) up(model.slope_offset) slope();

    module slope()
    {
        front_length = x_length() - 2 * bin.wall_thickness;
        difference()
        {
            union()
            {
                cuboid(size = [ front_length, model.slope_radius, model.slope_radius ],
                       anchor = BOT + BACK) attach(FRONT, BACK) fwd(model.slope_offset)
                    cuboid(size = [ front_length, model.spacer_distance, height_for_units(units = input.units.z - 1) ]);
            }
            cylinder(h = front_length, r = model.slope_radius, spin = 180, orient = LEFT, anchor = CENTER + RIGHT);
        }
    }
}

function height_for_units(units) = bin.height_unit * units;

module clearance()
{
    up(bin.lip_height)
        rect_tube(h = total_height(), size = [ x_length() + 2 * math.epsilon, y_length() + 2 * math.epsilon ],
                  wall = standard.clearance, rounding = standard.outer_rounding, anchor = TOP);
}

module block(model)
{
    main(model = model);

    module profile(model = model)
    {
        down(model.height0) first_part();
        down(model.height0 + model.height1) second_part();
        down(model.height0 + model.height1 + model.height2) third_part();

        module first_part()
        {
            profile_part(height = model.height1 + math.epsilon, bottom_width = model.width1,
                         top_width = model.width0 + math.epsilon) children();
        }

        module second_part()
        {
            profile_part(height = model.height2 + math.epsilon, bottom_width = model.width2, top_width = model.width1)
                children();
        }

        module third_part()
        {
            profile_part(height = model.height3 + math.epsilon, bottom_width = model.width3, top_width = model.width2)
                children();
        }

        module profile_part(height, bottom_width, top_width)
        {
            if (height > 0 && bottom_width > 0 && top_width > 0)
            {
                rect_tube(h = height, size = standard.length, isize1 = standard.length - bottom_width,
                          isize2 = standard.length - top_width, rounding = standard.outer_rounding, anchor = TOP)
                    children();
            }
            else
            {
                children();
            }
        }
    }

    module main(model = model)
    {
        grid_copies(spacing = standard.length, n = [ input.units.x, input.units.y ]) diff("hole profile") solid()
        {
            attach(TOP, BOT) tag("hole") hole_distributor() hole();
            position(TOP) tag("profile") profile(model);
        }

        module solid()
        {
            cuboid(size = [ standard.length - math.epsilon, standard.length - math.epsilon, bin.height_unit ],
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
    first_part() attach(BOT, TOP) second_part() children();

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
    first_part() children();

    module first_part()
    {
        wall_part(height = bin.height_unit, bottom_width = bin.wall_thickness, top_width = bin.wall_thickness)
            children();
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
        first_part() attach(BOT, TOP) second_part() attach(BOT, TOP) third_part()
            children();

        module first_part()
        {
            label_y_length = y_length() - 2 * model.width0;
            diff("wall_hole")
            wall_part(height = label_height, bottom_width = model.width1, top_width = model.width0)
            {
                position(LEFT + TOP) right(model.width0) single_holder(LEFT);
                position(RIGHT + TOP) left(model.width0) single_holder(RIGHT);
                position(BOT) label();
                position(RIGHT + TOP) down(label.holder.z) right(math.epsilon) tag("wall_hole") wall_hole();
                children();
            }

            module label(){
                diff("label_hole")
                cuboid(size  = [x_length() - 2 * model.width0, label_y_length, label.label.z]) position(FRONT)
                tag("label_hole") cuboid(size = [x_length() - 2 * model.width0 - 2 * label.holder.x, label.hole.y, label.label.z + math.epsilon], anchor = FWD);
            }

            module wall_hole()
            {
                cube(size = [ upper.width1, label.cover.y, label.cover.z ] + label.clearance, anchor = RIGHT + TOP);
            }

            module single_holder(pos)
            {
                cuboid(size = [ label.holder.x, label_y_length, label.holder.z ], anchor = TOP + pos)
                position(BOT - pos) support();

                module support()
                {
                    down(printer.support.offset.z) cuboid(
                        [
                            printer.support.line_width, label_y_length - 2 * printer.support.offset.y,
                            label.cover.z + label.clearance.z - 2 * printer.support.offset.z
                        ],
                        anchor = TOP - pos);
                }
            }
        }

        module second_part()
        {
            wall_part(height = model.height2, bottom_width = model.width2, top_width = model.width1) children();
        }

        module third_part()
        {
            height = bin.height_unit - label_height;
            wall_part(height = model.height3, bottom_width = model.width3, top_width = model.width2) children();
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