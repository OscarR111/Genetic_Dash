en_suelo = place_meeting(x, y + 1, obj_suelo);
var _input = keyboard_check(vk_space) || mouse_check_button(mb_left);

if (modo == "normal") {
    if (en_suelo && _input) vel_y = fuerza_salto;
    vel_y += grav;
} else {
    if (_input) vel_y += nave_empuje;
    else vel_y += nave_grav;
    vel_y = clamp(vel_y, -nave_vel_max, nave_vel_max);
}

if (place_meeting(x, y + vel_y, obj_suelo)) {
    while (!place_meeting(x, y + sign(vel_y), obj_suelo)) {
        y += sign(vel_y);
    }
    vel_y = 0;
}
y += vel_y;
x += vel_x;

if (modo == "normal") {
    if (en_suelo) {
        image_speed = 1;
	} else {
        image_speed = 0;
        image_index = 1;
    }
}
