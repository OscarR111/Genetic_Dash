cam = view_get_camera(0);
cam_w = camera_get_view_width(cam);
cam_h = camera_get_view_height(cam);
target = obj_jugador;

var _cancion =  mus_rm1_Solitude
if (room == rm_nivel_2) _cancion = mus_rm2_Stars;
if (room == rm_nivel_3) _cancion = mus_rm3_Remember;
if (!audio_is_playing(_cancion)) {
    audio_stop_all();
    audio_play_sound(_cancion, 1, true);
}