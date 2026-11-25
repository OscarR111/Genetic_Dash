# /// script
# requires-python = ">=3.10"
# dependencies = ["pandas", "matplotlib", "seaborn"]
# ///
"""Gráficas del benchmark de Genetic Dash (apartado 3.3.6 del PDF).

Lee los CSV que escribe el juego al correr el benchmark (tecla X del menú) y dibuja,
para cada variable del PDF, cómo cambian las 4 métricas:
  i.   tiempo de convergencia
  ii.  generaciones de convergencia
  iii. % de completitud en validación
  iv.  tasa de éxito en validación

Uso (con uv, que instala solo pandas, matplotlib y seaborn la primera vez):
    uv run graficas.py                                   (benchmark más reciente)
    uv run graficas.py ruta/bench_X_resultados.csv       (uno concreto)
    uv run graficas.py ruta/bench_X_resultados.csv carpeta_de_salida

Sin carpeta de salida, las imágenes van a benchmark/resultados/<fecha>/graficas/.

No hace falta tocar nada al cambiar los experimentos en scr_benchmark: el script deduce
qué variable cambia cada experimento comparando sus parámetros con los de "base".
"""
import os
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from matplotlib.patches import Patch

# ------------------------------------------------------------------ nombres para mostrar
CATEGORIAS = ["facil", "medio", "medioalto", "avanzado"]
NOMBRE_CAT = {"facil": "Fácil", "medio": "Medio", "medioalto": "Medio-alto", "avanzado": "Avanzado"}

# parámetro del CSV -> (nombre en las gráficas, cómo mostrar cada valor)
PARAMETROS = {
    "tam_poblacion": ("Número de pobladores", None),
    "prob_mutacion": ("Probabilidad de mutación (%)", None),
    "paso_mutacion": ("Paso de mutación", None),
    "tipo_pesos": ("Pesos iniciales", {1: "aleatorios", 2: "iguales", 3: "nulos"}),
    "valor_pesos": ("Valor de los pesos iguales", None),
    "tasa_seleccion": ("Tasa de selección", None),
    "tipo_mutacion": ("Técnica de mutación", {1: "suma", 2: "reemplazo"}),
    "tipo_seleccion": ("Técnica de selección", {1: "torneo", 2: "ruleta"}),
    "k_torneo": ("Tamaño del torneo", None),
    "umbral": ("Umbral de activación", None),
}

sns.set_theme(style="whitegrid", context="notebook")
PALETA = dict(zip(CATEGORIAS, sns.color_palette("deep", 4)))


def texto_valor(param, valor):
    nombres = PARAMETROS[param][1]
    if nombres:
        return nombres.get(int(valor), str(valor))
    return f"{valor:g}"


# ------------------------------------------------------------------ datos
def buscar_archivos():
    if len(sys.argv) > 1:
        res = Path(sys.argv[1])
    else:
        carpeta = Path(os.environ["LOCALAPPDATA"]) / "Genetic_Dash_Game"
        archivos = sorted(carpeta.glob("bench_*_resultados.csv"))
        if not archivos:
            sys.exit(f"No hay ningún benchmark en {carpeta}")
        res = archivos[-1]
    gen = res.with_name(res.name.replace("_resultados", "_generaciones"))
    if len(sys.argv) > 2:
        salida = Path(sys.argv[2])
    else:
        salida = Path(__file__).parent / "resultados" / res.stem.replace("_resultados", "") / "graficas"
    return res, gen, salida


def variables_por_experimento(res):
    """Para cada experimento: qué parámetro cambia respecto a la base y con qué valor."""
    params = res.groupby("experimento")[list(PARAMETROS)].first()
    base = "base" if "base" in params.index else params.index[0]
    info = {}
    for exp, fila in params.iterrows():
        distintos = [p for p in PARAMETROS if fila[p] != params.loc[base, p]]
        info[exp] = distintos
    return params, base, info


res_path, gen_path, salida = buscar_archivos()
res = pd.read_csv(res_path)
gen = pd.read_csv(gen_path)
salida.mkdir(parents=True, exist_ok=True)

params, base, cambios = variables_por_experimento(res)
orden_exp = list(dict.fromkeys(res["experimento"]))

# Etiqueta legible de cada experimento, por ejemplo "Pesos iniciales = nulos"
etiqueta = {}
for exp in orden_exp:
    if exp == base:
        etiqueta[exp] = "Base"
    elif len(cambios[exp]) == 1:
        p = cambios[exp][0]
        etiqueta[exp] = f"{PARAMETROS[p][0]} = {texto_valor(p, params.loc[exp, p])}"
    else:
        etiqueta[exp] = exp

ent = res[res["etapa"] == "entrenar"].copy()
val = res[res["etapa"] == "validar"].copy()
ent["generaciones"] = pd.to_numeric(ent["generaciones"])
ent["convergio"] = pd.to_numeric(ent["convergio"])
val["completitud"] = val["campeon_avance"] * 100
val["exito"] = val["campeon_gana"] * 100
ent_conv = ent[ent["convergio"] == 1]
hechas = []


def guardar(fig, nombre):
    if not fig.get_layout_engine():
        fig.tight_layout()
    fig.savefig(salida / nombre, dpi=130)
    plt.close(fig)
    hechas.append(nombre)


# ------------------------------------------------------------------ 1. una figura por variable: las 4 métricas
# Cada variable se compara con la base (que es uno de sus valores).
variables = []
for exp in orden_exp:
    if len(cambios[exp]) == 1 and cambios[exp][0] not in variables:
        variables.append(cambios[exp][0])

for p in variables:
    exps = [base] + [e for e in orden_exp if cambios[e] == [p]]
    # el valor de la variable en cada experimento, ordenado
    valores = {e: params.loc[e, p] for e in exps}
    exps.sort(key=lambda e: valores[e])
    nombre_x = {e: texto_valor(p, valores[e]) + (" (base)" if e == base else "") for e in exps}
    orden_x = [nombre_x[e] for e in exps]

    e_sub = ent_conv[ent_conv["experimento"].isin(exps)].assign(valor=lambda d: d["experimento"].map(nombre_x))
    v_sub = val[val["experimento"].isin(exps)].assign(valor=lambda d: d["experimento"].map(nombre_x))
    conv_txt = ", ".join(f"{nombre_x[e]}: {ent[ent['experimento'] == e]['convergio'].mean() * 100:.0f} %" for e in exps)

    fig, ejes = plt.subplots(2, 2, figsize=(13, 9))
    fig.suptitle(f"{PARAMETROS[p][0]}", fontsize=15, fontweight="bold")
    cats_ent = [c for c in CATEGORIAS if c in set(e_sub["categoria"])]
    cats_val = [c for c in CATEGORIAS if c in set(v_sub["categoria"])]

    # Cada barra es el promedio de las corridas, con su valor escrito encima
    graficos = [
        (ejes[0][0], e_sub, "tiempo_s", cats_ent, "i. Tiempo de convergencia (s)", "%.1f"),
        (ejes[0][1], e_sub, "generaciones", cats_ent, "ii. Generaciones de convergencia", "%.0f"),
        (ejes[1][0], v_sub, "completitud", cats_val, "iii. Completitud en validación (%)", "%.0f"),
        (ejes[1][1], v_sub, "exito", cats_val, "iv. Tasa de éxito en validación (%)", "%.0f"),
    ]
    for eje, datos, col, cats, titulo, formato in graficos:
        if len(datos):
            sns.barplot(data=datos, x="valor", y=col, hue="categoria", order=orden_x, hue_order=cats,
                        palette=PALETA, errorbar=None, ax=eje, legend=False)
            for barras in eje.containers:
                eje.bar_label(barras, fmt=formato, fontsize=7, padding=1)
        eje.set_title(titulo)
        eje.set_xlabel(PARAMETROS[p][0])
        eje.set_ylabel("")
        eje.set_ylim(0, eje.get_ylim()[1] * 1.08)
        if col in ("completitud", "exito"):
            eje.set_ylim(0, 110)
    # una sola leyenda para las 4 gráficas
    cats_todas = [c for c in CATEGORIAS if c in set(cats_ent) | set(cats_val)]
    fig.legend(handles=[Patch(color=PALETA[c], label=NOMBRE_CAT[c]) for c in cats_todas], title="Tipo de nivel",
               loc="upper center", bbox_to_anchor=(0.5, 0.955), ncol=len(cats_todas), fontsize=9)
    fig.text(0.5, 0.005, f"Cada barra es el promedio de las corridas. i y ii solo cuentan las corridas que convergieron "
             f"({conv_txt}).", ha="center", fontsize=8)
    fig.tight_layout(rect=(0, 0.02, 1, 0.89))
    guardar(fig, f"variable_{p}.png")

# ------------------------------------------------------------------ 2. mapas de calor: experimento contra tipo de nivel
# Una fila por experimento y una columna por tipo de nivel; el número es el promedio de las corridas.
# Verde = mejor. En éxito y completitud, más alto es mejor; en generaciones y tiempo, más bajo es mejor.
def mapa(datos, col, titulo, nombre, fmt, mas_alto_mejor, maximo=None, unidad=""):
    tabla = datos.pivot_table(index="experimento", columns="categoria", values=col, aggfunc="mean")
    tabla = tabla.reindex(index=orden_exp, columns=[c for c in CATEGORIAS if c in tabla.columns])
    tabla.index = [etiqueta[e] for e in tabla.index]
    tabla.columns = [NOMBRE_CAT[c] for c in tabla.columns]
    fig, eje = plt.subplots(figsize=(8, 0.45 * len(tabla) + 1.8))
    sns.heatmap(tabla, annot=True, fmt=fmt, cmap="RdYlGn" if mas_alto_mejor else "RdYlGn_r", vmin=0, vmax=maximo,
                cbar_kws={"label": unidad}, ax=eje)
    eje.set_title(titulo)
    eje.set_xlabel("Tipo de nivel")
    eje.set_ylabel("")
    guardar(fig, nombre)


mapa(val, "exito", "iv. Tasa de éxito en validación (%)", "mapa_exito.png", ".0f", True, 100, "%")
mapa(val, "completitud", "iii. Completitud en validación (%)", "mapa_completitud.png", ".0f", True, 100, "%")
mapa(ent_conv, "generaciones", "ii. Generaciones de convergencia (nivel de entrenamiento)\nen blanco: ninguna corrida convergió",
     "mapa_generaciones.png", ".0f", False, None, "generaciones")
mapa(ent_conv, "tiempo_s", "i. Tiempo de convergencia en segundos (nivel de entrenamiento)\nen blanco: ninguna corrida convergió",
     "mapa_tiempo.png", ".1f", False, None, "segundos")
mapa(ent.assign(conv=ent["convergio"] * 100), "conv", "Corridas que convergieron (%)", "mapa_convergio.png", ".0f", True, 100, "%")

# ------------------------------------------------------------------ 3. curvas de convergencia por variable
niveles_ent = list(dict.fromkeys(ent["nivel"]))
tope = int(gen["generacion"].max())


def curva_media(g):
    """Media del mejor fitness por generación. Una corrida que ya terminó se queda en su último valor."""
    curvas = []
    for _, corrida in g.groupby("repeticion"):
        s = corrida.set_index("generacion")["mejor"]
        curvas.append(s.reindex(range(1, tope + 1)).ffill())
    return pd.concat(curvas, axis=1).mean(axis=1) if curvas else None


for p in variables:
    exps = sorted([base] + [e for e in orden_exp if cambios[e] == [p]], key=lambda e: params.loc[e, p])
    fig, ejes = plt.subplots(1, len(niveles_ent), figsize=(5.5 * len(niveles_ent), 4.2), squeeze=False)
    fig.suptitle(f"Convergencia — {PARAMETROS[p][0]}", fontsize=13, fontweight="bold")
    for eje, nivel in zip(ejes[0], niveles_ent):
        for e in exps:
            c = curva_media(gen[(gen["nivel"] == nivel) & (gen["experimento"] == e)])
            if c is not None:
                eje.plot(c.index, c.values, label=texto_valor(p, params.loc[e, p]) + (" (base)" if e == base else ""))
        eje.set_title(nivel)
        eje.set_xlabel("Generación")
        eje.set_ylabel("Mejor fitness (media)")
        eje.set_ylim(0, 1.05)
    ejes[0][-1].legend(title=PARAMETROS[p][0], fontsize=8)
    guardar(fig, f"convergencia_{p}.png")

# ------------------------------------------------------------------ 4. sobreajuste: entrenamiento contra validación
# Completitud del campeón en su nivel de entrenamiento y en los de validación de la misma dificultad.
comp = pd.concat([
    ent.assign(completitud=ent["campeon_avance"] * 100, donde="Entrenamiento")[["categoria", "completitud", "donde"]],
    val.assign(donde="Validación")[["categoria", "completitud", "donde"]],
])
fig, eje = plt.subplots(figsize=(8, 4.5))
sns.barplot(data=comp, x="categoria", y="completitud", hue="donde", order=[c for c in CATEGORIAS if c in set(comp["categoria"])],
            errorbar=None, ax=eje)
for barras in eje.containers:
    eje.bar_label(barras, fmt="%.0f", fontsize=9, padding=2)
eje.text(0.99, 0.93, "El avanzado no tiene nivel de entrenamiento propio", transform=eje.transAxes, ha="right", fontsize=8)
eje.set_xticks(eje.get_xticks(), [NOMBRE_CAT[t.get_text()] for t in eje.get_xticklabels()])
eje.set_title("¿Sobreajuste? Completitud del campeón: entrenamiento contra validación")
eje.set_xlabel("Tipo de nivel")
eje.set_ylabel("Completitud (%)")
eje.set_ylim(0, 130)
eje.legend(title="", loc="upper left", ncol=2)
guardar(fig, "sobreajuste.png")

# ------------------------------------------------------------------ resumen
print(f"Benchmark: {res_path.name}")
print(f"Base: '{base}'. Variables comparadas: {', '.join(PARAMETROS[p][0] for p in variables)}")
sin_var = [e for e in orden_exp if e != base and len(cambios[e]) != 1]
if sin_var:
    print(f"Ojo: estos experimentos cambian más de una variable (o ninguna) y solo salen en los mapas: {sin_var}")
print(f"Técnica de cruce: el proyecto tiene una sola (cruce uniforme), así que no se compara.")
print(f"\n{len(hechas)} gráficas en {salida}:")
for h in hechas:
    print("  ", h)
