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