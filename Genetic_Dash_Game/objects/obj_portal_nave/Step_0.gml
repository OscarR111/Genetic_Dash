var _j = instance_place(x, y, obj_jugador);
if (_j != noone && !usado) {
    usado = true;
    if (_j.modo == "normal") {
        _j.modo = "nave";
        _j.sprite_index = spr_jugador_nave;
		audio_play_sound(sfx_nave_nyancat, 1, false, 1);
		_j.image_speed = 1;
    } else {
        _j.modo = "normal";
        _j.sprite_index = spr_gato_correr;
		audio_stop_sound(sfx_nave_nyancat);
    }
}