// BEGIN STEP: corre una vez por cuadro, antes del Step normal de todos los objetos.
// Aquí se repite la lógica del juego varias veces por cuadro para entrenar más rápido.

// --- Teclas ---
if (keyboard_check_pressed(ord("1"))) velocidad = 1;
if (keyboard_check_pressed(ord("2"))) velocidad = 5;
if (keyboard_check_pressed(ord("3"))) velocidad = 20;
if (keyboard_check_pressed(ord("4"))) velocidad = 0;      // 0 = máximo que aguante el equipo
if (keyboard_check_pressed(ord("V"))) {
    dibujar = !dibujar;
    draw_enable_drawevent(dibujar);
}

// --- Pasos extra de simulación ---
// El motor ya hace un paso por cuadro (el Step normal). Aquí se hacen los que faltan.
var _inicio = get_timer();
var _limite = tiempo_sin_dibujo;
if (dibujar) _limite = tiempo_con_dibujo;
var _extra = 1000000;
if (velocidad > 0) _extra = velocidad - 1;
var _hechos = 0;

// Solo se adelanta si la zona activa se calculó para esta generación y el entrenamiento sigue
if (generacion == zona_generacion && !terminada) {
    while (_hechos < _extra && (get_timer() - _inicio) < _limite) {
        // No pasar de donde llegan las piezas encendidas
        if (lider_x() > zona_limite) break;

        // Un paso completo del juego: el Step de cada objeto (menos la pausa, la cámara y el menú)
        with (all) {
            if (object_index != obj_pausa && object_index != obj_camara && object_index != obj_menu) {
                event_perform(ev_step, ev_step_normal);
            }
        }
        _hechos++;

        // Si nació una generación nueva, o el benchmark cerró el nivel, se espera al siguiente cuadro
        if (generacion != zona_generacion || terminada) break;
    }
}
pasos_cuadro = _hechos + 1;
pasos_total += pasos_cuadro;

// --- Zona activa para el Step normal de este cuadro y los pasos extra del siguiente ---
actualizar_zona();

// --- Progreso en el título de la ventana (se ve aunque no se dibuje) ---
cuadros++;
if (cuadros mod 30 == 0) {
    var _txt = "Gen " + string(generacion) + " | vivos " + string(poblacion_vivos()) + " | x" + string(pasos_cuadro);
    var _n = array_length(hist_mejor);
    if (_n > 0) _txt += " | mejor anterior " + string(hist_mejor[_n - 1]);
    if (primera_victoria >= 0) _txt += " | GANO en la gen " + string(primera_victoria);
    if (bench_activo()) _txt = bench_progreso() + " | " + _txt;
    window_set_caption(_txt);
}
