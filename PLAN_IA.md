# Plan de la IA — Genetic Dash

Documento de trabajo. Se actualiza a medida que avanzamos.
Requisitos: `Descripción Proyecto Genetic Dash.pdf` (carpeta de arriba).

Leyenda: `[x]` hecho y probado en GameMaker · `[~]` hecho, falta probar en GameMaker · `[ ]` pendiente

Última actualización: 2026-11-24

---

## 1. Lo que pide el PDF y cómo vamos

### 3.1 Juego

| Punto | Requisito | Estado |
|---|---|---|
| 3.1.1 | Running constante | Hecho |
| 3.1.2 | Púa que mata | Hecho |
| 3.1.3 | Muere al chocar de frente con un bloque sólido | Hecho (se puede aterrizar encima sin morir) |
| 3.1.4 | Trampolín más alto que el salto normal | Hecho |
| 3.1.5 | Orbe de doble salto | Hecho |
| 3.1.6 | Nave: se activa con un **portal de nave** y se desactiva con un **portal de normalidad** | **Parcial:** hay un solo portal que alterna. No existe un portal de normalidad distinto |
| 3.1.7 | 3 niveles base | Hecho: `rm_base_1`, `rm_base_2`, `rm_base_3` (sin probar en GameMaker) |
| 3.1.8 | Gráfica y sonoramente adecuado | Hecho. Faltan créditos de arte y música (`CREDITOS.md`) |

### 3.2 Optimizador

| Requisito | Estado |
|---|---|
| Al menos 1 actuador | Hecho (saltar) |
| Al menos 5 sensores | Hecho (9) |
| Red de 3 capas mínimo | Hecho (9 – 4 – 1) |
| Optimización con algoritmos genéticos | Hecho |
| Rendimiento según qué tan lejos llega | Hecho |
| Al menos 1 función de cruce | Hecho (uniforme) |
| Al menos 2 funciones de mutación | Hecho (suma y reemplazo) |
| Al menos 2 funciones de selección | Hecho (torneo y ruleta) |

### 3.3 Validación y benchmark

| Punto | Requisito | Estado |
|---|---|---|
| 3.3.1 | 7 niveles: 2 bajos, 2 medios, 2 medio-altos, 1 avanzado | Hecho (sin probar en GameMaker) |
| 3.3.2 | Entrenamiento incremental: ganador del nivel 1 → nivel 2 → nivel 3 | Hecho (tecla `C` del menú). Probado solo en simulación |
| 3.3.3 | Probar en los niveles de validación, nivel a nivel (¿sobreajuste?) | Hecho en el benchmark (sin probar en GameMaker) |
| 3.3.4 | Validación final en el avanzado | Hecho en el benchmark (sin probar en GameMaker) |
| 3.3.5 | Benchmark cualitativo | **Falta** (ya hay hallazgos en el apartado 4) |
| 3.3.6.a | Métricas: tiempo de convergencia, generaciones de convergencia, % de completitud y tasa de éxito en validación | Hecho: se registran en CSV (sin probar en GameMaker) |
| 3.3.6.b | Variables: pobladores, prob. de mutación, peso inicial, tasa de selección, técnicas de mutación, selección y cruce, umbral | Hecho: todas son parámetros y hay 13 experimentos listos |
| 3.3.6.c | Tablas (gráficas opcionales) | Hecho: `benchmark/analizar.py` (probado con datos inventados) |

### IV. Recomendaciones (no obligatorias)

| Recomendación | Estado |
|---|---|
| Entrenar de forma incremental | Hecho |
| Congelar los sensores de mecánicas que no están en el nivel | No hecho |
| Probar una red *shallow* (sin capa oculta) | No hecho |
| Normalizar las salidas | Hecho (sensores divididos entre 400; tanh y sigmoide) |

### Encabezado de la sección III

El PDF dice "desarrollar un agente inteligente de IA **con python**". El proyecto está hecho en GameMaker (GML). **Confirmado con el profesor (24/11): vale GameMaker.**

---

## 2. Orden de trabajo

### Prioridad 0 — Antes de seguir

1. [x] **Confirmar con el profesor lo de Python.** Vale GameMaker.
2. [ ] **Probar en GameMaker lo hecho hasta hoy** (pruebas en el apartado 5). Del juego real solo está comprobado el guardado de campeones.
3. [ ] **Guardar en git y subir.** Hay más de 20 archivos sin commit: los 9 niveles nuevos, el guardado, la aceleración y el menú. Avisar a Oscar antes, para no pisarse.

### Prioridad 1 — Código que falta para el benchmark

4. [~] **Semilla por corrida.** El benchmark fija la semilla con `random_set_seed` (la doc de GameMaker confirma que sin `randomize()` cada ejecución repite los mismos números). La semilla depende de la repetición y del nivel, así que todos los experimentos usan las mismas.
5. [~] **Parámetro `tasa_seleccion`** en `obj_poblacion` (1 = todos pueden ser padres; 0,2 = solo el mejor 20 %). Función `preparar_padres` en `scr_seleccion`.
6. [~] **Registro CSV** por generación y por nivel, con **criterio de convergencia** (un bot llega a la meta) y tope de generaciones.
7. [~] **Validación automática:** la población final de cada entrenamiento juega una partida en sus 2 niveles de validación, sin evolucionar.
8. [~] **Cola de experimentos:** script `scr_benchmark`, tecla `X` del menú.

### Prioridad 2 — Correr y escribir

9. [ ] Revisar las decisiones del apartado 3 (el benchmark ya usa las propuestas).
10. [ ] Correr el benchmark (primero una prueba corta para medir cuánto tarda).
11. [~] **Script de Python** `benchmark/analizar.py`: lee los CSV y arma las tablas del PDF y dos gráficas. Probado con datos inventados.
12. [ ] Redactar el benchmark cualitativo (base: apartado 4).

### Cómo correr el benchmark

1. **Qué se prueba:** en `scr_benchmark`, arriba del todo. `bench_ajustes` (repeticiones y tope de generaciones), `bench_base` (configuración base, igual a la de `obj_poblacion`) y `bench_experimentos` (13 experimentos; cada uno cambia una sola variable respecto a la base).
2. **Lanzarlo:** en el menú, tecla `X`. Corre solo, sin dibujar y sin sonido. El avance se ve en el título de la ventana. Al terminar vuelve al menú. Para cancelar: `Esc` y `M`.
3. **Cada corrida** hace el ciclo del PDF: entrena Entrenar 1 desde cero → valida en Fácil 1 y 2 → entrena Entrenar 2 desde ese campeón → valida en Medio 1 y 2 → entrena Entrenar 3 → valida en Medio-alto 1 y 2 y en el Avanzado.
4. **Datos:** en `%LOCALAPPDATA%\Genetic_Dash_Game\`, dos archivos por benchmark: `bench_<fecha>_generaciones.csv` (una fila por generación de entrenamiento) y `bench_<fecha>_resultados.csv` (una fila por nivel jugado, con los parámetros usados).
5. **Tablas y gráficas:** `python benchmark/analizar.py` (necesita `pandas` y `matplotlib`). Toma el benchmark más reciente y deja en `benchmark/resultados/<fecha>/`: una tabla por tipo de nivel como el ejemplo del PDF, la tabla de tasa de éxito por tipo de nivel, las curvas de convergencia y una gráfica de barras.

**Antes del benchmark completo:** correr una prueba corta (por ejemplo, `repeticiones: 1` y solo los 2 primeros experimentos) para medir cuánto tarda en tu equipo y calcular el total.

### Prioridad 3 — Cumplimiento fino y mejoras

13. [ ] **Portal de normalidad** distinto del portal de nave (3.1.6 los nombra como dos portales).
14. [ ] **Red shallow** como variable extra del benchmark (recomendación IV.3).
15. [ ] **Créditos y licencias** de arte y música en `CREDITOS.md`.
16. [ ] Opcional: mejorar la generalización (separaciones más variadas al entrenar, campeón más robusto).
17. [ ] Opcional: congelar sensores según el nivel (recomendación IV.2).

---

## 3. Decisiones pendientes

- [x] **Python:** vale GameMaker.
- [ ] **Qué es "converger".** Propuesta: la primera generación en que un bot llega a la meta, con un tope de generaciones.
- [ ] **Qué campeón se guarda.** Hoy, el primero que gana (suele ser 1 de 50). Alternativa: seguir unas generaciones y guardar cuando gane cierto % de la población.
- [ ] **Tasa de éxito en validación.** Propuesta: % de la población final que completa el nivel. Alternativa: % de corridas cuyo campeón lo completa.
- [ ] **Corridas por configuración** (3 a 5 semillas) y **tope de generaciones**.
- [ ] **Configuración base del benchmark**, de la que se cambia una variable a la vez.

---

## 4. Hallazgos (base para el benchmark cualitativo)

Salen de una simulación en Python (`..\herramientas_niveles\ciclo.py`) que reproduce la física, los 9 sensores, la red 9-4-1 y el algoritmo genético del juego. Da los mismos números que las pruebas reales del 23/11 (0,14 saltando siempre y 0,065 sin saltar), pero **falta confirmarlos en el juego**.

- **Ciclo completo con los parámetros actuales** (50 bots, mutación 50 % y ±1,5, torneo de 3, pesos iguales a 0,5), 20 semillas:
  - Entrenar 1: gana 20 de 20, generación mediana 12,5 (de 5 a 51).
  - Entrenar 2: gana 19 de 20, mediana 6 (de 1 a 111). Cargar el campeón anterior ayuda: varias veces gana en la generación 1.
  - Entrenar 3: gana 20 de 20, mediana 18,5 (de 1 a 167).
- **Validación del campeón:** Fácil 1 7/20, Fácil 2 20/20, Medio 1 7/20, Medio 2 7/20, Medio-alto 1 16/20, Medio-alto 2 12/20, Avanzado 0/20.
- **Sobreajuste:** los bots memorizan distancias en vez de reaccionar. Casi todas las muertes de validación caen donde la separación entre obstáculos difiere del entrenamiento. Ejemplo: en Fácil 1 la última púa está a 352 px de la anterior, y en Entrenar 1 la separación mínima es 384 px.
- **Avanzado:** todos mueren en el primer obstáculo. Ahí se ven una púa y un bloque a la vez, cosa que no ocurre en los niveles de entrenamiento.
- **Pesos iniciales** (12 semillas, tope de 200 generaciones):
  - Aleatorios: aprenden con todas las mutaciones probadas; los más rápidos (Entrenar 1 hacia la generación 4–6).
  - Nulos: aprenden incluso con mutación baja (10 % y ±0,5).
  - Iguales a 0,5: todos los bots nacen idénticos y saltando siempre. Solo aprenden con paso de mutación grande (±1,5). Con ±0,5 o menos, 0 de 12 en 200 generaciones.
- **Mutación:** lo habitual es 1–10 % por peso con un paso de 0,1–0,5. El proyecto usa 50 % y ±1,5. Entre las configuraciones que aprenden, la validación queda entre 32 y 45 de 72 sin una diferencia clara.
- **Escalera del nivel 1 de Angela:** las muertes "contra algo invisible" son la caja de choque de 64×64, más grande que el dibujo del gato (en el aire deja 16 px vacíos bajo las patas). No hay ninguna pieza invisible que mate.

---

## 5. Detalle de lo hecho y cómo probarlo

### Errores corregidos

- [~] **Sensor del orbe.** `obj_orbe_magico` ahora es hijo de `obj_orbe`, igual que el demonio es hijo de la púa. El sensor 4 (`place_meeting(x, y, obj_orbe)`) ya lo detecta. No se tocó `scr_sensores`.
- [~] **Techo invisible.** Ya no llama a `room_restart()`; mata al jugador como la púa (`morir()`). Antes, si un bot lo tocaba, se perdía el entrenamiento.
- [~] **`n_mutantes` fijo en 15.** Ahora sale de `frac_mutantes = 0.3` (30 % de la población). Con 50 bots siguen siendo 15. Con 10 bots eran todos mutantes y no había cruce.

**Cómo probarlo:** en modo BOT, entrar a un nivel con orbes y mirar el texto "Sensores": el cuarto número debe pasar a `1.00` cuando el bot toca el orbe.

### Velocidad de entrenamiento

Todo está en `obj_poblacion` (eventos *Begin Step* y *Room End*, y parámetros al final de *Create*). No se cambió la lógica de los bots.

- [~] **Varios pasos por cuadro.** Teclas `1` = x1, `2` = x5, `3` = x20, `4` = máximo. Arranca siempre en x1.
- [~] **No dibujar.** Tecla `V`. El progreso se sigue viendo en el título de la ventana.
- [~] **Zona activa.** Solo quedan encendidas las piezas cercanas a los bots. Mientras se dibuja cubre toda la pantalla, así que no se ve ningún corte. Fija, sin tecla ni texto; para depurar se apaga con `desactivar_lejanos = false` en el *Create*.
- [~] **Texto en pantalla:** generación, vivos y velocidad real lograda.
- [~] **Aviso de victoria** en la consola, en pantalla y en el título de la ventana: en qué generación ganó el primer bot y cuántos ganaron en la última.
- [~] **Parada al ganar** (fuera del benchmark): en cuanto una generación tiene un ganador, el entrenamiento se detiene. No se crea otra generación, el campeón ya quedó guardado, vuelve a x1 y a dibujar, y en pantalla dice cómo seguir (`Esc` y `M` al menú, `Esc` y `R` empezar de nuevo). Función `poblacion_detener` en `scr_guardado`.

**Cómo probarlo:**
1. Entrar a un nivel en modo BOT sin tocar nada: debe verse igual que antes.
2. Pulsar `2`, `3` y `4`: el texto "velocidad real" debe subir.
3. Pulsar `V`: la imagen se congela y el título de la ventana sigue cambiando de generación.
4. Pulsar `Esc` (pausa) y luego `M`: el menú debe verse normal.
5. **Importante:** entrenar un rato en máximo, volver a `1` y mirar que el mejor bot llega igual de lejos que el "mejor anterior" del título. Si no coincide, hay una diferencia entre rápido y normal.
6. Si los bots atraviesan piezas, poner `desactivar_lejanos = false` y repetir, para saber si la culpa es de la zona activa.

### Guardar y cargar cerebros

Funciones en el script `scr_guardado`. En el código de Oscar solo se agregaron dos líneas en el *Step* de `obj_poblacion` (`poblacion_guardar();` y `poblacion_avisar_victoria();`).

- [x] **Guardar.** Comprobado en el juego (23/11). Al terminar cada generación se guarda el campeón y toda la población, pero solo si llegaron más lejos que lo ya guardado de ese nivel. Un archivo por nivel: `campeon_<room>.json`.
- [~] **Cargar.** En el menú, la tecla `C` elige de qué nivel tomar el campeón. Los bots arrancan con ese cerebro (puesto 0) y copias mutadas de él. Indicio de que funciona: en una prueba del 23/11, Fácil 2 se ganó en la generación 1.
- [~] **Interruptor jugar / bot.** Tecla `B` del menú. En modo JUGAR `obj_poblacion` se borra solo y el nivel se juega normal.
- [~] `obj_poblacion` está en todos los niveles.

**Dónde quedan los archivos:** `%LOCALAPPDATA%\Genetic_Dash_Game\`. Para empezar un nivel de cero, borrar su archivo.

**Ojo:** el juego arranca en modo JUGAR. Para entrenar hay que pulsar `B` en el menú antes de entrar al nivel.

**Cómo probarlo:**
1. Sin pulsar nada en el menú, entrar a "Nivel 2 (Angela)": debe jugarse a mano.
2. Volver al menú, pulsar `B` y entrar a "Entrenar 1": deben salir los bots.
3. Dejar pasar unas generaciones. "Campeon guardado de este nivel" debe pasar de "ninguno" a un porcentaje.
4. Volver al menú (`Esc`, `M`): al lado de "Entrenar 1" debe decir "campeon: XX %".
5. Pulsar `C` hasta ver "Poblacion inicial: campeon de Entrenar 1" y entrar a "Entrenar 2": la primera generación ya debe saltar obstáculos.

### Niveles

El PDF pide 10 niveles: **3 base para entrenar** y **7 de validación**, en los que el bot no entrena.

| Se entrena en | Se valida en |
|---|---|
| `rm_base_1` — "Entrenar 1 (facil)" | `rm_facil_1`, `rm_facil_2` |
| `rm_base_2` — "Entrenar 2 (medio)" | `rm_medio_1`, `rm_medio_2` |
| `rm_base_3` — "Entrenar 3 (medio-alto)" | `rm_medioalto_1`, `rm_medioalto_2` |
| — | `rm_nivel_3` — "Avanzado", prueba final |

- [~] **Entrenamiento:**
  - `rm_base_1`: meta en x = 7680. 16 obstáculos: púas sueltas y dobles, slimes, escalones y pilares de 2 pisos.
  - `rm_base_2`: meta en x = 8256. 17 obstáculos: lo anterior más 2 trampolines con fila de púas, 2 con muro y 2 murciélagos.
  - `rm_base_3`: meta en x = 9792. 19 piezas: lo anterior más 3 filas con orbe y una sección de nave con 3 pilares.
- [~] **Fáciles:**
  - `rm_facil_1`: 16 obstáculos, solo púas. 11 sueltas y 5 dobles (2 demonios juntos o 1 slime).
  - `rm_facil_2`: 15 obstáculos. 8 púas sueltas, 4 escalones bajos de 2 a 5 columnas y 3 pilares de 2 pisos.
- [~] **Medios** (púas, escalones y pilares, trampolín y murciélagos bajos):
  - `rm_medio_1`: meta en x = 8064. 2 trampolines con fila de 4 púas, 1 trampolín con muro de 4 pisos, 2 murciélagos.
  - `rm_medio_2`: meta en x = 8192. 1 trampolín con fila de 4 púas, 2 trampolines con muro, 3 murciélagos.
- [~] **Medio-altos** (todas las mecánicas):
  - `rm_medioalto_1`: meta en x = 9728. 3 orbes, 2 trampolines, 1 murciélago y una sección de nave con 3 pilares.
  - `rm_medioalto_2`: meta en x = 9856. 3 orbes, 2 trampolines, 2 murciélagos y una sección de nave más cerca del principio.
- [x] **Avanzado:** `rm_nivel_3`. Tiene todas las mecánicas (24 trampolines, 28 orbes, 4 portales de nave).
- Los niveles de Angela (`rm_nivel_1`, `rm_nivel_2`) y la copia de prueba de Oscar (`rm_nivel_prueba_1`) **no se borraron**: siguen al final del menú.

**Orden del menú:** Entrenar 1, 2 y 3; Facil 1, Facil 2, Medio 1, Medio 2, Medio-alto 1, Medio-alto 2, Avanzado (Nivel 3); y al final Nivel 1 (Angela), Nivel 2 (Angela) y Prueba bot. Se compactó (32 px entre opciones) para que quepan las 13.

**Cómo están armados** (misma forma que los niveles 1 y 2):
- Suelo: `obj_suelo` en `y = 704`, una ficha cada 760 px. La superficie queda en `y ≈ 717,6`.
- Púa suelta: `obj_demon` en `y = 672`, escala `(-2, 2)`. Sobresale 28 px. Púa doble: dos demonios seguidos o un `obj_slime` en `y = 684`.
- Escalón bajo: columnas de `obj_mossy1` cada 32 px en `y = 672`, escala `(0.028340122, 0.049932525)`. Pilar: además cubos encima, escala `(0.028340122, 0.02834008)`.
- Trampolín + 4 púas: `obj_trampolin_magico` en `y = 640`, escala `(0.6666667, 0.48387095)`, la primera púa 144 px después. Trampolín + muro: columna de 4 pisos 224 px después.
- Murciélago bajo: `obj_bat` en `y = 544`, 224 px antes de una púa (mata al que salta demasiado pronto).
- Fila de 5 púas con orbe: `obj_orbe_magico` en `y = 512`, 64 px antes del primer demonio.
- Sección de nave: portal de entrada, 3 pilares de 2 o 3 pisos cada 480 px, portal de salida. Los portales van en `y = 718` con escala vertical 9,6 (cubren del suelo al techo para que no se puedan esquivar); se ven estirados.

**Comprobación:** todos se pasan en la simulación, con márgenes de salto menores cuanto más difícil es el nivel. El generador y el simulador están en `..\herramientas_niveles\` (fuera del repositorio).

---

## 6. Riesgos

- **Rápido contra normal.** Los pasos extra se ejecutan en un orden que puede no ser idéntico al del motor. Ver la prueba 5 de "Velocidad de entrenamiento".
- **El avanzado.** En la simulación ningún campeón pasa del primer obstáculo. Es un resultado válido para el benchmark, pero conviene saberlo antes.
- **La nave.** Ningún sensor da la altura ni la velocidad vertical. En la simulación los bots aprendieron las secciones de nave de los niveles nuevos, pero las del avanzado son más largas.

## 7. Notas técnicas

- GameMaker usa un solo núcleo del procesador. Lo que limita la velocidad es cuánto cuesta cada paso, no la potencia total del equipo.
- Encender y apagar instancias se aplica al terminar el evento. Por eso la zona activa se calcula al final del *Begin Step*.
- La compilación por terminal (igor) está bloqueada por la licencia: todo hay que probarlo desde el IDE.
