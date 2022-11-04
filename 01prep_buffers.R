

# all in EPSG 31976 and export as gpkg
library(tidyverse)
library(sf)
library(mapview)

# IBGE Poligono 
maza <- read_sf("vector/munis_maza_santana.shp") %>% 
  filter(CD_MUN=="1600402")
# IBGE linha 
maza_linha <- st_cast(maza, "LINESTRING")
# IBGE Ponto 
maza_ponto <- read_sf("vector/cidade_ap.shp") %>% 
  filter(geocodigo=="1600402")
# IBGE densamente edificada
maza_densamente_edificada <- read_sf("vector/lml_area_densamete_edificada_ap.shp") %>% 
  st_transform(31976) %>% filter(id==2634)
maza_edificada_linha <- st_cast(maza_densamente_edificada, "LINESTRING")
mapview::mapview(maza_linha) + 
  mapview::mapview(maza_densamente_edificada) +
  mapview::mapview(maza_edificada_linha, color="black") +
  mapview::mapview(maza_ponto) 

  
# Buffers
b250m <- st_buffer(maza_ponto, dist = 250) %>% 
  st_intersection(maza) %>% 
  mutate(dist_km = 0.25)
b500m <- st_buffer(maza_ponto, dist = 500) %>% 
  st_intersection(maza) %>% 
  mutate(dist_km = 0.5)
b1km <- st_buffer(maza_ponto, dist = 1000) %>% 
  st_intersection(maza) %>% 
  mutate(dist_km = 1)
b2km <- st_buffer(maza_ponto, dist = 2000) %>% 
  st_intersection(maza) %>% 
  mutate(dist_km = 2)
b4km <- st_buffer(maza_ponto, dist = 4000) %>% 
  st_intersection(maza) %>% 
  mutate(dist_km = 4)
b8km <- st_buffer(maza_ponto, dist = 8000) %>% 
  st_intersection(maza) %>% 
  mutate(dist_km = 8)
b16km <- st_buffer(maza_ponto, dist = 16000) %>% 
  st_intersection(maza) %>% 
  mutate(dist_km = 16)
b32km <- st_buffer(maza_ponto, dist = 32000) %>% 
  st_intersection(maza) %>% 
  mutate(dist_km = 32)
bind_rows(b250m, b500m, b1km, b2km, 
          b4km, b8km, b16km, b32km) -> maza_buffers 
maza_buffers$buff_area_km2 <- round(as.numeric(units::set_units(st_area(maza_buffers),km^2)), 3)
mapview::mapview(maza_buffers, zcol="dist_km")


# Export as gpkg
outfile <- "C:/Users/user/Documents/CA/mazagao/vector/mazagao.GPKG"
st_write(maza_buffers, dsn = outfile, 
         layer = "maza_buffers", delete_layer = TRUE, append = TRUE)
st_write(maza, dsn = outfile, 
         layer = "maza_poly", delete_layer = TRUE, append = TRUE)
st_write(maza_linha, dsn = outfile, 
         layer = "maza_linha", delete_layer = TRUE, append = TRUE)
st_write(maza_ponto, dsn = outfile, 
         layer = "maza_ponto", delete_layer = TRUE, append = TRUE)
st_write(maza_densamente_edificada, dsn = outfile, 
         layer = "maza_densamente_edificada", delete_layer = TRUE, append = TRUE)
st_write(maza_edificada_linha, dsn = outfile, 
         layer = "maza_edificada_linha", delete_layer = TRUE, append = TRUE)
st_layers("C:/Users/user/Documents/CA/mazagao/vector/mazagao.GPKG")
