# Guía para crear niveles — Genetic Dash

## Cómo abrir el proyecto
- Abrir `Genetic_Dash_Game/Genetic_Dash_Game.yyp` con **GameMaker LTS 2026** (IDE 2026.0.0.16, runtime 2026.0.0.23). Con otra versión puede pedir actualizar o no abrir.
- Todo lo que el juego necesita está dentro de `Genetic_Dash_Game/` (sprites, objetos, rooms).
- La carpeta `Assets/` (packs de arte originales, 99 MB) **no se sube al repositorio** (está en `.gitignore`). Solo hace falta si se quiere importar arte nuevo.
- No editar archivos del proyecto a mano mientras GameMaker los tiene abiertos: el IDE puede pisar el cambio o confundirse.

## Crear un nivel nuevo
1. Duplicar `rm_nivel_3` (clic derecho en el room) para heredar fondos, cámara, jugador, meta y pausa, y borrar las instancias que sobren. O crear una room vacía y copiar esas piezas.
2. Un nivel necesita, en la capa `Instances`: `obj_jugador` en `(64, 704)`, `obj_camara`, `obj_pausa` y `obj_meta`. La room debe tener las vistas activadas: vista 0 de 1208×720 en una pantalla de 1366×768 (la cámara lee ese tamaño y sigue al jugador).
3. Añadirlo al menú en `objects/obj_menu/Create_0.gml`: un texto nuevo en `opciones` y la room en `niveles`, **en el mismo orden**.
4. `obj_meta` al tocarla devuelve a `rm_menu`.

## Medidas y físicas
- Alto de la room: 768. Cuadrícula de 32. El nivel 3 mide 56 000 de ancho.
- **Suelo:** `obj_suelo` (sprite `spr_floor`), escala `(0.47771502, 0.3574297)`, `y = 689`, una ficha cada **760 px** desde `x = 0` (cada ficha mide 761, solapan 1 px). Su superficie de colisión queda en `y ≈ 702,6` (el diseño original usa 704).
- **Jugador (gato):** hitbox fija de 64×64 (`spr_jugador`), origen en los pies. Las velocidades se multiplican por `escala = 64/94`, para que se sienta como el diseño original de 94 px (`obj_jugador/Create_0.gml`).
  - Salto desde el suelo: altura ≈ 154 px, alcance horizontal ≈ 194 px.
  - Trampolín: altura ≈ 288 px. Orbe: impulso de unos 72 px sobre el punto donde se pulsa.
  - Cálculos aproximados con la física actual; comprobar jugando.
- **Modo nave:** cada `obj_portal_nave` alterna entre cubo y nave. La hitbox sigue siendo 64×64.
- Todo contacto con `obj_demon`, `obj_slime`, `obj_bat`, `obj_mossy1` u `obj_techo_invisible` **reinicia el nivel**. `obj_mossy1`, `obj_suelo` y `obj_techo_invisible` heredan de `obj_suelo`, así que son sólidos y se puede aterrizar encima.

## Cómo colocar cada pieza
`X` es el centro horizontal de la pieza y `Y` su base. Las medidas salen de reemplazar los peligros originales sin cambiar su zona letal.

| Pieza | Objeto | Escala | Posición de la instancia | Hitbox en el mundo |
|---|---|---|---|---|
| Peligro de suelo (1 por columna de 32 px) | `obj_demon` | `(−2, 2)` | `x = X + 38`, `y = 654` (base en 704) | triángulo de 32×32 centrado en X, `y 672..704` |
| Peligro doble (2 columnas contiguas) | `obj_slime` | `1` | `x = X1 − 16`, `y = 670` (X1 = centro de la 1.ª columna) | rectángulo de 64×32, `y 672..704` |
| Peligro volador | `obj_bat` | `(−1, 1)` | `x = X + 48`, `y = Y − 64` | rectángulo de 28×16: `x X−14..X+14`, `y Y−18..Y−2` |
| Trampolín | `obj_trampolin_magico` | `(0.6667, 0.4839)` | `x = (esquina izquierda del pad) − 32`, `y = Y − 64` | rectángulo de 64×19: `x..x+64`, `y Y−19..Y` |
| Orbe de salto | `obj_orbe_magico` | `1` | `x = Cx − 96`, `y = Cy − 96` (C = centro del orbe) | cuadrado de 48×48 centrado en C |
| Bloque decorado | `obj_mossy1` | `sx = w/1289`, `sy = h/1272` | `x = x0 + 630·sx`, `y = y0 − 68·sy` (caja `x0, y0, w, h`) | exactamente la caja `x0, y0, w, h`; la grama sobresale sin hitbox |
| Portal de nave | `obj_portal_nave` | `1` | `y = 704` | rectángulo de 47×71 |
| Meta | `obj_meta` | `(2, 12)` | `y = 0` | 128×768 |
| Techo de zona de nave | `obj_techo_invisible` | `x = ancho/32`, `y = 2` | `y = 64` (cubre `64..128`) | cierra el pasillo superior |

Zonas de nave: los bloques que cuelgan deben empezar en `y = 128`. Con el techo en `64..128` no queda hueco por encima. Si el techo queda más arriba, se abre un pasillo por el que el jugador rodea los obstáculos.

## Fondos
Hay 12 capas de fondo (`bg_layer_*`, `bg_lighting_*`) con *Tile Horizontal* activado y `y = −281`, por debajo de la capa `Instances`. Duplicar `rm_nivel_3` las trae ya colocadas. El orden de profundidad (de delante hacia atrás) es: 10, 8, 7, 6, luz 2, 5, 4, luz 1, 3, 2, 1, 0.

## Música
- Hay una canción para el menú (`mus_Menu_Summer`) y una por nivel (`mus_rm1_Solitude`, `mus_rm2_Stars`, `mus_rm3_Remember`).
- El menú la arranca en `objects/obj_menu/Create_0.gml` y los niveles en `objects/obj_camara/Create_0.gml`, que elige la canción según la sala. Solo arranca si esa canción no está sonando, así que **al morir (`room_restart`) no se reinicia**, y se repite sola al acabar.
- Para un nivel nuevo: importar la canción como sonido y añadir una línea en `obj_camara/Create_0.gml`, por ejemplo `if (room == rm_nivel_4) _cancion = mus_rm4_Nombre;`.
- Las canciones largas conviene configurarlas como **Compressed - Streamed** en el editor de sonidos. Sin *streaming* se cargan enteras en memoria (varias decenas de MB cada una).
- La pausa (`obj_pausa`) todavía no detiene la música.

## Errores que ya nos pasaron
1. **No usar el campo de máscara de colisión de un objeto para tomar la de otro sprite.** GameMaker alinea esa máscara con el origen del sprite de la máscara y usa la escala de la instancia, así que queda desplazada y a otro tamaño (pasó con `obj_demon` y con `obj_bat`). La máscara se ajusta en el propio sprite, en modo manual.
2. **Usar una hitbox fija por sprite**, no una por cuadro de animación.
3. **Sprites con resplandor**: la máscara automática cubre todo el cuadro y es enorme. Ponerla manual.
4. **Al importar un sprite**, comprobar que el tamaño del `.yy` coincide con el de las imágenes.

## Pendientes conocidos
- Integrar el commit `2e64186` de Oscar en `rm_nivel_3` (mueve 2 bloques, desplaza el primer par de púas, quita 3 púas voladoras y mueve una plataforma con su púa). No se pudo fusionar sin decidir qué hacer con las piezas que ya se reemplazaron por assets nuevos.
- Las 16 plataformas aéreas de Abel y sus 2 techos de zona de nave no están en la versión actual de `rm_nivel_3`.
- Revisar en `rm_nivel_3`: la segunda ficha del suelo está en `x = 768` (deja 7 px de hueco), el techo invisible está en `y = 0..32` y el primer portal está estirado (escala vertical 2,35).
- Los slimes son más letales que las púas que reemplazan (rectángulo contra triángulos). La hitbox del gato es de 64×64 y su dibujo es más bajo.
- Los niveles 1 y 2 ya usan los assets nuevos y los 12 fondos, pero aún conservan púas viejas (`obj_pua`: 53 en el nivel 1 y 14 en el 2) sin convertir. `Room1` sigue entera con los objetos antiguos (`obj_pua`, `obj_bloque`, `obj_trampolin`, `obj_orbe`).
- Créditos y licencias de los assets: ver `CREDITOS.md`.
