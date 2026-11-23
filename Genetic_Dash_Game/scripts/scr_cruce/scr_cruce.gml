function cruce_matriz(_a, _b) {
    var _filas = array_length(_a);
    var _cols = array_length(_a[0]);
    var _hijo = array_create(_filas);
    for (var _i = 0; _i < _filas; _i++) {
        var _fila = array_create(_cols);
        for (var _j = 0; _j < _cols; _j++) {
            if (random(1) < 0.5) _fila[_j] = _a[_i][_j];
            else _fila[_j] = _b[_i][_j];
        }
        _hijo[_i] = _fila;
    }
    return _hijo;
}

function cruce_cerebro(_a, _b) {
    return {
        w1: cruce_matriz(_a.w1, _b.w1),
        b1: cruce_matriz(_a.b1, _b.b1),
        w2: cruce_matriz(_a.w2, _b.w2),
        b2: cruce_matriz(_a.b2, _b.b2)
    };
}