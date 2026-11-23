function mutacion_suma_cerebro(_cerebro, _prob, _paso) {
    _cerebro.w1 = mutate_matrix(_cerebro.w1, _prob, -_paso, _paso);
    _cerebro.b1 = mutate_matrix(_cerebro.b1, _prob, -_paso, _paso);
    _cerebro.w2 = mutate_matrix(_cerebro.w2, _prob, -_paso, _paso);
    _cerebro.b2 = mutate_matrix(_cerebro.b2, _prob, -_paso, _paso);
    return _cerebro;
}

function mutacion_reemplazo_matriz(_m, _prob) {
    var _filas = array_length(_m);
    var _cols = array_length(_m[0]);
    var _nueva = array_create(_filas);
    for (var _i = 0; _i < _filas; _i++) {
        var _fila = array_create(_cols);
        for (var _j = 0; _j < _cols; _j++) {
            if (random(100) < _prob) _fila[_j] = random_range(-1, 1);
            else _fila[_j] = _m[_i][_j];
        }
        _nueva[_i] = _fila;
    }
    return _nueva;
}

function mutacion_reemplazo_cerebro(_cerebro, _prob) {
    return {
        w1: mutacion_reemplazo_matriz(_cerebro.w1, _prob),
        b1: mutacion_reemplazo_matriz(_cerebro.b1, _prob),
        w2: mutacion_reemplazo_matriz(_cerebro.w2, _prob),
        b2: mutacion_reemplazo_matriz(_cerebro.b2, _prob)
    };
}

function mutar(_cerebro, _tipo, _prob, _paso) {
    if (_tipo == 1) return mutacion_suma_cerebro(_cerebro, _prob, _paso);
    if (_tipo == 2) return mutacion_reemplazo_cerebro(_cerebro, _prob);
    return mutacion_suma_cerebro(_cerebro, _prob, _paso);
}