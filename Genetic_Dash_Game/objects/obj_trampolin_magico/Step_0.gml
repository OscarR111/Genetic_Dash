with (obj_jugador) {
    if (vivo && vel_y >= 0 && place_meeting(x, y, other)) {
        vel_y = -26 * escala;
        if (!es_bot) audio_play_sound(orbe_efect, 1, false);
    }
}