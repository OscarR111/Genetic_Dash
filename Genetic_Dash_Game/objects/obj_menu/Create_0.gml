// En orden de dificultad. Las dos listas van en el mismo orden.
// Primero los 3 niveles base (entrenamiento) y luego los 7 de validación del PDF. Avanzado = rm_nivel_3.
// Al final quedan los niveles anteriores: los dos de Angela y la copia de prueba de Oscar.
opciones = ["Entrenar 1 (facil)", "Entrenar 2 (medio)", "Entrenar 3 (medio-alto)",
            "Facil 1", "Facil 2", "Medio 1", "Medio 2", "Medio-alto 1", "Medio-alto 2", "Avanzado (Nivel 3)",
            "Nivel 1 (Angela)", "Nivel 2 (Angela)", "Prueba bot"];
niveles = [rm_base_1, rm_base_2, rm_base_3,
           rm_facil_1, rm_facil_2, rm_medio_1, rm_medio_2, rm_medioalto_1, rm_medioalto_2, rm_nivel_3,
           rm_nivel_1, rm_nivel_2, rm_nivel_prueba_1];
sel = 0;

// --- Modo de juego (tecla B) y población inicial de los bots (tecla C) ---
if (!variable_global_exists("modo_bot")) global.modo_bot = false;          // false = jugar, true = entrenar bots
if (!variable_global_exists("origen_cerebro")) global.origen_cerebro = ""; // room cuyo campeón se carga ("" = pesos nuevos)

// Mejor fitness guardado de cada nivel (-1 = no hay campeón guardado)
records = array_create(array_length(niveles), -1);
origen_sel = -1;   // posición en 'niveles' del campeón elegido; -1 = pesos nuevos
for (var _i = 0; _i < array_length(niveles); _i++) {
    records[_i] = guardado_record(room_get_name(niveles[_i]));
    if (records[_i] >= 0 && room_get_name(niveles[_i]) == global.origen_cerebro) origen_sel = _i;
}
if (origen_sel == -1) global.origen_cerebro = "";

// --- Benchmark (tecla X, ver scr_benchmark) ---
// Si se volvió al menú en medio de un benchmark (pausa y M), se cancela
if (bench_activo()) {
    global.bench.activo = false;
    audio_master_gain(1);
}
var _aj = bench_ajustes();
bench_info = string(array_length(bench_experimentos())) + " experimentos x " + string(_aj.repeticiones) + " repeticiones";

if (!audio_is_playing(mus_Menu_Summer)) {
    audio_stop_all();
    audio_play_sound(mus_Menu_Summer, 1, true);
}