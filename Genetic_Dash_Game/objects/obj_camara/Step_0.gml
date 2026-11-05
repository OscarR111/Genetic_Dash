if (!instance_exists(target)) exit;

var _x = target.x - cam_w / 2;
var _y = target.y - cam_h / 2;

_x = clamp(_x, 0, room_width - cam_w);
_y = clamp(_y, 0, room_height - cam_h);

camera_set_view_pos(cam, _x, _y);