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
lipless_lip = import("../model/gridfinity_alternatives/lipless/lip.json");
lipless_upper = import("../model/gridfinity_alternatives/lipless/upper.json");

// helpers
math = import(math_constants_path);

// changeables
input = import(input_path);

gridfinity_bin();

*left(50) intersect() bottom()
{
    tag("intersect") front(model = front);
};
*bottom() front(front);

module gridfinity_bin()
{
    difference()
    {
        lip(model = lip) attach(BOT, TOP) upper(model = upper) attach(BOT, TOP) middle() attach(BOT, TOP) bottom()
        {
            front(model = front);
            block(model = block);
        }
        *lip(model = lipless_lip) attach(BOT, TOP) upper(model = lipless_upper) attach(BOT, TOP) middle()
            attach(BOT, TOP) bottom() position(BOT) block(model = block);
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
            union(){
                cuboid(size = [ front_length, model.slope_radius, model.slope_radius ], anchor = BOT + BACK) attach(FRONT, BACK)
                fwd(model.slope_offset) cuboid( size = [front_length, model.spacer_distance, bin.height_unit * (input.height_units - 1)] );
            }
            color_this("green") pie_slice(h = front_length, r = model.slope_radius, ang = 90, spin = 180, orient = LEFT,
                                          anchor = CENTER + RIGHT);
        }
    }
}

module clearance()
{
    rect_tube(h = bin.height_unit * input.height_units + bin.lip_height, size = standard.length + 2 * math.epsilon,
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

module upper(model)
{
    first_part() attach(BOT, TOP) second_part() attach(BOT, TOP) third_part() children();

    module first_part()
    {
        color_this("blue") wall_part(height = model.height1, bottom_width = model.width1, top_width = model.width0)
            children();
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