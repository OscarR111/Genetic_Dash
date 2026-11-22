function sensores_calcular() {
    // Datos del jugador, guardados antes de entrar a los with
    var _borde = bbox_right;
    var _arriba = bbox_top;
    var _abajo = bbox_bottom;
    var _dist;
    var _d;

    // Sensor 1: ¿está en el suelo?
    scr_sensores[0] = en_suelo ? 1 : 0;

    // Sensor 2: distancia a la púa más cercana al frente
    _dist = vision;
    with (obj_pua) {
        _d = bbox_left - _borde;
        if (_d >= 0 && _d < _dist) _dist = _d;
    }
    scr_sensores[1] = _dist / vision;

    // Sensor 3: bloque más cercano al frente, a la altura del jugador
    _dist = vision;
    with (obj_bloque) {
        if (bbox_bottom > _arriba && bbox_top < _abajo) {
            _d = bbox_left - _borde;
            if (_d >= 0 && _d < _dist) _dist = _d;
        }
    }
    scr_sensores[2] = _dist / vision;

    // Sensor 4: ¿está tocando una orbe?
    scr_sensores[3] = place_meeting(x, y, obj_orbe) ? 1 : 0;

    // Sensor 5: ¿está en modo nave?
    scr_sensores[4] = modo != "normal" ? 1 : 0;

    // Sensor 6: bloque más cercano al frente-arriba
    _dist = vision;
    with (obj_bloque) {
        if (bbox_bottom <= _arriba) {
            _d = bbox_left - _borde;
            if (_d >= 0 && _d < _dist) _dist = _d;
        }
    }
    scr_sensores[5] = _dist / vision;

    // Sensor 7: bloque más cercano al frente-abajo
    _dist = vision;
    with (obj_bloque) {
        if (bbox_top >= _abajo) {
            _d = bbox_left - _borde;
            if (_d >= 0 && _d < _dist) _dist = _d;
        }
    }
    scr_sensores[6] = _dist / vision;
}