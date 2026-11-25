// BENCHMARK: corre sola una lista de experimentos y escribe dos CSV.
// Se lanza desde el menú con la tecla X. Las tablas y gráficas las arma benchmark/analizar.py.
//
// Archivos (en %LOCALAPPDATA%\Genetic_Dash_Game\):
//   bench_<fecha>_generaciones.csv : una fila por cada generación de entrenamiento
//   bench_<fecha>_resultados.csv   : una fila por cada nivel jugado (entrenamiento o validación)
//
// Cada corrida hace el ciclo del PDF: entrena en Entrenar 1 desde cero, valida su campeón en
// Fácil 1 y 2, entrena Entrenar 2 empezando por ese campeón, valida en Medio 1 y 2, entrena
// Entrenar 3, valida en Medio-alto 1 y 2 y, al final, en el Avanzado.
// Un entrenamiento termina cuando un bot llega a la meta (converge) o al llegar a max_generaciones.
// Una validación es una sola partida de la población final del entrenamiento, sin evolucionar.


// ============================================================ LO QUE SE EDITA

// Corridas por experimento (cada una con otra semilla) y tope de generaciones por nivel
function bench_ajustes() {
    return { repeticiones: 10, max_generaciones: 150 };
}

// Configuración base: los mismos valores que obj_poblacion (si se cambia una, cambiar la otra)
function bench_base() {
    return {
        tam_poblacion: 50, prob_mutacion: 20, paso_mutacion: 1, frac_mutantes: 0.2,
        tipo_seleccion: 1, k_torneo: 3, tasa_seleccion: 1,
        tipo_mutacion: 1, tipo_pesos: 1, valor_pesos: 0.5, umbral: 0.5
    };
}

// Experimentos: [nombre, variable que cambia respecto a la base, valor]. "" = la base tal cual.
function bench_experimentos() {
    return [
        ["base", "", 0],
        ["pobladores_10", "tam_poblacion", 10],
        ["pobladores_20", "tam_poblacion", 20],
        ["mutacion_10", "prob_mutacion", 10],
        ["mutacion_50", "prob_mutacion", 50],
        ["pesos_iguales", "tipo_pesos", 2],
        ["pesos_nulos", "tipo_pesos", 3],
        ["seleccion_50", "tasa_seleccion", 0.5],
        ["seleccion_20", "tasa_seleccion", 0.2],
        ["mutacion_reemplazo", "tipo_mutacion", 2],
        ["seleccion_ruleta", "tipo_seleccion", 2],
        ["umbral_03", "umbral", 0.3],
        ["umbral_07", "umbral", 0.7]
    ];
}

// Orden de los niveles en cada corrida: [entrenar o validar, room, categoría]
function bench_etapas() {
    return [
        ["entrenar", rm_base_1, "facil"],
        ["validar", rm_facil_1, "facil"],
        ["validar", rm_facil_2, "facil"],
        ["entrenar", rm_base_2, "medio"],
        ["validar", rm_medio_1, "medio"],
        ["validar", rm_medio_2, "medio"],
        ["entrenar", rm_base_3, "medioalto"],
        ["validar", rm_medioalto_1, "medioalto"],
        ["validar", rm_medioalto_2, "medioalto"],
        ["validar", rm_avanzado, "avanzado"]
    ];
}


// ============================================================ FUNCIONAMIENTO

function bench_activo() {
    return variable_global_exists("bench") && is_struct(global.bench) && global.bench.activo;
}

// Desde el menú (tecla X)
function bench_empezar() {
    var _aj = bench_ajustes();
    var _id = string(current_year) + bench_dos(current_month) + bench_dos(current_day) + "_" + bench_dos(current_hour) + bench_dos(current_minute);
    global.bench = {
        activo: true,
        experimentos: bench_experimentos(),
        etapas: bench_etapas(),
        repeticiones: _aj.repeticiones,
        max_generaciones: _aj.max_generaciones,
        i_exp: 0,
        rep: 1,
        i_etapa: 0,
        campeon: undefined,
        i_campeon: 0,
        poblacion: undefined,
        archivo_gen: "bench_" + _id + "_generaciones.csv",
        archivo_res: "bench_" + _id + "_resultados.csv"
    };
    bench_escribir(global.bench.archivo_gen, "experimento,repeticion,semilla,nivel,generacion,mejor,promedio,peor,ganadores,poblacion,tiempo_s,pasos");
    bench_escribir(global.bench.archivo_res, "experimento,repeticion,semilla,etapa,nivel,categoria,convergio,generaciones,tiempo_s,pasos,campeon_avance,campeon_gana,poblacion_ganan,poblacion,"
        + "tam_poblacion,prob_mutacion,paso_mutacion,tipo_seleccion,k_torneo,tasa_seleccion,tipo_mutacion,tipo_pesos,valor_pesos,umbral");
    global.origen_cerebro = "";     // el benchmark no usa campeones guardados con la tecla C
    audio_master_gain(0);           // sin sonido mientras corre
    show_debug_message("*** BENCHMARK: " + global.bench.archivo_res + " ***");
    room_goto(global.bench.etapas[0][1]);
}

// La semilla depende solo de la repetición y del nivel: todos los experimentos usan las mismas semillas
function bench_semilla() {
    return global.bench.rep * 1000 + global.bench.i_etapa;
}

// obj_poblacion (Create), justo después de sus parámetros: pone los del experimento y fija la semilla
function bench_aplicar_config() {
    var _b = global.bench;
    var _cfg = bench_base();
    var _exp = _b.experimentos[_b.i_exp];
    if (_exp[1] != "") struct_set(_cfg, _exp[1], _exp[2]);
    var _nombres = struct_get_names(_cfg);
    for (var _i = 0; _i < array_length(_nombres); _i++) {
        variable_instance_set(id, _nombres[_i], struct_get(_cfg, _nombres[_i]));
    }
    n_mutantes = floor(tam_poblacion * frac_mutantes);
    random_set_seed(bench_semilla());
}

// obj_poblacion (Create), al final: velocidad máxima sin dibujar y los cerebros de la etapa
function bench_preparar() {
    var _b = global.bench;
    velocidad = 0;
    dibujar = false;
    draw_enable_drawevent(false);
    if (_b.etapas[_b.i_etapa][0] == "entrenar") {
        // Desde el segundo nivel: el campeón anterior y copias mutadas de él (entrenamiento incremental)
        if (!is_undefined(_b.campeon)) {
            bots[0].cerebro = copiar_cerebro(_b.campeon);
            for (var _i = 1; _i < array_length(bots); _i++) {
                bots[_i].cerebro = mutar(copiar_cerebro(_b.campeon), tipo_mutacion, prob_mutacion, paso_mutacion);
            }
        }
    } else {
        // Validación: la población final del último entrenamiento, tal cual
        for (var _i = 0; _i < array_length(bots); _i++) {
            bots[_i].cerebro = copiar_cerebro(_b.poblacion[_i]);
        }
    }
}

// obj_poblacion (Step), cuando ya murieron todos y se calculó el fitness.
// Anota la generación y decide si la etapa terminó. Devuelve true si terminó (y ya cambió de nivel).
function bench_fin_generacion() {
    var _b = global.bench;
    var _etapa = _b.etapas[_b.i_etapa];
    var _t = (get_timer() - tiempo_etapa) / 1000000;
    var _idx = 0;
    for (var _i = 1; _i < array_length(fitness); _i++) {
        if (fitness[_i] > fitness[_idx]) _idx = _i;
    }

    if (_etapa[0] == "entrenar") {
        var _n = array_length(hist_mejor);
        bench_escribir(_b.archivo_gen, bench_csv([_b.experimentos[_b.i_exp][0], _b.rep, bench_semilla(), room_get_name(room), generacion,
            hist_mejor[_n - 1], hist_prom[_n - 1], hist_peor[_n - 1], ganadores_ultima, tam_poblacion, _t, pasos_total]));
        var _gano = ganadores_ultima > 0;
        if (!_gano && generacion < _b.max_generaciones) return false;   // sigue entrenando

        // Fin del entrenamiento: esta generación es la que se valida y la que pasa al siguiente nivel
        _b.poblacion = array_create(array_length(bots));
        for (var _i = 0; _i < array_length(bots); _i++) _b.poblacion[_i] = bots[_i].cerebro;
        _b.campeon = bots[_idx].cerebro;
        _b.i_campeon = _idx;
        bench_resultado(_etapa, _gano ? 1 : 0, generacion, _t, fitness[_idx], _gano ? 1 : 0);
    } else {
        var _c = _b.i_campeon;
        bench_resultado(_etapa, "", "", _t, fitness[_c], bots[_c].gano ? 1 : 0);
    }
    bench_siguiente();
    return true;
}

function bench_resultado(_etapa, _convergio, _generaciones, _t, _avance, _gana) {
    var _b = global.bench;
    bench_escribir(_b.archivo_res, bench_csv([_b.experimentos[_b.i_exp][0], _b.rep, bench_semilla(), _etapa[0], room_get_name(room), _etapa[2],
        _convergio, _generaciones, _t, pasos_total, _avance, _gana, ganadores_ultima, tam_poblacion,
        tam_poblacion, prob_mutacion, paso_mutacion, tipo_seleccion, k_torneo, tasa_seleccion, tipo_mutacion, tipo_pesos, valor_pesos, umbral]));
}

// Pasa al siguiente nivel, a la siguiente repetición o al siguiente experimento
function bench_siguiente() {
    var _b = global.bench;
    terminada = true;
    _b.i_etapa++;
    if (_b.i_etapa >= array_length(_b.etapas)) {
        _b.i_etapa = 0;
        _b.campeon = undefined;
        _b.poblacion = undefined;
        _b.rep++;
        if (_b.rep > _b.repeticiones) {
            _b.rep = 1;
            _b.i_exp++;
        }
        if (_b.i_exp >= array_length(_b.experimentos)) {
            _b.activo = false;
            audio_master_gain(1);
            show_debug_message("*** BENCHMARK TERMINADO: " + _b.archivo_res + " ***");
            room_goto(rm_menu);
            return;
        }
    }
    room_goto(_b.etapas[_b.i_etapa][1]);
}

// Texto de progreso para el título de la ventana
function bench_progreso() {
    var _b = global.bench;
    return "BENCHMARK exp " + string(_b.i_exp + 1) + "/" + string(array_length(_b.experimentos)) + " (" + _b.experimentos[_b.i_exp][0] + ")"
        + " rep " + string(_b.rep) + "/" + string(_b.repeticiones)
        + " nivel " + string(_b.i_etapa + 1) + "/" + string(array_length(_b.etapas));
}


// ============================================================ AYUDAS

function bench_escribir(_archivo, _linea) {
    var _f = file_text_open_append(_archivo);
    file_text_write_string(_f, _linea);
    file_text_writeln(_f);
    file_text_close(_f);
}

// Une valores con comas. Los decimales van con 4 cifras (string() solo pondría 2).
function bench_csv(_valores) {
    var _txt = "";
    for (var _i = 0; _i < array_length(_valores); _i++) {
        var _v = _valores[_i];
        if (_i > 0) _txt += ",";
        if (is_string(_v)) _txt += _v;
        else if (frac(_v) == 0) _txt += string(_v);
        else _txt += string_format(_v, 1, 4);
    }
    return _txt;
}

function bench_dos(_n) {
    if (_n < 10) return "0" + string(_n);
    return string(_n);
}
