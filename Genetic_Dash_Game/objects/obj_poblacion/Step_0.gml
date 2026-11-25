if (terminada) exit;   // el entrenamiento ya terminó (un bot ganó, o el benchmark está cambiando de nivel)

if (poblacion_vivos() == 0) {
    poblacion_calcular_fitness();
    poblacion_guardar();
    poblacion_avisar_victoria();
    if (bench_activo() && bench_fin_generacion()) exit;   // el benchmark anota la generación y decide si sigue
    if (ganadores_ultima > 0) {   // un bot llegó a la meta: se detiene el entrenamiento (misma condición que el aviso de victoria)
        poblacion_detener();
        exit;
    }
    var _hijos = poblacion_crear_hijos();
    poblacion_nueva_generacion(_hijos);
}