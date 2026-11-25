// Guardado y carga de cerebros entrenados.
// Los archivos quedan en la carpeta de guardado del juego:
//   %LOCALAPPDATA%\Genetic_Dash_Game\campeon_<nombre del room>.json
// Para empezar de cero en un nivel basta con borrar su archivo.

function guardado_nombre(_nombre_room) {
    return "campeon_" + _nombre_room + ".json";
}

// Devuelve los datos guardados de un nivel, o undefined si no hay archivo o no se puede leer
function guardado_cargar(_nombre_room) {
    var _archivo = guardado_nombre(_nombre_room);
    if (!file_exists(_archivo)) return undefined;

    var _datos = undefined;
    try {
        var _buf = buffer_load(_archivo);
        var _texto = buffer_read(_buf, buffer_text);
        buffer_delete(_buf);
        _datos = json_parse(_texto);
        if (!is_struct(_datos) || !struct_exists(_datos, "campeon") || !struct_exists(_datos, "fitness")) {
            _datos = undefined;
        }
    } catch (_error) {
        show_debug_message("No se pudo leer " + _archivo);
        _datos = undefined;
    }
    return _datos;
}

// Mejor fitness guardado de un nivel (de 0 a 1), o -1 si no hay nada guardado
function guardado_record(_nombre_room) {
    var _datos = guardado_cargar(_nombre_room);
    if (is_undefined(_datos)) return -1;
    return _datos.fitness;
}

// ¿El cerebro guardado tiene la misma forma que la red actual?
function guardado_compatible(_cerebro, _modelo) {
    if (!is_struct(_cerebro)) return false;
    if (!struct_exists(_cerebro, "w1") || !struct_exists(_cerebro, "b1")) return false;
    if (!struct_exists(_cerebro, "w2") || !struct_exists(_cerebro, "b2")) return false;
    if (array_length(_cerebro.w1) != array_length(_modelo.w1)) return false;
    if (array_length(_cerebro.w1[0]) != array_length(_modelo.w1[0])) return false;
    if (array_length(_cerebro.w2) != array_length(_modelo.w2)) return false;
    return true;
}

// Se llama desde obj_poblacion, justo después de poblacion_calcular_fitness().
// Guarda el campeón y toda la población de esta generación,
// pero solo si llegaron más lejos que lo que ya estaba guardado de este nivel.
function poblacion_guardar() {
    if (bench_activo()) return;   // el benchmark no pisa los campeones guardados a mano
    var _idx = 0;
    for (var _i = 1; _i < array_length(fitness); _i++) {
        if (fitness[_i] > fitness[_idx]) _idx = _i;
    }
    if (fitness[_idx] <= record_guardado) return;
    record_guardado = fitness[_idx];

    var _cerebros = array_create(array_length(bots));
    for (var _i = 0; _i < array_length(bots); _i++) {
        _cerebros[_i] = bots[_i].cerebro;
    }

    var _nivel = room_get_name(room);
    var _datos = {
        nivel: _nivel,
        fitness: fitness[_idx],
        generacion: generacion,
        fecha: date_datetime_string(date_current_datetime()),
        campeon: bots[_idx].cerebro,
        poblacion: _cerebros,
        fitness_poblacion: fitness
    };

    var _texto = json_stringify(_datos);
    var _buf = buffer_create(1024, buffer_grow, 1);
    buffer_write(_buf, buffer_text, _texto);
    buffer_save_ext(_buf, guardado_nombre(_nivel), 0, buffer_tell(_buf));
    buffer_delete(_buf);

    show_debug_message("Campeon guardado: fitness " + string(record_guardado) + " en " + guardado_nombre(_nivel));
}

// Se llama desde obj_poblacion, con los bots ya creados.
// Cambia sus cerebros por el campeón guardado de un nivel y copias mutadas de él.
// Devuelve true si lo hizo.
function poblacion_sembrar(_nombre_room) {
    var _datos = guardado_cargar(_nombre_room);
    if (is_undefined(_datos)) return false;

    if (!guardado_compatible(_datos.campeon, bots[0].cerebro)) {
        show_debug_message("El campeon de " + _nombre_room + " no tiene la forma de la red actual: se ignora");
        return false;
    }

    // Puesto 0: el campeón tal cual. El resto: copias mutadas.
    bots[0].cerebro = copiar_cerebro(_datos.campeon);
    for (var _i = 1; _i < array_length(bots); _i++) {
        bots[_i].cerebro = mutar(copiar_cerebro(_datos.campeon), tipo_mutacion, prob_mutacion, paso_mutacion);
    }
    return true;
}

// Se llama desde obj_poblacion, justo después de poblacion_calcular_fitness().
// Cuenta cuántos bots llegaron a la meta en esta generación y avisa en la consola.
// La primera vez anota en qué generación pasó y cuánto tiempo real llevaba el entrenamiento.
function poblacion_avisar_victoria() {
    var _ganadores = 0;
    for (var _i = 0; _i < array_length(bots); _i++) {
        if (bots[_i].gano) _ganadores++;
    }
    ganadores_ultima = _ganadores;
    if (_ganadores == 0) return;

    if (primera_victoria == -1) {
        primera_victoria = generacion;
        tiempo_victoria = (get_timer() - tiempo_inicio) / 1000000;
        show_debug_message("*** VICTORIA: un bot llego a la meta en la generacion " + string(generacion)
            + " (" + string(_ganadores) + " de " + string(tam_poblacion) + " bots, "
            + string(tiempo_victoria) + " s de entrenamiento) ***");
    } else {
        show_debug_message("    ganaron " + string(_ganadores) + " de " + string(tam_poblacion) + " bots");
    }
}

// Se llama desde obj_poblacion (Step) cuando algún bot llegó a la meta (fuera del benchmark).
// No se crea la siguiente generación: el nivel se queda quieto y el campeón ya quedó guardado.
// Vuelve a velocidad normal y a dibujar, para que se vea el aviso en pantalla.
function poblacion_detener() {
    terminada = true;
    velocidad = 1;
    if (!dibujar) {
        dibujar = true;
        draw_enable_drawevent(true);
    }
    window_set_caption("GANO en la generacion " + string(generacion) + " | entrenamiento detenido");
    show_debug_message("*** Entrenamiento detenido en la generacion " + string(generacion) + " ***");
}
