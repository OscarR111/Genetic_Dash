function sensores_calcular() {
    // Datos del jugador, guardados antes de entrar a los with
    var _borde = bbox_right;
    var _arriba = bbox_top;
    var _abajo = bbox_bottom;
    var _dist;
    var _d;

    // Sensor 1: ¿está en el suelo?
    sensores[0] = en_suelo ? 1 : 0;

    // Sensor 2: distancia a la púa más cercana al frente
    _dist = vision;
    with (obj_pua) {
		if(bbox_bottom > _arriba && bbox_top < _abajo){
			_d = bbox_left - _borde;
			if (_d >= 0 && _d < _dist) _dist = _d;
		}
        
    }
    sensores[1] = _dist / vision;

    // Sensor 3: bloque más cercano al frente, a la altura del jugador
    _dist = vision;
    with (obj_bloque) {
        if (bbox_bottom > _arriba && bbox_top < _abajo) {
            _d = bbox_left - _borde;
            if (_d >= 0 && _d < _dist) _dist = _d;
        }
    }
    sensores[2] = _dist / vision;

    // Sensor 4: ¿está tocando una orbe?
    sensores[3] = place_meeting(x, y, obj_orbe) ? 1 : 0;

    // Sensor 5: ¿está en modo nave?
    sensores[4] = modo != "normal" ? 1 : 0;

    // Sensor 6: bloque más cercano al frente-arriba
    _dist = vision;
    with (obj_bloque) {
        if (bbox_bottom <= _arriba) {
            _d = bbox_left - _borde;
            if (_d >= 0 && _d < _dist) _dist = _d;
        }
    }
    sensores[5] = _dist / vision;

    // Sensor 7: bloque más cercano al frente-abajo
    _dist = vision;
    with (obj_bloque) {
        if (bbox_top >= _abajo) {
            _d = bbox_left - _borde;
            if (_d >= 0 && _d < _dist) _dist = _d;
        }
    }
    sensores[6] = _dist / vision;
	
	//Sensor 8: pua mas sercana que esta arriba
	_dist = vision;
    with (obj_pua) {
		if(bbox_bottom <= _arriba){
			_d = bbox_left - _borde;
			if (_d >= 0 && _d < _dist) _dist = _d;
		}
        
    }
	
	sensores[7] = _dist / vision;
	
	//Sensor 9: pua mas sercana que esta abajo
	_dist = vision;
    with (obj_pua) {
		if(bbox_top >= _abajo){
			_d = bbox_left - _borde;
			if (_d >= 0 && _d < _dist) _dist = _d;
		}
        
    }
	
	sensores[8] = _dist / vision;
}