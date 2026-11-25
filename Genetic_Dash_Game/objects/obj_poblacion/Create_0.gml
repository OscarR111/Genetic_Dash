// Este objeto solo trabaja si en el menú se eligió el modo BOT (tecla B) o el benchmark (tecla X).
// En modo JUGAR se borra a sí mismo y el nivel se juega normal.
if (!variable_global_exists("modo_bot")) global.modo_bot = false;
if (!global.modo_bot && !bench_activo()) {
    instance_destroy();
    exit;
}

// --- PARÁMETROS (se editan solo aquí) ---
tam_poblacion = 50;     // cuántos bots por generación
prob_mutacion = 20;     // probabilidad de mutar cada número, en % (10 = 10 %)
paso_mutacion = 1;      // cuánto puede cambiar un número al mutar (±)
k_torneo = 3;           // participantes en cada torneo
frac_mutantes = 0.2;    // fracción de la población que son copias mutadas del campeón (0.2 = 20 %)
n_mutantes = floor(tam_poblacion * frac_mutantes);   // con 50 bots salen 10
tipo_seleccion = 1;     // 1 = torneo, 2 = ruleta
tipo_mutacion = 1;      // 1 = suma, 2 = reemplazo
tipo_pesos = 1;         // pesos iniciales: 1 = aleatorios, 2 = iguales, 3 = nulos
valor_pesos = 0.5;      // el valor que usan todos los pesos si tipo_pesos es 2
umbral = 0.5;           // la red salta si su salida es mayor que este valor
tasa_seleccion = 1;     // fracción de la generación que puede ser padre (1 = todos, 0.2 = el mejor 20 %)
bots = [];

// En el benchmark (tecla X del menú) los parámetros y la semilla los pone scr_benchmark
if (bench_activo()) bench_aplicar_config();



// Buscar al jugador colocado en el room: de ahí salen la posición y la capa de los bots
var _base = instance_find(obj_jugador, 0);
inicio_x = _base.x;
inicio_y = _base.y;
capa = _base.layer;
instance_destroy(_base);

// Crear los bots
for (var _i = 0; _i < tam_poblacion; _i++) {
    var _bot = instance_create_layer(inicio_x, inicio_y, capa, obj_jugador);
    _bot.es_bot = true;
    _bot.cerebro = nn_crear_cerebro(tipo_pesos, valor_pesos);
    array_push(bots, _bot);
}

generacion = 1;
terminada = false;

meta_x = room_width;
if (instance_exists(obj_meta)) meta_x = obj_meta.x;

fitness = array_create(tam_poblacion, 0);

hist_mejor = [];
hist_peor = [];
hist_prom = [];

var _nombre_sel = "torneo";
if (tipo_seleccion == 2) _nombre_sel = "ruleta";
var _nombre_mut = "suma";
if (tipo_mutacion == 2) _nombre_mut = "reemplazo";
var _nombre_pes = "aleatorios";
if (tipo_pesos == 2) _nombre_pes = "iguales (" + string(valor_pesos) + ")";
if (tipo_pesos == 3) _nombre_pes = "nulos";
show_debug_message("=== Selección: " + _nombre_sel + " | Mutación: " + _nombre_mut + " | Pesos: " + _nombre_pes + " | Umbral: " + string(umbral) + " ===");

// --- VELOCIDAD DE ENTRENAMIENTO (la lógica está en el evento Begin Step) ---
velocidad = 1;              // pasos de simulación por cuadro. Teclas: 1 = x1, 2 = x5, 3 = x20, 4 = máximo (vale 0)
dibujar = true;             // tecla V: dejar de dibujar para ir más rápido
pasos_cuadro = 1;           // pasos que de verdad se lograron en el último cuadro
tiempo_con_dibujo = 9000;   // microsegundos por cuadro para simular cuando se dibuja (un cuadro dura 16 667)
tiempo_sin_dibujo = 14500;  // lo mismo cuando no se dibuja
cuadros = 0;
titulo_ventana = window_get_caption();
pasos_total = 0;            // pasos de simulación desde que empezó el nivel
tiempo_etapa = get_timer(); // momento en que empezó el nivel (para medir el tiempo de convergencia)

// --- ZONA ACTIVA: solo quedan encendidas las piezas cercanas a los bots ---
desactivar_lejanos = true;  // fijo. Solo para depurar: false = todo el nivel encendido siempre (más lento)
zona_vista = 1300;          // mientras se dibuja, se enciende todo lo que cabe en pantalla (no se ve ningún corte)
zona_atras = 300;           // sin dibujar: píxeles encendidos detrás del bot más atrasado
zona_extra = 150;           // holgura delante de lo que ven los sensores
zona_viaje_max = 1500;      // cuánto puede avanzar un bot en un solo cuadro a velocidad máxima
zona_inicio = 1000;         // tramo del principio del nivel que siempre queda encendido
zona_generacion = -1;       // generación para la que se calculó la zona
zona_limite = 0;            // hasta qué x pueden llegar los bots con la zona actual

// x del bot vivo más adelantado (o un número muy bajo si no queda ninguno)
lider_x = function() {
    var _max = -1000000000;
    for (var _i = 0; _i < array_length(bots); _i++) {
        if (bots[_i].vivo && bots[_i].x > _max) _max = bots[_i].x;
    }
    return _max;
};

// Enciende las piezas cercanas a los bots y apaga las demás.
// GameMaker aplica estos cambios al terminar el evento, por eso se llama al final del Begin Step.
actualizar_zona = function() {
    zona_generacion = generacion;
    if (!desactivar_lejanos) {
        zona_limite = 1000000000;
        return;
    }

    var _min = 1000000000;
    var _max = -1000000000;
    var _vision = 400;
    for (var _i = 0; _i < array_length(bots); _i++) {
        var _b = bots[_i];
        if (_b.vivo) {
            if (_b.x < _min) _min = _b.x;
            if (_b.x > _max) _max = _b.x;
            _vision = _b.vision;
        }
    }
    // Si no queda nadie vivo se deja la zona como está: el tramo del principio,
    // donde nace la siguiente generación, siempre está encendido.
    if (_max < _min) return;

    var _viaje = zona_viaje_max;
    if (velocidad > 0) _viaje = velocidad * 6;

    var _atras = zona_atras;
    var _delante = _viaje + _vision + zona_extra;
    // Mientras se dibuja, la zona cubre toda la pantalla para que no se vea ningún corte
    if (dibujar) {
        _atras = max(_atras, zona_vista);
        _delante = max(_delante, _viaje + zona_vista);
    }

    var _izq = _min - _atras;
    var _der = _max + _delante;
    zona_limite = _max + _viaje;

    instance_activate_region(_izq, -100000, _der - _izq, 200000, true);
    instance_deactivate_region(_izq, -100000, _der - _izq, 200000, false, true);
    instance_activate_region(inicio_x - zona_atras, -100000, zona_atras + zona_inicio, 200000, true);
    instance_activate_object(obj_jugador);
    instance_activate_object(obj_camara);
    instance_activate_object(obj_pausa);
};

// --- VICTORIAS (ver poblacion_avisar_victoria en scr_guardado) ---
primera_victoria = -1;      // generación en la que un bot llegó a la meta por primera vez (-1 = todavía ninguno)
ganadores_ultima = 0;       // cuántos bots llegaron a la meta en la última generación terminada
tiempo_inicio = get_timer();
tiempo_victoria = 0;        // segundos reales de entrenamiento hasta la primera victoria

// --- CEREBROS GUARDADOS (funciones en scr_guardado) ---
// Mejor fitness que ya hay guardado de este nivel (-1 = ninguno). Solo se guarda si se supera.
record_guardado = guardado_record(room_get_name(room));

// Población inicial: si en el menú se eligió el campeón de un nivel (tecla C),
// los bots arrancan con ese cerebro y copias mutadas de él, en vez de los pesos nuevos.
origen = "";
if (variable_global_exists("origen_cerebro")) origen = global.origen_cerebro;
sembrado = false;
if (origen != "") sembrado = poblacion_sembrar(origen);

if (sembrado) show_debug_message("=== Poblacion inicial: campeon de " + origen + " ===");
else show_debug_message("=== Poblacion inicial: pesos nuevos ===");

// En el benchmark: velocidad máxima, sin dibujar y los cerebros que tocan en este nivel
if (bench_activo()) bench_preparar();