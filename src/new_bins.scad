include <BOSL2/std.scad>

height_units = 5;
$fn = 40;

// gridfinity standard
general_standard_path = "../model/gridfinity_standard/general.json";
bin_standard_path = "../model/gridfinity_standard/bin.json";
lip_standard_path = "../model/gridfinity_standard/lip.json";
upper_standard_path = "../model/gridfinity_standard/upper.json";
bottom_standard_path = "../model/gridfinity_standard/bottom.json";

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

// helpers
math = import(math_constants_path);

// changeables
input = import(input_path);

gridfinity_bin();

module gridfinity_bin()
{
    difference()
    {
        lip() attach(BOT, TOP) upper() attach(BOT, TOP) middle() attach(BOT, TOP) bottom() attach(BOT,TOP) block();
        clearance();
    }
}

module clearance()
{
    rect_tube(h = bin.height_unit * input.height_units, size = standard.length, wall = standard.clearance,
              rounding = standard.outer_rounding, anchor = TOP);
}

module block(){
    color_this("#497")
            cuboid(size = [standard.length, standard.length, bin.height_unit], rounding = standard.outer_rounding, edges = "Z") children();
}

module bottom()
{
    first_part() attach(BOT,TOP) second_part() children();

    module first_part()
    {
        color_this("lightgreen")
            rect_tube(h = bottom.height1, size = standard.length, isize1 = standard.length - 2 * bin.wall_thickness,
                      isize2 = standard.length - 2 * bin.wall_thickness, rounding = standard.outer_rounding) children();
    }

    module second_part()
    {
        color_this("#123")
            cuboid(size = [standard.length, standard.length, bottom.height2], rounding = standard.outer_rounding, edges = "Z") children();
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

module upper()
{
    first_part() attach(BOT, TOP) second_part() attach(BOT, TOP) third_part() children();

    module first_part()
    {
        color_this("blue")
            rect_tube(h = upper.height1, size = standard.length, isize1 = standard.length - 2 * upper.width1,
                      isize2 = standard.length - 2 * lip.width3, rounding = standard.outer_rounding)
                children();
    }

    module second_part()
    {
        color_this("green")
            rect_tube(h = upper.height2, size = standard.length, isize1 = standard.length - 2 * upper.width2,
                      isize2 = standard.length - 2 * lip.width1, rounding = standard.outer_rounding)
                children();
    }

    module third_part()
    {
        color_this("red")
            rect_tube(h = upper.height3, size = standard.length, isize1 = standard.length - 2 * upper.width3,
                      isize2 = standard.length - 2 * upper.width2, rounding = standard.outer_rounding)
                children();
    }
}

module lip()
{
    first_part() attach(BOT, TOP) second_part() attach(BOT, TOP) third_part() children();
    module first_part()
    {
        color_this("purple")
            rect_tube(h = lip.height1, size = standard.length, isize1 = standard.length - 2 * lip.width1,
                      isize2 = standard.length - 2 * math.epsilon, rounding = standard.outer_rounding,
                      anchor = TOP) children();
    }

    module second_part()
    {
        color_this("red") rect_tube(h = lip.height2, size = standard.length, isize1 = standard.length - 2 * lip.width2,
                                     isize2 = standard.length - 2 * lip.width1, rounding = standard.outer_rounding) children();
    }

    module third_part()
    {
        color_this("firebrick")
            rect_tube(h = lip.height3, size = standard.length, isize1 = standard.length - 2 * lip.width3,
                      isize2 = standard.length - 2 * lip.width2, rounding = standard.outer_rounding)
                children();
    }
}