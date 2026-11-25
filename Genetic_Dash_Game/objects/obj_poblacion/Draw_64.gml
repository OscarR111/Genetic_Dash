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

draw_text(20, 160, "Gen: " + string(generacion) + " | vivos: " + string(poblacion_vivos()) + " | velocidad real: x" + string(pasos_cuadro));
draw_text(20, 180, "Teclas: 1 = x1, 2 = x5, 3 = x20, 4 = maximo, V = ver / no ver");

var _victoria = "Todavia no gana ningun bot";
if (primera_victoria >= 0) {
    _victoria = "GANO: primera victoria en la generacion " + string(primera_victoria)
        + " | en la ultima generacion ganaron " + string(ganadores_ultima) + " de " + string(tam_poblacion);
}
draw_text(20, 220, _victoria);
if (terminada && !bench_activo()) {
    draw_text(20, 250, "ENTRENAMIENTO DETENIDO: un bot llego a la meta en la generacion " + string(generacion)
        + ". Esc y M = volver al menu | Esc y R = empezar de nuevo");
}

var _guardado = "ninguno";
if (record_guardado >= 0) _guardado = string(round(record_guardado * 100)) + " %";
var _inicial = "pesos nuevos";
if (sembrado) _inicial = "campeon de " + origen;
draw_text(20, 200, "Campeon guardado de este nivel: " + _guardado + " | poblacion inicial: " + _inicial);