var _w = display_get_gui_width();
var _y0 = 130;     // altura de la primera opción
var _paso = 32;    // separación entre opciones (compacto para que quepan todas)
draw_set_halign(fa_center);
draw_text(_w/2, 60, "GENETIC DASH");
for (var i = 0; i < array_length(opciones); i++) {
    var _txt = opciones[i];
    if (i == sel) _txt = "> " + _txt + " <";
    draw_text(_w/2, _y0 + i * _paso, _txt);
}

// Modo de juego y población inicial de los bots
var _pie = _y0 + array_length(opciones) * _paso + 16;   // debajo de la última opción, haya las que haya
var _modo = "JUGAR";
if (global.modo_bot) _modo = "BOT (entrenar)";
draw_text(_w/2, _pie, "Modo: " + _modo + "   [B para cambiar]   |   [X] correr benchmark (" + bench_info + ")");

if (global.modo_bot) {
    var _inicial = "pesos nuevos";
    if (origen_sel >= 0) _inicial = "campeon de " + opciones[origen_sel];
    draw_text(_w/2, _pie + 30, "Poblacion inicial: " + _inicial + "   [C para cambiar]");

    // Qué hay guardado de cada nivel
    for (var _k = 0; _k < array_length(opciones); _k++) {
        var _g = "sin campeon";
        if (records[_k] >= 0) _g = "campeon: " + string(round(records[_k] * 100)) + " %";
        draw_text(_w/2 + 300, _y0 + _k * _paso, _g);
    }
}
draw_set_halign(fa_left);
