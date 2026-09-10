# Costa del Sol — Riesgo de inundación

Mapa interactivo de riesgo de inundación fluvial para 62 municipios de la Costa del Sol y el valle interior del Guadalhorce (provincias de Cádiz y Málaga), cruzando exposición urbana (valor construido en riesgo) y agrícola (superficie por tipo de cultivo) con las zonas inundables oficiales del SNCZI en 4 periodos de retorno (T10 / T50 / T100 / T500) y el daño anual esperado (EAD).

**Mapa en vivo:** https://juanzotes.github.io/costa-del-sol-flood-risk/

## Pipeline

1. `1_data_processing.ipynb` — descarga y preparación de fuentes (Catastro, SNCZI, Copernicus CLC+, IGN, estadística de valor de vivienda).
2. `2_indicators.ipynb` — indicadores de exposición por municipio y por celda de detalle de 100 m (carril urbano y carril agrícola).
3. `3_web_export.ipynb` — export de las capas ya agregadas a GeoJSON (WGS84) para la web.
4. `convert.sh` — tippecanoe + tile-join: cada capa a su propio rango de zoom, combinadas en un único PMTiles.
5. `index.html` — mapa MapLibre GL JS + PMTiles, un solo fichero estático.

## Stack

Python (GeoPandas, Shapely, DuckDB, Rasterio) · tippecanoe · PMTiles · MapLibre GL JS · GitHub Pages

## Correrlo en local

```bash
npx http-server -p 8000 --cors
```

(`python -m http.server` no sirve — PMTiles necesita soporte de HTTP Range requests, que el servidor de Python no implementa.)

## Fuentes y atribución

- Dirección General del Catastro — edificios y antigüedad de construcción (uso agregado únicamente, ver nota de licencia abajo)
- SNCZI, Ministerio para la Transición Ecológica (MITECO) — zonas inundables oficiales
- Copernicus CLC+ Backbone — cobertura de suelo / tipo de cultivo
- Instituto Geográfico Nacional (IGN) — límites administrativos

## Nota sobre los datos

Los datos catastrales en bruto (parcela o edificio individual) **no se incluyen en este repositorio** — la licencia de descarga de productos catastrales prohíbe su publicación tal cual. Solo se publican los indicadores ya agregados por municipio o por celda de 100 m que alimentan el mapa (vía `data/tiles/*.pmtiles`). El pipeline completo de generación de esos indicadores está en los notebooks de este repo.

_Documentación completa de metodología y hallazgos: en curso._
