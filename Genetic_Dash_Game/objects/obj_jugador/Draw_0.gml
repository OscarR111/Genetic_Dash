var _w = sprite_get_width(sprite_index);
var _h = sprite_get_height(sprite_index);
var _d = point_distance(0, 0, -_w/2, -_h/2);
var _a = point_direction(0, 0, -_w/2, -_h/2) + angulo;
draw_sprite_ext(sprite_index, 0,
    x + _w/2 + lengthdir_x(_d, _a),
    y + _h/2 + lengthdir_y(_d, _a),
    1, 1, angulo, c_white, 1);