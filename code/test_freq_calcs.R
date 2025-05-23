# TAKEAWAYS
# Processing frequency tables with many individual polygons rather than a few multipolygons is much faster (factor of ~5)
# Processing frequency tables is faster with polygons rather than a raster
# Cropping the raster first doesn't seem to make much of a difference
# For a raster with many layers, it is faster to iterate over the layers than to process as a multi-layer raster (~20% difference)


library(terra)
library(sf)
library(dplyr)
library(tictoc)

epa_l4 <- glue::glue(
  "/vsizip/vsicurl/", #magic remote connection
  "https://gaftp.epa.gov/EPADataCommons/ORD/Ecoregions/us/us_eco_l4.zip", #copied link to download location
  "/us_eco_l4_no_st.shp") |> #path inside zip file
  sf::st_read() |>
  dplyr::mutate(US_L4CODE_INT = as.integer(factor(US_L4CODE, levels = unique(US_L4CODE))))



beetle5yrF <- list.files("C:/Users/tyler/OneDrive - UCB-O365/dev/disturbance-stack-patch-analysis/data/nathan_outputs", pattern = "beetle_totals", full.names = TRUE)
crs <- terra::rast(beetle5yrF[1]) |> terra::crs()

sr <- epa_l4 |>
  dplyr::filter(US_L3NAME == "Southern Rockies") |>
  sf::st_transform(crs)

aoi <- sr
aoi2 <- sr |>
  dplyr::group_by(US_L4CODE_INT) |>
  dplyr::summarize(geometry = st_union(geometry))
r <- terra::rast(beetle5yrF[1])
r2 <- terra::rast(beetle5yrF[2:3])
rAll <- terra::rast(beetle5yrF)

rSR <- r |> terra::crop(aoi)

aoiR <- aoi |>
  terra::rasterize(y = rSR, field = "US_L4CODE_INT", fun = "min")

#One layer, many poly
tic()
f <-  r |> terra::freq(bylayer = TRUE, usenames = TRUE, zones = terra::vect(aoi), wide = TRUE)
toc()
#36 seconds

# One layer, multipoly
tic()
f2 <-  r |> terra::freq(bylayer = TRUE, usenames = TRUE, zones = terra::vect(aoi2), wide = TRUE)
toc()
#134 seconds

#Two layer many poly
tic()
f <-  r2 |> terra::freq(bylayer = TRUE, usenames = TRUE, zones = terra::vect(aoi), wide = TRUE)
toc()
#67.19 seconds

#Two layer multi poly
tic()
f2 <-  r2 |> terra::freq(bylayer = TRUE, usenames = TRUE, zones = terra::vect(aoi2), wide = TRUE)
toc()
#339.43 seconds

#18 layer many poly
tic()
fAll <- rAll |> terra::freq(bylayer = TRUE, usenames = TRUE, zones = terra::vect(aoi), wide = TRUE)
toc()
#877.36 sec

# One layer rasterized poly
tic()
f <-  rSR |> terra::freq(bylayer = TRUE, usenames = TRUE, zones = aoiR, wide = TRUE)
toc()
#237 sec - WAY longer!

#One layer, many poly, cropped R
tic()
f <-  rSR |> terra::freq(bylayer = TRUE, usenames = TRUE, zones = terra::vect(aoi), wide = TRUE)
toc()
#33 seconds; 31 sec w/ memfrac 0.8



# All layers, many poly, for each layer
tic()
for(x in beetle5yrF) {
  r <- terra::rast(x)
  f <-  r |> terra::freq(bylayer = TRUE, usenames = TRUE, zones = terra::vect(aoi), wide = TRUE)
}
toc()
#715 sec



r <- terra::rast(beetle5yrF[1])

#One layer, many poly, for each poly
tic()
for(i in 1:nrow(aoi)) {
  x <- r |>
    terra::crop(aoi[i,], mask = TRUE) |>
    freq()
}
toc()
#37 sec ; essentially identical to giving freq zones


#All layers, many poly, for each poly
tic()
for(x in beetle5yrF) {
  r <- terra::rast(x)
  for(i in 1:nrow(aoi)) {
    x <- r |>
      terra::crop(aoi[i,], mask = TRUE) |>
      freq()
  }
}
toc()
#746 sec ; essentially the same as doing freq zones