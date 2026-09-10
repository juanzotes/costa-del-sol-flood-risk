# Costa del Sol Flood Risk

🗺️ **[Live demo](https://juanzotes.github.io/costa-del-sol-flood-risk/)**

An interactive map of flood exposure for 62 municipalities along Spain's Costa del Sol and the inland Guadalhorce valley (Cádiz and Málaga provinces), covering roughly 150 km of coastline from Tarifa to Nerja. It cross-references Spain's official flood extent layers (SNCZI, 4 return periods) with cadastral building data and Copernicus land cover to separate two distinct exposure channels: built-up value at risk in urban areas, and agricultural area at risk by crop type. The point is that a standard flood map usually stops at "this area floods" — here the same flood zone is split by land use, because a euro of building value and a hectare of avocado orchard are exposed to completely different kinds of loss, and, as the results below show, can even sit on opposite sides of the same river within the same town.

![Screenshot showing the headline finding](images/headline.png)
<!-- [ASK Juan: sigue pendiente — súbeme un screenshot (idealmente el popup de
     San Roque, ver "Findings") y lo dejo en images/headline.png, o lo subes tú
     directamente al repo en esa ruta. -->

---

## The question

Which flood zones along the Costa del Sol concentrate the most exposure — in built-up value in urban areas and in vulnerable agricultural land — and how does that risk vary by land use and by elevation relative to the nearest watercourse?

---

## The data

- **Cadastral buildings.** 1,714,423 features. Source: [Dirección General del Catastro — INSPIRE Buildings ATOM feed](https://catastro.hacienda.gob.es/INSPIRE/buildings/ES.SDGC.BU.atom.xml). License: Catastro download license — raw parcel-level data is not redistributed; only municipality- and 100m-grid-level aggregates are published here.
- **Building construction year.** 483,939 construction units with a valid year, across 148 municipal files. Source: Catastro bulk alphanumeric download (CAT format). Same license terms as above.
- **Official flood extent zones (SNCZI).** 4 return periods (T10 / T50 / T100 / T500). Source: [SNCZI, Ministry for Ecological Transition (MITECO)](https://gis.miteco.gob.es/web/snczi). Public data.
- **Land cover & crop type.** Copernicus CLC+ Backbone (10m, 2023) and the Copernicus Crop Types layer. Source: Copernicus Land Monitoring Service (WEkEO / CDSE). Free-tier account.
- **Imperviousness.** Copernicus HRL Imperviousness Density, 10m/100m, 2024.
- **Elevation.** IGN MDT02, 2m digital terrain model. Source: [IGN/CNIG Centro de Descargas](https://centrodedescargas.cnig.es/). Kept as a VRT rather than a materialized mosaic — a 2m raster across ~150 km of coastline would run into the tens of GB — and sampled directly at building/grid-cell points.
- **Historic flood events.** [CNIH — Catálogo Nacional de Inundaciones Históricas](https://sig.mapama.gob.es/snczi/), national government database.
- **Average housing value.** €/m² for municipalities with more than 25,000 inhabitants. Source: Ministry of Housing/Transport, quarterly housing value statistics. Covers 12 of the 62 municipalities — several inland Guadalhorce towns (Álora, Pizarra, Coín, Ojén) fall below the population threshold and have no figure.

All data in **EPSG:25830** (ETRS89 / UTM zone 30N) for analysis; web layers exported to **EPSG:4326** for the map. Known gaps: housing-value coverage stops at 12/62 municipalities (handled as its own neutral legend class, not folded into "zero risk"); SNCZI's digitized watercourse layer captures an estimated 26-36% of major channels, so a few distance-to-channel outputs likely reflect missing source geometry rather than genuine distance from water (see Findings).

---

## Methodology

The study area is defined by three *comarcas* (Campo de Gibraltar, the Guadalhorce valley, and Vélez-Málaga), not a fixed radius or an arbitrary municipality list — flood risk here is a drainage-basin problem, not an administrative one. Ojén has no coastline but drains directly into the Marbella flood plain, so it's included; a headwater sliver of the Barbate basin falls inside Tarifa's boundary but is excluded, because that basin's floodplain and mouth are on the Atlantic side, outside this project's actual hydrological story.

The analysis first delineates the official flood zone for each return period (SNCZI), then splits everything inside it by land use. Copernicus land cover separates built-up area from agricultural land, so exposure is measured in whatever unit actually matters for that land use: euros of built value for urban land, hectares by crop type for agricultural land. The two are deliberately never merged into a single 0–100 risk score — euros and hectares aren't the same unit, and forcing them together with an arbitrary weight would throw away exactly the distinction this project is trying to show.

### Why only 10 of the 62 municipalities get building-level detail

The choropleth covers all 62 municipalities, but the zoomed-in grid layer (individual buildings and crop pixels, with elevation relative to the nearest watercourse) only exists for **10**: Fuengirola, Málaga, Marbella, Rincón de la Victoria, Vélez-Málaga, Torremolinos, San Roque, Cártama, Nerja and Mijas. Running that grid for all 62 (1.7M buildings, 220k+ crop pixels) would be far more expensive to compute and tile, and would dilute the actual point — a hiring narrative about knowing *where* to zoom in is worth more than uniform coverage. The map marks these 10 directly (dashed orange outline, toggleable) so it's obvious where the fine-grained data exists before you go looking for it, instead of only turning up empty on click.

The selection isn't arbitrary — six independent rankings (flooded area by return period, €/m² and historic CNIH damage, land use inside the flood zone, crop-type vulnerability, imperviousness) were computed across all 62 municipalities first, plus a qualitative "is this municipality coastal" flag. A municipality made the grid if it scored on **multiple** of those criteria, was a deliberate outlier worth showing on its own, or had a hydrological reason to be shown alongside a neighboring grid municipality:

- **Fuengirola, Málaga, Marbella, Rincón de la Victoria, Torremolinos, Vélez-Málaga** — the quantitative core, scoring on 3–4 of the 6 criteria each; between them they cover the western, central, and eastern thirds of the study area.
- **San Roque** — the only Campo de Gibraltar representative, in on real data (top-5 absolute flooded area), not just for geographic symmetry.
- **Cártama** — scores on only 2 criteria but is a deliberate contrast: a large flooded area that's rural/agricultural rather than urban-coastal, so the grid isn't showing only one kind of exposure.
- **Nerja** — scores on only 2 criteria (coastal + top-5 historic CNIH damage), included on documented past damage rather than modeled area.
- **Mijas** — scores on the same 2 criteria as Nerja (coastal + top-5 historic CNIH damage), and independently ranks in the top 5 municipalities by annualized building EAD (see Findings). Added after the map was already live, for a reason the ranking alone doesn't capture: it shares a river with Fuengirola, already in the grid — Mijas sits upstream, Fuengirola downstream — so the same flood event can be traced across both instead of stopping at an administrative boundary.
- **Tarifa was deliberately left out**, despite anchoring the western edge of the study area: "coastal" was its only qualifying signal, and 20 of the 22 shortlist candidates share it — it carries no discriminating information. Adding it back just for geographic symmetry would have been the same arbitrary pick this selection process was built to avoid; San Roque already covers that corner of the map with an actual data-backed reason.

Tarifa still gets the full municipality-level choropleth — it only misses the building/crop-level zoom.

The high-level shape:

1. **Extract.** Municipality-level ATOM feeds for cadastral buildings, a national shapefile-by-return-period for SNCZI, and Copernicus rasters via the WEkEO/CDSE APIs — standardized to EPSG:25830 and clipped to the study extent in `1_data_processing.ipynb`.
2. **Transform.** Spatial joins and raster masking in `2_indicators.ipynb`: building/crop exposure inside each flood zone, an Expected Annual Damage (EAD) metric integrating loss against return-period probability by the trapezoid rule, and elevation-above-channel sampling via a vectorized nearest-neighbor join for the ten detail municipalities.
3. **Visualize.** `3_web_export.ipynb` re-projects results to EPSG:4326 GeoJSON; `convert.sh` tiles each layer separately with tippecanoe (each layer needs its own zoom range, which tippecanoe can't set within one invocation) and combines them with tile-join into a single PMTiles file; `index.html` renders it with MapLibre GL JS.

Two choices are easy to miss. First, an Expected Annual Damage metric sits on top of the standard T100 (100-year) reference, because a T10 event (10%/year probability) shouldn't be weighted the same as a T500 event (0.2%/year) just because T500 covers more area — integrating the loss-vs-probability curve actually reorders the ranking (San Roque moves ahead of everyone else in annualized flooded building area, because much of its exposure already floods at T10, not only in extreme scenarios). Second, elevation relative to the channel is computed with a vectorized `shapely.STRtree` nearest-neighbor join instead of GeoPandas' `sjoin_nearest`, after the latter caused a 10+ minute run and a kernel crash on ~230k agricultural grid points — `sjoin_nearest` keeps every exact-distance tie before deduplicating, which multiplied the intermediate table on duplicate channel segments; STRtree returns exactly one nearest match per point, vectorized, with no ties to explode.

---

## Findings

In San Roque, the same 100-year flood zone produces opposite exposure profiles depending on what's built on it: buildings sit 2.7 m above the nearest channel on average, with only 4.8% of them below channel level, while agricultural land in the same municipality sits mostly below it — 61% of flooded crop-grid cells there have a negative relative elevation.

- Annualizing risk reorders the standard T100 ranking: San Roque leads in annualized flooded *building area* (frequent, low-level flooding rather than one big event), but Marbella overtakes it in annualized *€ value*, because its housing value per m² is nearly double San Roque's.
- Fruit crops — the avocado and mango orchards typical of the Guadalhorce valley — account for 1,136.8 ha/year of annualized agricultural exposure, more than 10x the next category (Fresh Vegetables, 108 ha/year).
- There's a clear east–west split in *what kind* of crop is at risk, not just how much land is: Fruits dominate flood exposure in almost every Guadalhorce-valley municipality, while Campo de Gibraltar municipalities (Los Barrios, Tarifa, San Roque, Algeciras) are dominated by wheat and other extensive cereals instead.
- Cártama and Coín show two different flood "personalities" despite comparable T100 totals: Cártama's exposure is already largely present at T10 (648 ha vs. 919 ha at T500 — a chronic profile), while Coín's exposure jumps sharply between return periods (12.3 ha at T10 to 81.6 ha at T50 — a sudden-flood profile).
- Data-quality caveat that shaped the map itself: SNCZI's digitized watercourse layer likely captures only ~26–36% of major channels, so Vélez-Málaga's ~1,015 m average distance-to-channel — far above every other municipality in the detail grid — probably reflects a missing digitized channel in that area rather than buildings genuinely a kilometer from any river. It's flagged rather than corrected, since no better public layer exists.

**EAD (Expected Annual Damage)** is the annualized risk metric used throughout this project: it weights each of the 4 return periods (T10–T500) by its probability of occurring in a given year, instead of only looking at the T100 (100-year) reference on its own — see Methodology. The top 5 municipalities by annualized urban exposure:

| Rank | Municipality | EAD, built area (m²/year) | EAD, built value (€/year) |
|---|---|---|---|
| 1 | San Roque | 1,787,039 | €4.57B |
| 2 | Marbella | 1,203,041 | €5.21B |
| 3 | Málaga | 697,960 | €2.26B |
| 4 | Mijas | 373,080 | €1.21B |
| 5 | Fuengirola | 339,065 | €1.24B |

*Ranked by EAD built area — the metric with full 62/62 coverage. Note the crossover with Marbella already visible here: it ranks below San Roque in annualized flooded area but above it in annualized € value, because its housing value per m² is nearly double San Roque's (the € figure only has coverage for the 12 municipalities with a housing-value data point, see Data).*

---

## Tech stack

- **Data.** GeoPandas + Shapely (spatial joins, STRtree nearest-neighbor queries) and Rasterio/GDAL (raster masking, VRT mosaicking for the 2m elevation model), pulling directly from official Spanish/EU sources (Catastro ATOM feeds, SNCZI shapefiles, Copernicus WEkEO/CDSE) instead of a pre-packaged benchmark dataset.
- **Compute.** Pandas for the trapezoid-rule Expected Annual Damage integration; native PostGIS via `apt` (no Docker daemon in the build environment) available for anything that needed a spatial database rather than in-memory joins.
- **Tiling.** tippecanoe + tile-join — each of the 6 map layers tiled separately, since tippecanoe can't set a different zoom range per layer in one invocation, then combined into a single PMTiles file.
- **Visualization.** MapLibre GL JS over Leaflet — native vector-tile rendering and paint-property styling meant the choropleth, the return-period selector, and the zoom-triggered detail grid could all run off one static file with zero server-side logic.
- **Hosting.** GitHub Pages — deploy-from-branch, no build step, serves PMTiles' HTTP range requests correctly out of the box.

Total monthly cost: $0. Total servers running: 0.

Every piece of this stack was picked to avoid running a server. PMTiles moves the job a tile server would normally do — slicing vector data by zoom and tile — into a single static file read via HTTP range requests, so plain static hosting (GitHub Pages) is enough; there's nothing to keep running, patch, or pay for after deploy. The trade-off is a slower iteration loop on the tiling step itself, since each layer's zoom range has to be decided at tiling time rather than tuned live in the browser — which is why layer selection and zoom ranges were worked out deliberately before the `convert.sh` run (see Methodology), instead of iterated on after the fact.

---

## How to reproduce

Requires a GeoPandas/Rasterio/GDAL Python environment (conda recommended), `tippecanoe` (Linux/WSL — not installable via pip), and Node.js for local static serving.

```bash
git clone https://github.com/juanzotes/costa-del-sol-flood-risk.git
cd costa-del-sol-flood-risk

# 1. Data + indicators — run the notebooks in order
jupyter notebook 1_data_processing.ipynb   # download + standardize sources -> data/processed/
jupyter notebook 2_indicators.ipynb        # spatial joins, EAD, elevation-above-channel -> CSVs
jupyter notebook 3_web_export.ipynb        # re-project results -> data/web/*.geojson

# 2. Tile (needs tippecanoe: apt install tippecanoe, or WSL on Windows)
./convert.sh                                # -> data/tiles/costa_del_sol_flood_risk.pmtiles

# 3. View locally
npx http-server -p 8000 --cors
```

`python -m http.server` will not work for step 3 — it doesn't support the HTTP range requests PMTiles needs, and the map will load its UI but show no data, with no visible error.

The raw Catastro building/parcel data that step 1 downloads (`data/raw/`, `data/processed/`) is not included in this repository and cannot be redistributed under the Catastro download license — see License, below.

---

## What I learned

The naive approach to classifying municipalities by risk (population quantiles) quietly broke on real data: only 12 of 62 municipalities had housing-value figures, so a 20th–80th percentile split collapsed to zero across the board. I fixed it by computing quantiles only over municipalities with actual exposure, and giving "no data" its own neutral legend class instead of letting it render identically to "low risk."

I also underestimated how easily a naive `gpd.sjoin_nearest` can blow up: on ~230k agricultural grid points it kept every exact-distance tie before deduplicating, which turned into a 10-minute run and a kernel crash. Rewriting it as a vectorized `shapely.STRtree` nearest-neighbor query fixed the crash — and after a full rerun, produced numbers identical to what came before, which was its own lesson: a `.values`-based alignment bug I'd theorized about (positional copy instead of index-aligned copy after a reordering join) never actually manifested in this dataset. The rewrite was still worth keeping, just for the crash fix and the robustness, not because the original numbers were wrong.

---

## What I'd do differently

If I started over, I'd lock in the return-period data model — one property per period on each feature vs. duplicated map layers per period — before writing `2_indicators.ipynb`'s output columns, instead of designing the indicator tables first and retrofitting them to the map's needs afterward. I'd also decide upfront whether the IGN elevation model needed to be a full mosaic or just a VRT sampled at points, rather than finding out partway through that a 2m raster across 150 km of coastline wasn't feasible to materialize.

---

## Roadmap

- Adaptive elevation resolution (2m near the detail grid, coarser elsewhere) if the IGN terrain model earns a place in the rendered map beyond point sampling
- Citable access date for the Catastro sources in the map's attribution control (required by the download license, not yet added)
- Several sources gathered during data collection didn't make it into the final map, on purpose — they're narrative/contextual, not exposure data, and the map's focus is the EAD-driven urban/agricultural split. If that scope ever widens: Junta de Andalucía's historical flood hazard/risk maps (context for why these three comarcas were picked in the first place), the wetlands layer (`hi_zhumeda_s`, e.g. the Guadalhorce estuary as a natural buffer), and a handful of discarded hydrography layers (coastal structures, fords) that were identified and sourced but never clipped or tiled

---

## Author

**Juan Zotes Orcajo.** GIS Research Analyst, working on geospatial risk analysis and climate/insurance-focused portfolio projects.

[LinkedIn](https://www.linkedin.com/in/juan-zotes-orcajo-88a0a51aa/) · [GitHub](https://github.com/juanzotes) · juanzotes@gmail.com

---

## License

MIT. See `LICENSE` for details.

Data attribution: Dirección General del Catastro, SNCZI (Ministry for Ecological Transition), Copernicus Land Monitoring Service, Instituto Geográfico Nacional (IGN). Cadastral data is used strictly in aggregated form, per the Catastro download license (clauses 6 and 8); raw parcel- or building-level data is not included in this repository.
