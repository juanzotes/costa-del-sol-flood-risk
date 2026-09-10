#!/bin/bash
set -euo pipefail

WEB_DIR="data/web"
OUT_DIR="data/tiles"
mkdir -p "$OUT_DIR"

# Se queda en -z14 a proposito (no subir a 16): retilear estos poligonos
# grandes hasta z16 disparaba el pmtiles combinado de 13 a 23MB (mas tiles
# pequenos = mas fragmentos de la misma geometria/propiedades repetidos por
# tile), por encima del limite de 20MB para sincronizar con tu maquina. En
# vez de eso, en index.html estas capas usan una fuente vectorial separada
# ("cds_bg") con maxzoom:14 sobre el MISMO pmtiles - mas alla de z14, MapLibre
# hace overzoom automatico (reutiliza visualmente el tile de z14 en vez de
# pedir uno nuevo), que es justo lo que Juan pedia (que sigan visibles) sin
# necesidad de generar tiles nuevos ni engordar el archivo.
tippecanoe -o "$OUT_DIR/municipios.pmtiles" -l municipios \
  -Z0 -z14 -f "$WEB_DIR/municipios.geojson"

tippecanoe -o "$OUT_DIR/snczi_zonas.pmtiles" -l snczi_zonas \
  -Z0 -z14 -f "$WEB_DIR/snczi_zonas.geojson"

tippecanoe -o "$OUT_DIR/limites_comarcas.pmtiles" -l limites_comarcas \
  -Z0 -z14 -f "$WEB_DIR/limites_comarcas.geojson"

tippecanoe -o "$OUT_DIR/hidrografia_cauces.pmtiles" -l hidrografia_cauces \
  -Z12 -z14 -f "$WEB_DIR/hidrografia_cauces.geojson"

# Cambiado de -Z13 a -Z12 (medio punto de zoom antes vía minzoom:12.5 en index.html)
tippecanoe -o "$OUT_DIR/edificios_grid_t100.pmtiles" -l edificios_grid_t100 \
  -Z12 -z16 -f "$WEB_DIR/edificios_grid_t100.geojson"

tippecanoe -o "$OUT_DIR/agricola_grid_t100.pmtiles" -l agricola_grid_t100 \
  -Z12 -z16 -f "$WEB_DIR/agricola_grid_t100.geojson"

tile-join -o "$OUT_DIR/costa_del_sol_flood_risk.pmtiles" -f \
  "$OUT_DIR/municipios.pmtiles" \
  "$OUT_DIR/snczi_zonas.pmtiles" \
  "$OUT_DIR/limites_comarcas.pmtiles" \
  "$OUT_DIR/hidrografia_cauces.pmtiles" \
  "$OUT_DIR/edificios_grid_t100.pmtiles" \
  "$OUT_DIR/agricola_grid_t100.pmtiles"

echo "Listo: $OUT_DIR/costa_del_sol_flood_risk.pmtiles"
ls -lh "$OUT_DIR"/*.pmtiles
