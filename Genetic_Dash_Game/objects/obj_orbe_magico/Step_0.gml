with (obj_jugador) {
    if (vivo && modo == "normal" && !en_suelo && input_pressed && place_meeting(x, y, other)) {
        vel_y = -13 * escala;
        if (!es_bot) audio_play_sound(orbe_efect, 1, false);
    }
}  