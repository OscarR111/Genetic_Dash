if (!vivo) exit;

// 1. Input: humano = teclado, bot = lo decidirá la red (más adelante)
if (!es_bot) {
    input = keyboard_check(vk_space) || mouse_check_button(mb_left);
    input_pressed = keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left);
}

// 2. Suelo
en_suelo = place_meeting(x, y + 1, obj_suelo);

// 3. Física según el modo
if (modo == "normal") {
    if (en_suelo && input) {
        vel_y = fuerza_salto;
        if (!es_bot) audio_play_sound(salto_efect, 1, false);
    }
    vel_y += grav;
} else {
    if (input) vel_y += nave_empuje;
    else vel_y += nave_grav;
    vel_y = clamp(vel_y, -nave_vel_max, nave_vel_max);
}

// 4. Colisión vertical
if (place_meeting(x, y + vel_y, obj_suelo)) {
    while (!place_meeting(x, y + sign(vel_y), obj_suelo)) {
        y += sign(vel_y);
    }
    vel_y = 0;
}
y += vel_y;

// 5. Avance constante
x += vel_x;

// 6. Animación (solo en modo normal)
if (modo == "normal") {
    if (en_suelo) {
        image_speed = 1;
    } else {
        image_speed = 0;
        image_index = 1;
    }
}
