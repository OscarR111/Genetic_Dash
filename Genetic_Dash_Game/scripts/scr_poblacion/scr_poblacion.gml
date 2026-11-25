// Cuenta cuántos bots siguen vivos
function poblacion_vivos() {
    var _vivos = 0;
    for (var _i = 0; _i < array_length(bots); _i++) {
        if (bots[_i].vivo) _vivos++;
    }
    return _vivos;
}

// Calcula la nota de cada bot y guarda las estadísticas
function poblacion_calcular_fitness() {
    var _mejor = 0;
    var _peor = 1;
    var _suma = 0;
    for (var _i = 0; _i < array_length(bots); _i++) {
        var _b = bots[_i];
        if (_b.gano) {
            fitness[_i] = 1;
        } else {
            fitness[_i] = clamp((_b.x - inicio_x) / (meta_x - inicio_x), 0, 1);
        }
        _suma += fitness[_i];
        if (fitness[_i] > _mejor) _mejor = fitness[_i];
        if (fitness[_i] < _peor) _peor = fitness[_i];
    }
    var _prom = _suma / tam_poblacion;

    array_push(hist_mejor, _mejor);
    array_push(hist_peor, _peor);
    array_push(hist_prom, _prom);

    show_debug_message("Gen " + string(generacion) + " | mejor: " + string(_mejor) + " | peor: " + string(_peor) + " | promedio: " + string(_prom));
}

// Fabrica los cerebros de la siguiente generación
function poblacion_crear_hijos() {
    var _hijos = array_create(tam_poblacion);

    var _idx_mejor = 0;
    for (var _i = 1; _i < array_length(fitness); _i++) {
        if (fitness[_i] > fitness[_idx_mejor]) _idx_mejor = _i;
    }
    var _cerebro_mejor = bots[_idx_mejor].cerebro;

    // Puesto 0: el campeón, sin cambios (elitismo)
    _hijos[0] = _cerebro_mejor;

    // Copias mutadas del campeón
    for (var _i = 1; _i <= n_mutantes; _i++) {
        var _copia = copiar_cerebro(_cerebro_mejor);
        _hijos[_i] = mutar(_copia, tipo_mutacion, prob_mutacion, paso_mutacion);
    }

    // El resto: selección, cruce y mutación (los padres salen del mejor 'tasa_seleccion', ver scr_seleccion)
    preparar_padres();
    for (var _i = n_mutantes + 1; _i < tam_poblacion; _i++) {
        var _padre_a = bots[padres_idx[seleccionar(padres_fit, tipo_seleccion, k_torneo)]];
        var _padre_b = bots[padres_idx[seleccionar(padres_fit, tipo_seleccion, k_torneo)]];
        var _hijo = cruce_cerebro(_padre_a.cerebro, _padre_b.cerebro);
        _hijos[_i] = mutar(_hijo, tipo_mutacion, prob_mutacion, paso_mutacion);
    }

    return _hijos;
}

// Borra a los bots viejos y crea los nuevos con los cerebros hijos
function poblacion_nueva_generacion(_hijos) {
    for (var _i = 0; _i < array_length(bots); _i++) {
        instance_destroy(bots[_i]);
    }
    bots = [];

    for (var _i = 0; _i < tam_poblacion; _i++) {
        var _bot = instance_create_layer(inicio_x, inicio_y, capa, obj_jugador);
        _bot.es_bot = true;
        _bot.cerebro = _hijos[_i];
        array_push(bots, _bot);
    }

    generacion++;
}