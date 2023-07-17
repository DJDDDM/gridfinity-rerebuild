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

gridfinity_bin();

module gridfinity_bin()
{
    difference()
    {
        lip(lip) attach(BOT, TOP) upper(upper, closeable_label) attach(BOT, TOP) middle() attach(BOT, TOP) bottom()
        {
            front(model = front);
            block(model = block);
        }

        clearance();
    }
}

module front(model)
{

    back(bin.wall_thickness + model.spacer_distance) up(model.slope_offset) slope();

    module slope()
    {
        front_length = standard.length - 2 * bin.wall_thickness;
        difference()
        {
            union()
            {
                cuboid(size = [ front_length, model.slope_radius, model.slope_radius ],
                       anchor = BOT + BACK) attach(FRONT, BACK) fwd(model.slope_offset)
                    cuboid(size = [ front_length, model.spacer_distance, height_for_units(units = input.units.z - 1) ]);
            }
            color_this("green") pie_slice(h = front_length, r = model.slope_radius, ang = 90, spin = 180, orient = LEFT,
                                          anchor = CENTER + RIGHT);
        }
    }
}

function height_for_units(units) = bin.height_unit * units;

module clearance()
{
    rect_tube(h = height_for_units(input.units.z) + bin.lip_height, size = standard.length + 2 * math.epsilon,
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
            wall_part(height = model.height1 + math.epsilon, bottom_width = model.width1,
                      top_width = model.width0 + math.epsilon) children();
        }

        module second_part()
        {
            color_this("red") wall_part(height = model.height2 + math.epsilon, bottom_width = model.width2,
                                        top_width = model.width1) children();
        }

        module third_part()
        {
            color_this("darkgreen") wall_part(height = model.height3 + math.epsilon, bottom_width = model.width3,
                                              top_width = model.width2) children();
        }
    }

    module main(model = model)
    {
        diff("hole profile") solid()
        {
            attach(TOP, BOT) color_this([ 0.9, 0.2, 0.3, 1 ]) tag("hole") hole_distributor() hole();
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
        color_this("lightgreen")
            rect_tube(h = bottom.height1, size = standard.length, isize1 = standard.length - 2 * bin.wall_thickness,
                      isize2 = standard.length - 2 * bin.wall_thickness, rounding = standard.outer_rounding) children();
    }

    module second_part()
    {
        color_this("#123") cuboid(size = [ standard.length, standard.length, bottom.height2 ],
                                  rounding = standard.outer_rounding, edges = "Z") children();
    }
}

module middle()
{
    first_part() children();

    module first_part()
    {
        color_this("grey")
            rect_tube(h = bin.height_unit, size = standard.length, isize1 = standard.length - 2 * bin.wall_thickness,
                      isize2 = standard.length - 2 * bin.wall_thickness, rounding = standard.outer_rounding) children();
    }
}

module upper(model, label)
{
    !first_part() *attach(BOT, TOP) second_part() attach(BOT, TOP) third_part() * children();

    module first_part()
    {
        height = is_def(label) ? label.label.z + label.holder.z : model.height1;
        diff("hole")
        {
            color_this("blue") wall_part(height = height, bottom_width = model.width1, top_width = model.width0)
            {
                position(BOT) label(label);
                position(RIGHT+BOT) color_this("pink") tag("hole") up(label.label.z) wall_hole();
                children();
            }
        }

        module wall_hole()
        {
            #cube(size =
                     [
                         upper.width1 + math.epsilon,
                         label.cover.y + label.clearance.y,
                         label.cover.z + label.clearance.z
                     ],
                 anchor = RIGHT + BOT);
        }

        module label(model)
        {
            diff("cover_hole")
            {
                cuboid(size = model.label, anchor = BOT)
                {
                    position(TOP) holders();
                    position(FRONT) tag("cover_hole")
                        cuboid(size = [ model.hole.x, model.hole.y, model.label.z + 3 * math.epsilon ], anchor = FRONT);
                }
            }
            children();

            module holders()
            {
                xcopies(l = model.label.x, n = 2) holder(left = ($idx == 0));
            }

            module holder(left)
            {
                single_holder((left ? RIGHT : LEFT));
            }

            module single_holder(pos)
            {
                up(label.cover.z + label.clearance.z) cuboid(size = model.holder, anchor = TOP + -1 * pos )
                {
                    *position(pos + BOT) up(printer.support.z_offset) cuboid(
                        [
                            printer.support.line_width, model.holder.y - 2 * printer.support.xy_offset,
                            model.cover.z + model.clearance.z - 2 * printer.support.z_offset
                        ],
                        anchor = pos + BOT);
                }
            }

            module cover()
            {
                cuboid(model.cover);
            }
        }
    }

    module second_part()
    {
        color_this("green") wall_part(height = model.height2, bottom_width = model.width2, top_width = model.width1)
            children();
    }

    module third_part()
    {
        color_this("red") wall_part(height = model.height3, bottom_width = model.width3, top_width = model.width2)
            children();
    }
}

module lip(model)
{
    first_part() attach(BOT, TOP) second_part() attach(BOT, TOP) third_part() children();

    module first_part()
    {
        path = rect(size = standard.length - 2 * model.width1, rounding = standard.outer_rounding - model.width1);
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
        color_this("red") wall_part(height = model.height2, bottom_width = model.height2, top_width = model.height1)
            children();
    }

    module third_part()
    {
        color_this("firebrick") wall_part(height = model.height3, bottom_width = model.width3, top_width = model.width2)
            children();
    }
}

module wall_part(height, bottom_width, top_width)
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