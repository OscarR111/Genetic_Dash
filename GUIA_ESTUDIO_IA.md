# Guía de estudio — la IA de Genetic Dash

Esta guía explica, en orden, cómo funciona el agente y todo lo que se agregó encima del trabajo de Oscar: arreglos, aceleración, guardado de campeones, niveles y benchmark. Está pensada para leerse de arriba abajo.

Cada sección dice **qué es**, **cómo funciona** y **dónde está en el proyecto**. Al final hay un glosario, un mapa de archivos y preguntas de repaso.

> El estado de cada tarea y lo que falta está en `PLAN_IA.md`. Esta guía es solo para entender.

---

## 1. La idea general en una frase

Cada bot es un gato con un **cerebro** (una red neuronal pequeña). El cerebro mira el nivel a través de **sensores** y decide si **saltar**. Al principio los cerebros no saben nada. Un **algoritmo genético** hace que, generación tras generación, sobrevivan y se mezclen los cerebros que llegan más lejos.

```
sensores (9 números) → red neuronal → ¿saltar?    ← esto pasa en cada paso del juego
fitness (qué tan lejos llegó) → selección, cruce, mutación → nueva generación    ← esto pasa cuando mueren todos
```

---

## 2. El agente (código de Oscar)

### 2.1 Sensores — lo que "ve" el bot

**Dónde:** `scripts/scr_sensores` (función `sensores_calcular`).

Son 9 números. Las distancias se dividen entre la **visión** (400 px), así que valen entre 0 (pegado) y 1 (no hay nada a la vista). A eso se le llama **normalizar**: la red trabaja mejor si todos los números están en la misma escala.

| # | Sensor | Valor |
|---|---|---|
| 1 | ¿Está en el suelo? | 0 o 1 |
| 2 | Distancia a la púa más cercana al frente, a su altura | 0 a 1 |
| 3 | Distancia al bloque más cercano al frente, a su altura | 0 a 1 |
| 4 | ¿Está tocando un orbe? | 0 o 1 |
| 5 | ¿Está en modo nave? | 0 o 1 |
| 6 | Distancia al bloque más cercano al frente, **por encima** | 0 a 1 |
| 7 | Distancia al bloque más cercano al frente, **por debajo** | 0 a 1 |
| 8 | Distancia a la púa más cercana al frente, por encima | 0 a 1 |
| 9 | Distancia a la púa más cercana al frente, por debajo | 0 a 1 |

"Púa" incluye todo lo que hereda de `obj_pua`: demonios, slimes y murciélagos. "Bloque" incluye `obj_mossy1`.

### 2.2 Red neuronal — el cerebro

**Dónde:** `scripts/scr_cerebro`.

Tiene 3 capas: **9 entradas → 4 neuronas ocultas → 1 salida**.

```
oculta = tanh(sensores × w1 + b1)      ← 4 números entre -1 y 1
salida = sigmoide(oculta × w2 + b2)    ← 1 número entre 0 y 1
salta si salida > umbral (0,5)
```

- **Pesos (`w1`, `w2`):** cuánto importa cada entrada para cada neurona. Son lo que el algoritmo genético va ajustando.
- **Sesgos (`b1`, `b2`):** un número que se suma a cada neurona, como un "punto de partida".
- En total, un cerebro son **45 números**: 36 + 4 + 4 + 1. El algoritmo genético solo cambia esos 45 números.
- **tanh** y **sigmoide** son funciones de activación: aplastan cualquier número a un rango fijo (−1 a 1, o 0 a 1). Eso es lo que hace que la red pueda aprender cosas no lineales.
- **Umbral:** convierte la salida en una decisión de sí o no. Es la "técnica de thresholding" que pide el PDF.

### 2.3 El actuador — cómo actúa

**Dónde:** `objects/obj_jugador/Step_0`.

La única acción es **pulsar** (como el clic del jugador):
- `input`: la red quiere pulsar en este paso. En el suelo, salta; en nave, sube.
- `input_pressed`: la pulsación es **nueva** (antes no pulsaba). Hace falta para el orbe, que solo funciona con una pulsación nueva en el aire.

### 2.4 Fitness — la nota de cada bot

**Dónde:** `scripts/scr_poblacion` (función `poblacion_calcular_fitness`).

```
fitness = (x donde murió − x de inicio) / (x de la meta − x de inicio)     ← entre 0 y 1
fitness = 1 si llegó a la meta
```

Es lo que pide el PDF: el rendimiento depende de **qué tan lejos llega**.

### 2.5 Algoritmo genético — cómo se forma la siguiente generación

**Dónde:** `scripts/scr_poblacion` (`poblacion_crear_hijos`), `scr_seleccion`, `scr_cruce`, `scr_mutacion`.

Cuando mueren todos los bots, se arma la generación siguiente así (con 50 bots):

| Puestos | Qué son | Para qué |
|---|---|---|
| 1 | El **campeón** sin cambios | **Elitismo:** nunca se pierde lo mejor que se encontró |
| 15 (30 %) | **Copias mutadas del campeón** | Buscar mejoras cerca de lo que ya funciona |
| 34 | **Hijos:** se eligen dos padres, se cruzan y el hijo se muta | Combinar ideas de distintos bots |

**Selección** (cómo se eligen los padres):
- **Torneo** (`tipo_seleccion = 1`): se toman `k_torneo` bots al azar (3) y gana el de mayor fitness.
- **Ruleta** (`tipo_seleccion = 2`): cada bot tiene una probabilidad proporcional a su fitness.

**Cruce uniforme** (`scr_cruce`): para cada uno de los 45 números, el hijo lo toma de un padre o del otro con un 50 % de probabilidad.

**Mutación** (`scr_mutacion`), con probabilidad `prob_mutacion` para cada número:
- **Suma** (`tipo_mutacion = 1`): se le suma un valor al azar entre −`paso_mutacion` y +`paso_mutacion`.
- **Reemplazo** (`tipo_mutacion = 2`): se cambia por un valor nuevo al azar entre −1 y 1.

**Pesos iniciales** (`tipo_pesos`), cómo nace la primera generación:
- **1 = aleatorios:** cada número al azar entre −1 y 1.
- **2 = iguales:** todos valen `valor_pesos` (0,5). Todos los bots nacen idénticos.
- **3 = nulos:** todos valen 0.

Todos estos parámetros están al principio del *Create* de `obj_poblacion`.

---

## 3. Arreglos que se hicieron

| Problema | Qué pasaba | Arreglo |
|---|---|---|
| Sensor del orbe | Buscaba `obj_orbe`, pero los niveles usan `obj_orbe_magico`. Nunca se encendía | `obj_orbe_magico` es ahora **hijo** de `obj_orbe` (igual que el demonio es hijo de la púa). Así el sensor lo ve sin tocar su código |
| Techo invisible | Llamaba a `room_restart()`: si un bot lo tocaba, se borraba todo el entrenamiento | Ahora mata solo a ese bot, como una púa (`morir()`) |
| `n_mutantes` fijo en 15 | Con 10 bots, todos eran mutantes y no había cruce | Sale del 30 % de la población (`frac_mutantes`) |

**Idea clave — herencia (padre/hijo):** cuando un objeto es hijo de otro, `place_meeting(x, y, obj_padre)` y `with (obj_padre)` también lo incluyen. Por eso basta con cambiar el padre para que el sensor reconozca un objeto nuevo.

---

## 4. Aceleración del entrenamiento

**Dónde:** `objects/obj_poblacion`, eventos *Begin Step* (`Step_1`) y *Room End* (`Other_5`), y parámetros en el *Create*.

GameMaker corre 60 cuadros por segundo. En cada cuadro hace **un paso** de lógica (mover, chocar, decidir) y **dibuja** la pantalla. Hay tres trucos para entrenar más rápido:

### 4.1 Varios pasos por cuadro

En el *Begin Step* se repite la lógica del juego varias veces antes de dibujar:

```
mientras falten pasos y quede tiempo en este cuadro:
    with (all) event_perform(ev_step, ev_step_normal)    ← un paso completo de todos los objetos
```

Los bots viven exactamente lo mismo, paso por paso; solo se dibuja 1 de cada N cuadros. La física no cambia.

Teclas: `1` = x1, `2` = x5, `3` = x20, `4` = máximo (lo que aguante el equipo). Siempre arranca en x1.

### 4.2 No dibujar

Tecla `V`: `draw_enable_drawevent(false)`. Dibujar los 12 fondos es caro; sin dibujar caben muchos más pasos. El progreso se sigue viendo en el **título de la ventana**.

### 4.3 Zona activa

En cada paso, cada bot revisa todas las púas y bloques del nivel (sensores y choques). Como todos los bots avanzan a la misma velocidad, siempre van juntos. Por eso solo se dejan **encendidas** las piezas cercanas a ellos (`instance_activate_region` / `instance_deactivate_region`) y el resto se apaga. Cada paso cuesta mucho menos.

- Mientras se dibuja, la zona cubre toda la pantalla: no se ve ningún corte.
- No cambia el resultado: un bot nunca alcanza una pieza apagada.
- Para depurar: `desactivar_lejanos = false` en el *Create*.

**Idea clave:** GameMaker usa un solo núcleo del procesador. Lo que limita la velocidad no es la potencia total del equipo, sino cuánto cuesta cada paso.

---

## 5. Guardar y cargar cerebros

**Dónde:** `scripts/scr_guardado`.

- **Guardar:** al terminar cada generación, si el mejor bot llegó más lejos que lo ya guardado de ese nivel, se escribe `campeon_<nivel>.json` con el campeón y toda la población. Los cerebros se guardan en JSON con `json_stringify`.
- **Cargar:** en el menú, la tecla `C` elige de qué nivel tomar el campeón. La siguiente partida en modo bot arranca con ese cerebro en el puesto 1 y copias mutadas en el resto.
- **Dónde quedan:** `%LOCALAPPDATA%\Genetic_Dash_Game\`. Para empezar un nivel de cero, se borra su archivo.
- **Parada al ganar:** en cuanto una generación tiene un ganador (la misma condición que el aviso de victoria), `poblacion_detener` detiene el entrenamiento. No se crea otra generación, el campeón ya está guardado, el juego vuelve a x1 y a dibujar, y en pantalla dice cómo seguir: `Esc` y `M` para el menú, `Esc` y `R` para empezar de nuevo. El benchmark no usa esta parada: ya cambia de nivel solo cuando alguien gana.

**Menú:**
- `B`: alterna entre JUGAR (el nivel se juega a mano) y BOT (entrenar).
- `C`: elige la población inicial (pesos nuevos o el campeón de un nivel).
- `X`: corre el benchmark (sección 8).

**Entrenamiento incremental** (lo pide el PDF): entrenar Entrenar 1 → cargar su campeón con `C` y entrenar Entrenar 2 → cargar ese campeón y entrenar Entrenar 3. Cada nivel parte de lo aprendido en el anterior.

---

## 6. Los niveles

El PDF pide dos grupos distintos:

| Se entrena en | Se valida en |
|---|---|
| `rm_base_1` — Entrenar 1 (fácil) | `rm_facil_1`, `rm_facil_2` |
| `rm_base_2` — Entrenar 2 (medio) | `rm_medio_1`, `rm_medio_2` |
| `rm_base_3` — Entrenar 3 (medio-alto) | `rm_medioalto_1`, `rm_medioalto_2` |
| — | `rm_nivel_3` — Avanzado |

- **Entrenamiento:** donde corre el algoritmo genético.
- **Validación:** el bot ya entrenado juega **sin evolucionar**, en niveles que nunca vio. Sirve para saber si **aprendió** o solo **memorizó** el nivel de entrenamiento (sobreajuste).
- Cada nivel de validación usa las **mismas mecánicas** que su nivel de entrenamiento, pero en **otra disposición**.

| Tipo | Mecánicas |
|---|---|
| Fácil | Púas sueltas y dobles, escalones y pilares |
| Medio | Lo anterior más trampolines y murciélagos bajos |
| Medio-alto | Lo anterior más orbes y una sección de nave |
| Avanzado | Todo, más largo y difícil (el nivel 3 original, de 56 000 px) |

Los niveles nuevos se generaron con un script de Python (carpeta `herramientas_niveles`, fuera del repositorio) con las mismas medidas que usó el equipo, y se comprobó en una simulación que todos se pueden pasar.

---

## 7. Tasa de selección

**Dónde:** parámetro `tasa_seleccion` en el *Create* de `obj_poblacion`; función `preparar_padres` en `scr_seleccion`.

Decide **qué parte de la generación puede ser padre**:
- `1` = todos pueden ser padres (como antes).
- `0.5` = solo la mejor mitad.
- `0.2` = solo el mejor 20 %.

Una vez por generación, `preparar_padres` ordena a los bots de mejor a peor y se queda con los primeros. Después el torneo o la ruleta eligen padres **solo entre esos**.

**Para qué:** una tasa baja presiona más hacia lo que ya funciona (converge rápido, pero se pierde variedad). Una tasa alta mantiene más variedad. Es la variable iv del benchmark del PDF.

---

## 8. El benchmark

### 8.1 Qué pide el PDF

Comparar 4 **métricas** cambiando 8 **variables**:

| Métricas | Variables |
|---|---|
| Tiempo de convergencia | Número de pobladores |
| Generaciones de convergencia | Probabilidad de mutación |
| % de completitud en validación | Pesos iniciales |
| Tasa de éxito en validación | Tasa de selección |
| | Técnica de mutación |
| | Técnica de selección |
| | Técnica de cruce |
| | Umbral |

### 8.2 Cómo lo hace el juego

**Dónde:** `scripts/scr_benchmark`. Se lanza con la tecla `X` del menú.

Arriba del script hay 4 funciones que se editan:
- `bench_ajustes`: repeticiones por experimento (3) y tope de generaciones (100).
- `bench_base`: la configuración base (los mismos valores que `obj_poblacion`).
- `bench_experimentos`: la lista de experimentos. Cada uno cambia **una sola variable** respecto a la base. Así, si cambia el resultado, se sabe por qué.
- `bench_etapas`: el orden de los niveles.

Cada **corrida** hace el ciclo completo del PDF:

```
Entrenar 1 (desde cero)       → validar en Fácil 1 y Fácil 2
Entrenar 2 (desde el campeón) → validar en Medio 1 y Medio 2
Entrenar 3 (desde el campeón) → validar en Medio-alto 1, Medio-alto 2 y Avanzado
```

- **Converge** cuando un bot llega a la meta. Si nadie llega en 100 generaciones, se anota como "no convergió" y se sigue con el mejor que haya.
- **Validar** es una sola partida de la población final, sin evolucionar.
- Todo corre al máximo, sin dibujar y sin sonido. Al terminar vuelve al menú.

**Semilla:** los números "al azar" de un computador salen de una fórmula que parte de una **semilla**. Con la misma semilla salen siempre los mismos números. El benchmark fija la semilla con `random_set_seed` según la repetición y el nivel, así que **todos los experimentos juegan con las mismas semillas**. Eso hace la comparación justa y repetible.

### 8.3 Los datos

En `%LOCALAPPDATA%\Genetic_Dash_Game\` quedan dos archivos por benchmark:

**`bench_<fecha>_generaciones.csv`** — una fila por generación de entrenamiento:
`experimento, repeticion, semilla, nivel, generacion, mejor, promedio, peor, ganadores, poblacion, tiempo_s, pasos`

**`bench_<fecha>_resultados.csv`** — una fila por nivel jugado:
- `etapa`: entrenar o validar. `categoria`: facil, medio, medioalto o avanzado.
- `convergio` y `generaciones`: solo en entrenamiento.
- `tiempo_s` y `pasos`: cuánto duró ese nivel (en segundos reales y en pasos de simulación).
- `campeon_avance` (0 a 1) y `campeon_gana` (0 o 1): cómo le fue al campeón.
- `poblacion_ganan` y `poblacion`: cuántos de la población llegaron a la meta.
- Al final, todos los parámetros usados.

### 8.4 Las tablas (Python)

**Dónde:** `benchmark/analizar.py`. Necesita `pandas` y `matplotlib`.

```
python benchmark/analizar.py
```

Toma el benchmark más reciente y deja en `benchmark/resultados/<fecha>/`:
- Una tabla por tipo de nivel, como el primer ejemplo del PDF (filas = experimentos, columnas = métricas).
- La tabla de tasa de éxito por tipo de nivel, como el segundo ejemplo del PDF.
- `curvas_convergencia.png`: el mejor fitness por generación, promedio de las corridas.
- `exito_validacion.png`: barras de tasa de éxito.

Definiciones que usa:
- **Tiempo y generaciones de convergencia:** media de las corridas que convergieron.
- **Completitud:** cuánto del nivel recorrió el campeón (100 % = llegó a la meta).
- **Tasa de éxito:** % de validaciones en las que el campeón llegó a la meta.
- **Población que gana:** % de la población final que llegó a la meta.

---

## 9. Lo que ya se descubrió (simulación)

Antes de tener el benchmark se reprodujo el agente en Python para probar ideas rápido. Estos resultados son de esa simulación; **hay que confirmarlos en el juego**.

1. **El entrenamiento en cadena funciona.** Con 20 semillas, cada nivel de entrenamiento se ganó en casi todas (19 o 20 de 20). Cargar el campeón anterior ayuda: varias veces el nivel siguiente se gana en la generación 1.
2. **Hay sobreajuste.** En validación, el campeón gana entre 7 y 20 de 20 según el nivel, y 0 de 20 en el avanzado. Los bots **memorizan distancias**: mueren donde la separación entre obstáculos es distinta a la del entrenamiento.
3. **Pesos iniciales:**
   - Aleatorios: los que aprenden más rápido.
   - Nulos: aprenden incluso con mutación baja.
   - Iguales: todos los bots nacen idénticos y saltando siempre. Solo aprenden si el paso de mutación es grande (±1,5). Con ±0,5 o menos no aprendieron en 200 generaciones.
4. **Mutación:** lo habitual es mutar entre el 1 % y el 10 % de los números con un paso de 0,1 a 0,5. El proyecto usa 50 % y ±1,5, que es muy alto. Aun así, cambiar la mutación casi no cambió los resultados de validación.
5. **"Choques invisibles"** en la escalera del nivel 1: la caja de choque del gato (64×64) es más grande que su dibujo. No hay piezas invisibles que maten.

---

## 10. Glosario

| Término | Significado |
|---|---|
| **Agente** | El que actúa en el juego: aquí, cada bot con su cerebro |
| **Sensor** | Un número que describe lo que el agente percibe |
| **Actuador** | La acción que puede hacer: pulsar |
| **Peso** | Número de la red que dice cuánto influye una entrada |
| **Sesgo** | Número que se suma en cada neurona |
| **Función de activación** | Fórmula que aplasta el resultado de una neurona (tanh, sigmoide) |
| **Umbral** | Valor a partir del cual la salida se convierte en "saltar" |
| **Fitness** | Nota de un bot: qué tan lejos llegó (0 a 1) |
| **Generación** | Un grupo de bots que juega a la vez |
| **Elitismo** | Pasar al mejor sin cambios a la siguiente generación |
| **Selección** | Elegir qué bots son padres (torneo, ruleta) |
| **Tasa de selección** | Qué parte de la generación puede ser padre |
| **Cruce** | Mezclar los pesos de dos padres |
| **Mutación** | Cambiar algunos pesos al azar |
| **Convergencia** | Cuando el algoritmo encuentra una solución (aquí: un bot llega a la meta) |
| **Entrenamiento incremental** | Empezar cada nivel con el campeón del anterior |
| **Validación** | Probar al bot en niveles que no vio, sin evolucionar |
| **Sobreajuste** | Cuando el bot aprende de memoria el nivel de entrenamiento y falla en otros |
| **Generalizar** | Lo contrario: lo aprendido sirve en niveles nuevos |
| **Semilla** | Número del que salen los valores "al azar"; la misma semilla repite los mismos valores |
| **Benchmark** | Comparación sistemática de configuraciones con métricas |

---

## 11. Mapa de archivos

| Archivo | Qué hace | De quién |
|---|---|---|
| `scripts/scr_sensores` | Los 9 sensores | Oscar |
| `scripts/scr_cerebro` | La red neuronal, crear y copiar cerebros | Oscar |
| `scripts/scr_poblacion` | Fitness y nueva generación | Oscar (2 líneas cambiadas por la tasa de selección) |
| `scripts/scr_seleccion` | Torneo y ruleta | Oscar, más `preparar_padres` (tasa de selección) |
| `scripts/scr_cruce` | Cruce uniforme | Oscar |
| `scripts/scr_mutacion` | Mutación por suma y por reemplazo | Oscar |
| `scripts/scr_guardado` | Guardar y cargar campeones, aviso de victoria | Nuevo |
| `scripts/scr_benchmark` | Cola de experimentos y CSV | Nuevo |
| `objects/obj_jugador` | Física, input del humano o del bot | Oscar |
| `objects/obj_poblacion` — *Create* | Parámetros, crear bots, ajustes de velocidad y zona | Oscar + nuevo |
| `objects/obj_poblacion` — *Step* | Cuando mueren todos: fitness, guardar, benchmark, nueva generación | Oscar + 3 líneas |
| `objects/obj_poblacion` — *Begin Step* | Pasos extra por cuadro, zona activa, título de la ventana | Nuevo |
| `objects/obj_poblacion` — *Draw GUI* | Texto en pantalla | Oscar + nuevo |
| `objects/obj_menu` | Niveles, teclas B, C y X | Equipo + nuevo |
| `benchmark/analizar.py` | Tablas y gráficas del benchmark | Nuevo (Python) |
| `PLAN_IA.md` | Estado del proyecto frente al PDF y lo que falta | Nuevo |

---

## 12. Preguntas de repaso

1. ¿Por qué los sensores de distancia se dividen entre 400?
2. Si un cerebro tiene 45 números, ¿qué es exactamente lo que "evoluciona"?
3. ¿Qué diferencia hay entre `input` e `input_pressed`, y por qué el orbe necesita el segundo?
4. Con 50 bots, ¿cuántos son el campeón, cuántos sus copias mutadas y cuántos hijos de un cruce?
5. ¿Qué pasaría si se quitara el elitismo?
6. ¿Por qué con pesos iniciales **iguales** y mutación pequeña el algoritmo no aprende?
7. ¿Por qué "varios pasos por cuadro" no cambia lo que aprenden los bots?
8. ¿Por qué apagar las piezas lejanas no cambia el resultado?
9. ¿Qué diferencia hay entre un nivel de entrenamiento y uno de validación?
10. Si un bot gana su nivel de entrenamiento pero falla la validación, ¿qué problema tiene?
11. ¿Por qué en el benchmark cada experimento cambia **una sola** variable?
12. ¿Para qué sirve fijar la semilla?
13. ¿Qué mide la tasa de selección y qué efecto esperas si la bajas a 0,2?

<details>
<summary>Respuestas cortas</summary>

1. Para normalizar: todos los sensores quedan entre 0 y 1 y la red puede compararlos.
2. Esos 45 números: los pesos y sesgos de la red. El código de la red no cambia.
3. `input` es "está pulsando"; `input_pressed` es "acaba de empezar a pulsar". El orbe se activa con una pulsación nueva en el aire, no con mantener pulsado.
4. 1 campeón, 15 copias mutadas (30 %) y 34 hijos de cruce.
5. El mejor cerebro podría perderse por una mutación mala y el fitness podría bajar de una generación a otra.
6. Todos nacen idénticos; con cambios pequeños siguen comportándose igual (saltando siempre) y la selección no tiene diferencias que aprovechar.
7. Cada bot vive los mismos pasos con la misma física; solo se dibuja menos.
8. Los bots van juntos y nunca alcanzan una pieza apagada: la zona se recalcula antes de que lleguen.
9. En el de entrenamiento corre el algoritmo genético; en el de validación el bot juega sin evolucionar, en un nivel que no vio.
10. Sobreajuste: memorizó el nivel de entrenamiento en vez de aprender a reaccionar.
11. Para saber qué causó el cambio en los resultados.
12. Para que los experimentos se comparen en igualdad de condiciones y se puedan repetir.
13. Qué parte de la generación puede ser padre. Con 0,2 debería converger más rápido pero con menos variedad, y quizá generalizar peor.

</details>
