if (poblacion_vivos() == 0) {
    poblacion_calcular_fitness();
    var _hijos = poblacion_crear_hijos();
    poblacion_nueva_generacion(_hijos);
}