sel += keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
sel = clamp(sel, 0, array_length(opciones) - 1);
if (keyboard_check_pressed(vk_enter)) room_goto(niveles[sel]);