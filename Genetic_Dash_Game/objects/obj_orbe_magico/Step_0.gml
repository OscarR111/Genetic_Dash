var _j = instance_place(x, y, obj_jugador);
if (_j != noone && _j.modo == "normal" && !_j.en_suelo) {
    if (keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left)) {
        audio_play_sound(orbe_efect, 1, false);
        _j.vel_y = -13 * _j.escala;
    }
}