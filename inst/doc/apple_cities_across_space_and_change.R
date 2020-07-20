## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, message=FALSE, warning=FALSE--------------------------------------
library(covid19mobility)
library(sf)
library(rnaturalearth)
library(dplyr)
library(ggplot2)

apple_cities <- refresh_covid19mobility_apple_city()

## ----convert, message=FALSE, warning=FALSE------------------------------------

# Get UN LOCODEs
# from jebyrnes/unlocode
locode_url <- "https://github.com/jebyrnes/unlocodeR/raw/master/data/unlocode.rda"
f <- tempfile()
utils::download.file(locode_url, f, quiet = TRUE)
load(f) # loads unlocode
unlink(f)

#filter to only what we need
unlocode <- unlocode %>%
  select(un_locode,  latitude_dec, longitude_dec )

# JOIN!  
apple_cities_spatial <- apple_cities %>%
  left_join(unlocode,
            by = c("location_code" = "un_locode")) %>%
  
  #remove no spatial info
  filter(!is.na(latitude_dec)) %>%
  
  #turn into an sf object using x, y
  st_as_sf(coords = c("longitude_dec", "latitude_dec"),
           crs = 4326)
  

## ----plot_cities, warning=TRUE, message = TRUE--------------------------------
country_map <- rnaturalearth::ne_countries(returnclass = "sf")

unique_cities <- apple_cities_spatial %>%
  group_by(location_code) %>%
  slice(1L) %>%
  ungroup() 

ggplot() +
  geom_sf(data = country_map, fill = "lightgrey") +
  geom_sf(data = unique_cities)

## ----summarize_differences, message = FALSE-----------------------------------
apple_cities_spatial_changes <- apple_cities_spatial %>%
  group_by(location_code, data_type) %>%
  filter(as.character(date) %in% c("2020-02-01", "2020-04-01", "2020-06-01")) %>%
  arrange(date) %>%
  summarize(feb_to_april = value[2] - value[1],
            april_to_june = value[3] - value[2]) %>%
  ungroup()

## -----------------------------------------------------------------------------
ggplot() +
  geom_sf(data = country_map, fill = "lightgrey") +
  geom_sf(data = apple_cities_spatial_changes, 
          aes(color = feb_to_april),
          alpha = 0.3) +
  scale_color_viridis_c(limits = c(-250,250)) +
  facet_grid(data_type~.)

## -----------------------------------------------------------------------------
ggplot() +
  geom_sf(data = country_map, fill = "lightgrey") +
  geom_sf(data = apple_cities_spatial_changes, 
          aes(color = april_to_june),
          alpha = 0.3) +
  scale_color_viridis_c(limits = c(-250,250)) +
  facet_grid(data_type~.)

