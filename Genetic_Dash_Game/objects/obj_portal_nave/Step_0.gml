var _j = instance_place(x, y, obj_jugador);
if (_j != noone && !usado) {
    usado = true;
    if (_j.modo == "normal") {
        _j.modo = "nave";
        _j.sprite_index = spr_jugador_nave;
    } else {
        _j.modo = "normal";
        _j.sprite_index = spr_gato_correr;
    }
}