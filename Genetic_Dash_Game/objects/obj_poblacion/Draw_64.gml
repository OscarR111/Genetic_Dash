var _b = noone;
for (var _i = 0; _i < array_length(bots); _i++) {
    if (bots[_i].vivo) { _b = bots[_i]; break; }
}

if (_b != noone) {
    var _txt = "";
    for (var _i = 0; _i < 9; _i++) {
        _txt += string_format(_b.sensores[_i], 1, 2) + "  ";
    }
    draw_text(20, 100, "Sensores: " + _txt);
    draw_text(20, 120, "Salida: " + string(nn_decidir(_b.cerebro, _b.sensores)));
    draw_text(20, 140, "w1[0][0]: " + string(_b.cerebro.w1[0][0]));
}