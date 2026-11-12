var _j = instance_place(x, y, obj_jugador);
if (_j != noone && _j.vel_y >= 0) {
	_j.vel_y = -26 * _j.escala
	audio_play_sound(orbe_efect, 1, false)
}
