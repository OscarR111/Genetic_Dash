// Portal (alterna entre normal y nave)
var _portal = instance_place(x, y, obj_portal_nave);
if (_portal != noone && _portal != portal_usado) {
    portal_usado = _portal;
    if (modo == "normal") {
        modo = "nave";
        sprite_index = spr_jugador_nave;
    } else {
        modo = "normal";
        sprite_index = spr_jugador;
        image_angle = 0;
    }
}

en_suelo = place_meeting(x, y + 1, obj_suelo);
var _input = keyboard_check(vk_space) || mouse_check_button(mb_left);

if (modo == "normal") {
    // Salto
    if (en_suelo && _input) vel_y = fuerza_salto;

    // Trampolín
    if (place_meeting(x, y, obj_trampolin) && vel_y >= 0) vel_y = fuerza_trampolin;

    // Orbe
    var _orbe = instance_place(x, y, obj_orbe);
    if (_orbe != noone && !en_suelo) {
        if (keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left)) vel_y = fuerza_orbe;
    }

    vel_y += grav;
}
else {
    // Modo nave: mantener sube, soltar baja
    if (_input) vel_y += nave_empuje;
    else vel_y += nave_grav;
    vel_y = clamp(vel_y, -nave_vel_max, nave_vel_max);
    image_angle = -vel_y * 3;
}

// Colisión vertical
if (place_meeting(x, y + vel_y, obj_suelo)) {
    while (!place_meeting(x, y + sign(vel_y), obj_suelo)) {
        y += sign(vel_y);
    }
    vel_y = 0;
}
y += vel_y;

// Movimiento constante a la derecha
x += vel_x;

// Muerte por púa
if (place_meeting(x, y, obj_pua)) {
    room_restart();
}

// Muerte por bloque de frente
if (place_meeting(x + vel_x, y, obj_bloque)) {
    room_restart();
}