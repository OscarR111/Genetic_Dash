sel += keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
sel = clamp(sel, 0, array_length(opciones) - 1);
if (keyboard_check_pressed(vk_enter)) room_goto(niveles[sel]);

// B: cambiar entre jugar y entrenar bots
if (keyboard_check_pressed(ord("B"))) global.modo_bot = !global.modo_bot;

// X: correr el benchmark completo (ver scr_benchmark)
if (keyboard_check_pressed(ord("X"))) bench_empezar();

// C: elegir con qué cerebro arrancan los bots.
// Pasa al siguiente nivel que tenga campeón guardado; después del último vuelve a "pesos nuevos".
if (keyboard_check_pressed(ord("C"))) {
    var _nuevo = -1;
    for (var _i = origen_sel + 1; _i < array_length(niveles); _i++) {
        if (records[_i] >= 0) {
            _nuevo = _i;
            break;
        }
    }
    origen_sel = _nuevo;
    global.origen_cerebro = "";
    if (origen_sel >= 0) global.origen_cerebro = room_get_name(niveles[origen_sel]);
}