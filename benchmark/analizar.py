"""Tablas y gráficas del benchmark de Genetic Dash.

El juego escribe los datos al correr el benchmark (tecla X del menú) en
%LOCALAPPDATA%\\Genetic_Dash_Game\\bench_<fecha>_resultados.csv y bench_<fecha>_generaciones.csv.
Este script los lee y deja todo en benchmark/resultados/<fecha>/.

Uso:
    python analizar.py                          (usa el benchmark más reciente)
    python analizar.py ruta/bench_X_resultados.csv

Necesita pandas y matplotlib.
"""
import os
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

CATEGORIAS = ["facil", "medio", "medioalto", "avanzado"]


def buscar_archivos():
    if len(sys.argv) > 1:
        res = Path(sys.argv[1])
    else:
        carpeta = Path(os.environ["LOCALAPPDATA"]) / "Genetic_Dash_Game"
        archivos = sorted(carpeta.glob("bench_*_resultados.csv"))
        if not archivos:
            sys.exit(f"No hay ningún benchmark en {carpeta}")
        res = archivos[-1]
    return res, res.with_name(res.name.replace("_resultados", "_generaciones"))


def a_markdown(df):
    """Tabla en Markdown sin depender de otros paquetes."""
    df = df.round(1).astype(object).where(df.notna(), "-")
    filas = ["| " + " | ".join([df.index.name or ""] + [str(c) for c in df.columns]) + " |",
             "|" + "---|" * (len(df.columns) + 1)]
    for idx, fila in df.iterrows():
        filas.append("| " + " | ".join([str(idx)] + [str(v) for v in fila]) + " |")
    return "\n".join(filas)


res_path, gen_path = buscar_archivos()
res = pd.read_csv(res_path)
gen = pd.read_csv(gen_path)
salida = Path(__file__).parent / "resultados" / res_path.stem.replace("_resultados", "")
salida.mkdir(parents=True, exist_ok=True)
orden = list(dict.fromkeys(res["experimento"]))   # experimentos en el orden en que se corrieron

ent = res[res["etapa"] == "entrenar"]
val = res[res["etapa"] == "validar"]
conv = ent[ent["convergio"] == 1]

texto = [f"# Benchmark {salida.name}", "",
         f"Corridas por experimento: {res['repeticion'].max()}. Archivo: `{res_path.name}`.", ""]

# ---------------------------------------------------------------- una tabla por tipo de nivel (como el ejemplo del PDF)
for cat in CATEGORIAS:
    t = pd.DataFrame(index=pd.Index(orden, name="experimento"))
    e = ent[ent["categoria"] == cat]
    if len(e):
        c = conv[conv["categoria"] == cat]
        t["convergió (%)"] = e.groupby("experimento")["convergio"].mean() * 100
        t["tiempo de convergencia (s)"] = c.groupby("experimento")["tiempo_s"].mean()
        t["generaciones de convergencia"] = c.groupby("experimento")["generaciones"].mean()
    v = val[val["categoria"] == cat]
    for nivel in dict.fromkeys(v["nivel"]):
        t[f"completitud {nivel} (%)"] = v[v["nivel"] == nivel].groupby("experimento")["campeon_avance"].mean() * 100
    t["tasa de éxito (%)"] = v.groupby("experimento")["campeon_gana"].mean() * 100
    t["población que gana (%)"] = (v["poblacion_ganan"] / v["poblacion"]).groupby(v["experimento"]).mean() * 100
    t.to_csv(salida / f"tabla_{cat}.csv")
    texto += [f"## Nivel tipo {cat}", "", a_markdown(t), ""]

# ---------------------------------------------------------------- tasa de éxito: experimento contra tipo de nivel
exito = (val.groupby(["experimento", "categoria"])["campeon_gana"].mean() * 100).unstack()
exito = exito.reindex(index=orden, columns=[c for c in CATEGORIAS if c in exito.columns])
exito.index.name = "experimento"
exito.to_csv(salida / "tabla_exito.csv")
texto += ["## Tasa de éxito en validación (%)", "",
          "Porcentaje de partidas de validación en las que el campeón llega a la meta.", "",
          a_markdown(exito), ""]

texto += ["## Definiciones", "",
          "- **Convergió:** algún bot llegó a la meta antes del tope de generaciones.",
          "- **Tiempo y generaciones de convergencia:** media de las corridas que convergieron.",
          "- **Completitud:** cuánto del nivel recorrió el campeón (100 % = llegó a la meta).",
          "- **Tasa de éxito:** porcentaje de validaciones en las que el campeón llegó a la meta.",
          "- **Población que gana:** porcentaje de la población final que llegó a la meta.", ""]
(salida / "tablas.md").write_text("\n".join(texto), encoding="utf-8")

# ---------------------------------------------------------------- gráfica 1: curvas de convergencia
niveles_ent = list(dict.fromkeys(ent["nivel"]))
fig, ejes = plt.subplots(1, len(niveles_ent), figsize=(6 * len(niveles_ent), 4.5), squeeze=False)
for eje, nivel in zip(ejes[0], niveles_ent):
    g = gen[gen["nivel"] == nivel]
    tope = int(g["generacion"].max())
    for exp in orden:
        curvas = []
        for _, corrida in g[g["experimento"] == exp].groupby("repeticion"):
            s = corrida.set_index("generacion")["mejor"]
            # una corrida que ya convergió se queda en su último valor hasta el final
            curvas.append(s.reindex(range(1, tope + 1)).ffill())
        if curvas:
            eje.plot(range(1, tope + 1), pd.concat(curvas, axis=1).mean(axis=1), label=exp)
    eje.set_title(nivel)
    eje.set_xlabel("generación")
    eje.set_ylabel("mejor fitness (media de las corridas)")
    eje.set_ylim(0, 1.05)
ejes[0][-1].legend(fontsize=7, loc="lower right")
fig.tight_layout()
fig.savefig(salida / "curvas_convergencia.png", dpi=120)

# ---------------------------------------------------------------- gráfica 2: tasa de éxito por tipo de nivel
ax = exito.plot.bar(figsize=(max(8, len(orden) * 0.8), 4.5))
ax.set_ylabel("tasa de éxito en validación (%)")
ax.set_ylim(0, 105)
plt.xticks(rotation=45, ha="right")
plt.tight_layout()
plt.savefig(salida / "exito_validacion.png", dpi=120)

print(f"Listo: {salida}")
for f in sorted(salida.iterdir()):
    print("  ", f.name)
