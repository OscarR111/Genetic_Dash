// Buscar al jugador vivo que va más adelante
var _lider = noone;
var _max_x = -1;
with (obj_jugador) {
    if (vivo && x > _max_x) {
        _max_x = x;
        _lider = id;
    }
}

if (_lider == noone) exit;

var _x = _lider.x - cam_w / 2;
var _y = _lider.y - cam_h / 2;

_x = clamp(_x, 0, room_width - cam_w);
_y = clamp(_y, 0, room_height - cam_h);

camera_set_view_pos(cam, _x, _y);