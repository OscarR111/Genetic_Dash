with (obj_jugador) {
    if (vivo && place_meeting(x, y, other) && portal_usado != other.id) {
        portal_usado = other.id;
        if (modo == "normal") {
            modo = "nave";
            sprite_index = spr_jugador_nave;
            image_speed = 1;
            if (!es_bot) {
                audio_stop_all();
                audio_play_sound(sfx_nave_nyancat, 1, false, 1);
            }
        } else {
            modo = "normal";
            sprite_index = spr_gato_correr;
            if (!es_bot) audio_stop_sound(sfx_nave_nyancat);
        }
    }
}