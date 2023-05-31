// file for printing the pegboard board. That is, the plate you put on the wall

include <BOSL2/std.scad>

module pegboard_board(type)
{
    function is_double(type) = (type == "double_circular" || type == "double_hexagonal" || type == "double_octagonal");
    function is_circular(type) = (type == "single_circular" || type == "double_circular" || type == "rowed_circular" || type == "quad_circular");
    function is_hexagonal(type) = (type == "single_hexagonal" || type == "double_hexagonal" || type == "rowed_hexagonal" || type == "quad_hexagonal");
    function is_octagonal(type) = (type == "single_octagonal" || type == "double_octagonal");

    function single_space() = [ hole_spacing, hole_spacing ];
    function double_space() = [ hole_spacing / 2, hole_spacing / 2 ];
    function rowed_space() = [ hole_spacing / 2, hole_spacing / 2 ];
    function quad_space() = [ hole_spacing / 2, hole_spacing / 4 ];

    function single_circular_space() = single_space();
    function single_hexagonal_space() = single_space();
    function quad_circular_space() = quad_space();
    function quad_hexagonal_space() = quad_space();

    function init_space(type) = (type == "single_circular")    ? single_circular_space()
                                : (type == "single_hexagonal") ? single_hexagonal_space()
                                : is_double(type)              ? double_space()
                                : (type == "rowed_circular")   ? rowed_space()
                                : (type == "rowed_hexagonal")  ? rowed_space()
                                : (type == "quad_circular")    ? quad_circular_space()
                                : (type == "quad_hexagonal")   ? quad_hexagonal_space()
                                                               : assert(false) + 0;

    space = function(type) init_space(type);

    function rim_size_base() = [ hole_spacing, hole_spacing ];
    function rim_size_broad() = (1 - epsilon) * rim_size_base();
    function rim_size_double() = 0.5 * rim_size_base();
    function rim_size_slim() = [ (0.5) * hole_spacing, (0.5) * hole_spacing ];
    function rim_size_tight() = [ (0.5) * hole_spacing, (0.25) * hole_spacing ];

    function single_circular_rim_size() = rim_size_broad();
    function single_hexagonal_rim_size() = rim_size_broad();
    function quad_circular_rim_size() = rim_size_tight();
    function quad_hexagonal_rim_size() = rim_size_tight();

    function init_rim_size(type) = (type == "single_circular")    ? single_circular_rim_size()
                                   : (type == "single_hexagonal") ? single_hexagonal_rim_size()
                                   : is_double(type)              ? rim_size_double()
                                   : (type == "rowed_circular")   ? rim_size_slim()
                                   : (type == "rowed_hexagonal")  ? rim_size_slim()
                                   : (type == "quad_circular")    ? quad_circular_rim_size()
                                   : (type == "quad_hexagonal")   ? quad_hexagonal_rim_size()
                                                                  : assert(false) + 0;

    rim_size = function(type) init_rim_size(type);

    function board_size() = [ x_board_size, y_board_size ];
    function center_size(type) = board_size() - rim_size(type);

    function standard_center_startpoints(type) = [
        [ -0.5 * center_size(type).x, -0.5 * center_size(type).y ],
        [ -0.5 * (center_size(type).x - space(type).x), -0.5 * (center_size(type).y - space(type).y) ]
    ];

    function rowed_center_startpoints(type) = [
        [ -0.5 * center_size(type).x, -0.5 * center_size(type).y + 0.25 * space(type).y ],
        [ -0.5 * (center_size(type).x - space(type).x), -0.5 * (center_size(type).y - space(type).y) ]
    ];

    function init_center_startpoints(type) = (type == "single_circular")    ? standard_center_startpoints(type)
                                             : (type == "single_hexagonal") ? standard_center_startpoints(type)
                                             : is_double(type)              ? standard_center_startpoints(type)
                                             : (type == "rowed_circular")   ? rowed_center_startpoints(type)
                                             : (type == "rowed_hexagonal")  ? rowed_center_startpoints(type)
                                             : (type == "quad_circular")    ? standard_center_startpoints(type)
                                             : (type == "quad_hexagonal")   ? standard_center_startpoints(type)
                                             : (type == undef)              ? assert(undef == false) + 0
                                                                            : assert(false) + 0;

    center_startpoints = function(type) init_center_startpoints(type);

    function standard_center_lengths(type) =
        [[center_size(type).x, center_size(type).y],
         [center_size(type).x - space(type).x, center_size(type).y - space(type).y]];

    function double_center_lengths(type) = [[center_size(type).x, center_size(type).y - space(type).y],
                                            [center_size(type).x - space(type).x, center_size(type).y - space(type).y]];

    function init_center_lengths(type) = (type == "single_circular")    ? standard_center_lengths(type)
                                         : (type == "single_hexagonal") ? standard_center_lengths(type)
                                         : is_double(type)              ? standard_center_lengths(type)
                                         : (type == "rowed_circular")   ? double_center_lengths(type)
                                         : (type == "rowed_hexagonal")  ? double_center_lengths(type)
                                         : (type == "quad_circular")    ? standard_center_lengths(type)
                                         : (type == "quad_hexagonal")   ? standard_center_lengths(type)
                                         : (type == undef)              ? assert(undef == false) + 0
                                                                        : assert(false) + 0;

    center_lengths = function(type) init_center_lengths(type);

    linear_extrude(height = board_thickness)
    {
        difference()
        {
            board();
            holes(type);
        }
    }

    module board()
    {
        square(board_size(), anchor = CENTER);
    }

    module holes(type)
    {
        hole_position(type) hole_shape(type);
        // up(1) color("green") hole_position("quad_hexagonal") hole_shape("quad_hexagonal");
        //% down(1) color("blue") hole_position("single_hexagonal") hole_shape("single_hexagonal");
    }

    module hole_shape(type)
    {
        if (is_circular(type))
        {
            if (type == "quad_circular")
                assert(hole_extra_diameter == 0);
            circle(d = hole_size + hole_extra_diameter);
        }
        else if (is_hexagonal(type))
        {
            if (type == "quad_hexagonal")
                assert(hole_extra_diameter == 0);
            hexagon(id = (hole_size + hole_extra_diameter));
        }
        else if (is_octagonal(type)){
            octagon(id = (hole_size + hole_extra_diameter), realign = true);
        }
        else
        {
            echo(type) assert(false); // should not have reached here
        }
    }

    module hole_position(type)
    {
        {
            color("red")
                ycopies(spacing = space(type).y, sp = center_startpoints(type)[0].y, l = center_lengths(type)[0].y)
                    xcopies(spacing = space(type).x, sp = center_startpoints(type)[0].x, l = center_lengths(type)[0].x)
                        children();
            color("yellow")
                ycopies(spacing = space(type).y, sp = center_startpoints(type)[1].y, l = center_lengths(type)[1].y)
                    xcopies(spacing = space(type).x, sp = center_startpoints(type)[1].x, l = center_lengths(type)[1].x)
                        children();
        }
    }
}