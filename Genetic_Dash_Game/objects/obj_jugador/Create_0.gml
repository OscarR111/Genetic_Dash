// --- FÍSICA ---
// El sprite del cubo mide 64 px. El juego se diseñó con un cubo de 94 px, así que
// todas las velocidades y fuerzas se multiplican por 'escala' (64 / 94): el salto
// y la velocidad se sienten igual que antes, solo que en un cubo más pequeño.
escala = 64 / 94;

vel_x = 6 * escala;
vel_y = 0;
grav = 0.8 * escala;
fuerza_salto = -19 * escala;
en_suelo = false;
modo = "normal";
nave_empuje = -0.6 * escala;
nave_grav = 0.4 * escala;
nave_vel_max = 7 * escala;
// Hitbox fija: el cuadrado de 64x64 de spr_jugador (el gato se dibuja encima).
mask_index = spr_jugador;
