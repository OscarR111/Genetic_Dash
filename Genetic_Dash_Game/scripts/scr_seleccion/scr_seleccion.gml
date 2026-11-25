function seleccion_torneo(_fitness, _k) {
    var _total = array_length(_fitness);
    var _ganador = irandom(_total - 1);
    for (var _i = 1; _i < _k; _i++) {
        var _rival = irandom(_total - 1);
        if (_fitness[_rival] > _fitness[_ganador]) _ganador = _rival;
    }
    return _ganador;
}

function seleccion_ruleta(_fitness) {
    var _total = array_length(_fitness);

    var _suma = 0;
    for (var _i = 0; _i < _total; _i++) {
        _suma += _fitness[_i];
    }

    if (_suma <= 0) return irandom(_total - 1);

    var _punto = random(_suma);

    var _acumulado = 0;
    for (var _i = 0; _i < _total; _i++) {
        _acumulado += _fitness[_i];
        if (_punto <= _acumulado) return _i;
    }

    return _total - 1;
}

function seleccionar(_fitness, _tipo, _k) {
    if (_tipo == 1) return seleccion_torneo(_fitness, _k);
    if (_tipo == 2) return seleccion_ruleta(_fitness);
    return seleccion_torneo(_fitness, _k);
}

// TASA DE SELECCIÓN: solo el mejor 'tasa_seleccion' de la generación puede ser padre
// (1 = todos, 0.5 = la mejor mitad, 0.2 = el mejor 20 %). Se llama una vez por generación,
// desde poblacion_crear_hijos, y deja listas padres_idx (qué bots) y padres_fit (su fitness).
function preparar_padres() {
    var _n = array_length(fitness);
    var _k = clamp(ceil(_n * tasa_seleccion), 2, _n);
    var _usado = array_create(_n, false);
    padres_idx = array_create(_k);
    padres_fit = array_create(_k);
    for (var _j = 0; _j < _k; _j++) {
        // el mejor que todavía no se eligió
        var _m = -1;
        for (var _i = 0; _i < _n; _i++) {
            if (!_usado[_i] && (_m == -1 || fitness[_i] > fitness[_m])) _m = _i;
        }
        _usado[_m] = true;
        padres_idx[_j] = _m;
        padres_fit[_j] = fitness[_m];
    }
}