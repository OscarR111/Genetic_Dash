if (!pausado) {
    var _max_x = 0;
    with (obj_jugador) {
        if (x > _max_x) _max_x = x;
    }
    porcentaje = clamp(_max_x / meta_x * 100, 0, 100);
}

if (keyboard_check_pressed(vk_escape)) {
    pausado = !pausado;
    if (pausado) instance_deactivate_all(true);
    else instance_activate_all();
}

if (pausado) {
    if (keyboard_check_pressed(ord("R"))) { audio_stop_sound(sfx_nave_nyancat); instance_activate_all(); room_restart(); }
    if (keyboard_check_pressed(ord("M"))) { instance_activate_all(); room_goto(rm_menu); }
}