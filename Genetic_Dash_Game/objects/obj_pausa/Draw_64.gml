var _w = display_get_gui_width();
var _h = display_get_gui_height();

draw_set_halign(fa_left);
draw_set_color(c_white);
draw_text(20, 20, string(floor(porcentaje)) + "%");

if (pausado) {
    draw_set_alpha(0.6);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_text(_w/2, _h/2 - 60, "PAUSA");
    draw_text(_w/2, _h/2 - 20, "Progreso: " + string(floor(porcentaje)) + "%");
    draw_text(_w/2, _h/2 + 20, "ESC: continuar   R: reiniciar   M: menú");
    draw_set_halign(fa_left);
}