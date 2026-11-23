function crear_matriz_pesos(_filas, _cols, _tipo, _valor) {
    if (_tipo == 1) return create_random_matrix(_filas, _cols);

    var _v = 0;
    if (_tipo == 2) _v = _valor;

    var _m = array_create(_filas);
    for (var _i = 0; _i < _filas; _i++) {
        _m[_i] = array_create(_cols, _v);
    }
    return _m;
}

function nn_crear_cerebro(_tipo, _valor) {
    return {
        w1: crear_matriz_pesos(9, 4, _tipo, _valor),
        b1: crear_matriz_pesos(1, 4, _tipo, _valor),
        w2: crear_matriz_pesos(4, 1, _tipo, _valor),
        b2: crear_matriz_pesos(1, 1, _tipo, _valor)
    };
}

function nn_sigmoide(_x) {
    _x = clamp(_x, -20, 20);
    return 1 / (1 + exp(-_x));
}

function nn_tanh(_x) {
    _x = clamp(_x, -20, 20);
    return 2 / (1 + exp(-2 * _x)) - 1;
}

function nn_decidir(_cerebro, _sensores) {
    // Capa 1 -> capa 2 (oculta)
    var _z1 = _matrix_multiply([_sensores], _cerebro.w1);
    _z1 = _matrix_sum([_z1], _cerebro.b1);
    var _h = array_create(4);
    for (var _i = 0; _i < 4; _i++) {
        _h[_i] = nn_tanh(_z1[0][_i]);
    }

    // Capa 2 -> capa 3 (salida)
    var _z2 = _matrix_multiply([_h], _cerebro.w2);
    _z2 = _matrix_sum(_z2, _cerebro.b2);
    return nn_sigmoide(_z2[0][0]);
}

function copiar_matriz(_m) {
    var _filas = array_length(_m);
    var _copia = array_create(_filas);
    for (var _i = 0; _i < _filas; _i++) {
        var _largo = array_length(_m[_i]);
        _copia[_i] = array_create(_largo);
        array_copy(_copia[_i], 0, _m[_i], 0, _largo);
    }
    return _copia;
}

function copiar_cerebro(_c) {
    return {
        w1: copiar_matriz(_c.w1),
        b1: copiar_matriz(_c.b1),
        w2: copiar_matriz(_c.w2),
        b2: copiar_matriz(_c.b2)
    };
}