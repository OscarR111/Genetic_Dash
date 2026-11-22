escala = 64 / 94;

vel_x = 6 * escala;
vel_y = 0;
grav = 0.8 * escala;
fuerza_salto = -19 * escala;
en_suelo = false;
modo = "normal";
nave_empuje = -0.6 * escala;
nave_grav = 0.4 * escala;
nave_vel_max = 7 * escala;

mask_index = spr_jugador;

es_bot = false;
vivo = true;
gano = false;
input = false;
input_pressed = false;
portal_usado = noone;

morir = function() {
    if (!vivo) return;
    vivo = false;
    if (es_bot) {
        visible = false;
    } else {
        audio_stop_sound(sfx_nave_nyancat);
        audio_play_sound(sfx_death, 1, false, 1, 5.4);
        room_restart();
    }
};

ganar = function() {
    if (!vivo) return;
    vivo = false;
    gano = true;
    if (es_bot) visible = false;
    else room_goto(rm_menu);
};

// --- Sensores ---
vision = 400;
sensores = array_create(7, 0);