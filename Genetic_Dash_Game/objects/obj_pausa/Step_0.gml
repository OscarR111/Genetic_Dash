if (!pausado && instance_exists(obj_jugador)) {
    porcentaje = clamp(obj_jugador.x / meta_x * 100, 0, 100);
}

if (keyboard_check_pressed(vk_escape)) {
    pausado = !pausado;
    if (pausado) instance_deactivate_all(true);
    else instance_activate_all();
}

if (pausado) {
    if (keyboard_check_pressed(ord("R"))) { instance_activate_all(); room_restart(); }
    if (keyboard_check_pressed(ord("M"))) { instance_activate_all(); room_goto(rm_menu); }
}