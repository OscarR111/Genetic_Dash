// Detectar suelo
en_suelo = place_meeting(x, y + 1, obj_suelo);

// Salto (espacio o clic)
if (en_suelo && (keyboard_check(vk_space) || mouse_check_button(mb_left))) {
    vel_y = fuerza_salto;
}

// Gravedad
vel_y += grav;

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