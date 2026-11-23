// --- PARÁMETROS (se editan solo aquí) ---
tam_poblacion = 50;     // cuántos bots por generación
prob_mutacion = 50;     // probabilidad de mutar cada número, en % (10 = 10 %)
paso_mutacion = 1.5;    // cuánto puede cambiar un número al mutar (±)
k_torneo = 3;           // participantes en cada torneo
n_mutantes = 15;        // copias mutadas del campeón en cada generación
tipo_seleccion = 1;     // 1 = torneo, 2 = ruleta
tipo_mutacion = 1;      // 1 = suma, 2 = reemplazo
tipo_pesos = 2;         // pesos iniciales: 1 = aleatorios, 2 = iguales, 3 = nulos
valor_pesos = 0.5;      // el valor que usan todos los pesos si tipo_pesos es 2
umbral = 0.5;           // la red salta si su salida es mayor que este valor
bots = [];



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