#!/bin/bash
# Costa del Sol Flood Risk - GeoJSON -> PMTiles (tippecanoe + tile-join)
#
# Corre en el contenedor cloud (root, apt), no en esta maquina - la VM local no
# tiene sudo. Cada capa se tilea por separado con su propio rango de zoom
# (minzoom/maxzoom), luego tile-join las combina en un unico .pmtiles - mismo
# patron que el proyecto de demografia, y necesario porque tippecanoe no deja
# fijar un minzoom distinto por capa dentro de una sola invocacion.
#
# Solo 6 de las 8 capas de data/web/ entran aqui - hidrografia_humedales y
# limites_cuencas se quedaron fuera del mapa interactivo (ver plan doc,
# Fase 3): no responden directamente a la pregunta del proyecto, se usan como
# mucho para una figura estatica en el README.
set -euo pipefail

WEB_DIR="data/web"
OUT_DIR="data/tiles"
mkdir -p "$OUT_DIR"

# --- Capas de fondo: visibles en (casi) todo el rango de zoom ---
tippecanoe -o "$OUT_DIR/municipios.pmtiles" -l municipios \
  -Z0 -z14 -f "$WEB_DIR/municipios.geojson"

tippecanoe -o "$OUT_DIR/snczi_zonas.pmtiles" -l snczi_zonas \
  -Z0 -z14 -f "$WEB_DIR/snczi_zonas.geojson"

tippecanoe -o "$OUT_DIR/limites_comarcas.pmtiles" -l limites_comarcas \
  -Z0 -z14 -f "$WEB_DIR/limites_comarcas.geojson"

# --- Capas de detalle: solo aparecen al hacer zoom sobre los 9 municipios del grid ---
tippecanoe -o "$OUT_DIR/hidrografia_cauces.pmtiles" -l hidrografia_cauces \
  -Z12 -z14 -f "$WEB_DIR/hidrografia_cauces.geojson"

tippecanoe -o "$OUT_DIR/edificios_grid_t100.pmtiles" -l edificios_grid_t100 \
  -Z13 -z16 -f "$WEB_DIR/edificios_grid_t100.geojson"

tippecanoe -o "$OUT_DIR/agricola_grid_t100.pmtiles" -l agricola_grid_t100 \
  -Z13 -z16 -f "$WEB_DIR/agricola_grid_t100.geojson"

# --- Combinar en un unico pmtiles, cada capa conserva su propio rango de zoom ---
tile-join -o "$OUT_DIR/costa_del_sol_flood_risk.pmtiles" -f \
  "$OUT_DIR/municipios.pmtiles" \
  "$OUT_DIR/snczi_zonas.pmtiles" \
  "$OUT_DIR/limites_comarcas.pmtiles" \
  "$OUT_DIR/hidrografia_cauces.pmtiles" \
  "$OUT_DIR/edificios_grid_t100.pmtiles" \
  "$OUT_DIR/agricola_grid_t100.pmtiles"

echo "Listo: $OUT_DIR/costa_del_sol_flood_risk.pmtiles"
ls -lh "$OUT_DIR"/*.pmtiles
