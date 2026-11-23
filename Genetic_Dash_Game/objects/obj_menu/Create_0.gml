opciones = ["Nivel 1", "Nivel 2", "Nivel 3", "Nivel bot 1"];
niveles = [rm_nivel_1, rm_nivel_2, rm_nivel_3, rm_nivel_prueba_1];
sel = 0;

if (!audio_is_playing(mus_Menu_Summer)) {
    audio_stop_all();
    audio_play_sound(mus_Menu_Summer, 1, true);
}