var _w = display_get_gui_width();
draw_set_halign(fa_center);
draw_text(_w/2, 100, "GENETIC DASH");
for (var i = 0; i < array_length(opciones); i++) {
    var _txt = opciones[i];
    if (i == sel) _txt = "> " + _txt + " <";
    draw_text(_w/2, 200 + i * 40, _txt);
}
draw_set_halign(fa_left);