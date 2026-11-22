if (!vivo) exit;

// 1. Input: humano = teclado, bot = lo decidirá la red (más adelante)
if (!es_bot) {
    input = keyboard_check(vk_space) || mouse_check_button(mb_left);
    input_pressed = keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left);
}

// 2. Suelo
en_suelo = place_meeting(x, y + 1, obj_suelo);

// 3. Física según el modo
if (modo == "normal") {
    if (en_suelo && input) {
        vel_y = fuerza_salto;
        if (!es_bot) audio_play_sound(salto_efect, 1, false);
    }
    vel_y += grav;
} else {
    if (input) vel_y += nave_empuje;
    else vel_y += nave_grav;
    vel_y = clamp(vel_y, -nave_vel_max, nave_vel_max);
}

// 4. Colisión vertical
if (place_meeting(x, y + vel_y, obj_suelo)) {
    while (!place_meeting(x, y + sign(vel_y), obj_suelo)) {
        y += sign(vel_y);
    }
    vel_y = 0;
}
y += vel_y;

// 5. Avance constante
x += vel_x;

// 6. Animación (solo en modo normal)
if (modo == "normal") {
    if (en_suelo) {
        image_speed = 1;
    } else {
        image_speed = 0;
        image_index = 1;
    }
}

// Sensores

if (es_bot) {
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
        _d = bbox_left - _borde;
        if (_d >= 0 && _d < _dist) _dist = _d;
    }
    sensores[1] = _dist / vision;

    // Sensor 3: distancia al bloque más cercano al frente, a la altura del jugador
    _dist = vision;
    with (obj_bloque) {
        if (bbox_bottom > _arriba && bbox_top < _abajo) {
            _d = bbox_left - _borde;
            if (_d >= 0 && _d < _dist) _dist = _d;
        }
    }
    sensores[2] = _dist / vision;
	
	// Sensor 4: Esta tocando una orbe ?
	sensores[3] = place_meeting(x, y, obj_orbe) ? 1 : 0;
	
	// Sensor 5: Esta en modo nave?
	sensores[4] =  modo != "normal" ? 1 : 0;
	
	// Sensor 6: Distancia a un bloque que este arriba
	_dist = vision;
	with(obj_bloque){
		if(bbox_bottom <= _arriba){
			_d = bbox_left - _borde;
			if(_d >= 0 && _d < _dist) _dist = _d;
		}
	}
	sensores[5] = _dist / vision
	
	//Sensor 7: Distancia a un  bloque que este abajo
	_dist = vision;
	with(obj_bloque){
		if(bbox_top >= _abajo){
			_d = bbox_left - _borde;
			if(_d >= 0 && _d < _dist) _dist = _d;
		}
	}
	sensores[6] = _dist / vision;
}