## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ---- message=FALSE, warning=FALSE,echo=TRUE,eval=FALSE-----------------------
#  library(covid19mobility) #to get data on mobility from Apple/Google
#  library(dplyr) # for joining, piping data frames
#  library(lubridate) # for dealing with our date data
#  library(sf) # shapefile manipulation
#  library(urbnmapr) #to get county and state data in a shapefile
#  library(gganimate) # to animate plots

## ---- message=FALSE, warning=FALSE,echo=FALSE,eval=TRUE,include=FALSE---------
#not using urbanmappr directly as it is not on CRAN
library(covid19mobility) #to get data on mobility from Apple/Google
library(dplyr) # for joining, piping data frames
library(lubridate) # for dealing with our date data
library(sf) # shapefile manipulation
library(gganimate) # to animate plots

## ---- out.width="100%"--------------------------------------------------------
head(refresh_covid19mobility_apple_subregion())

## ---- out.width="100%"--------------------------------------------------------
apple_us <- refresh_covid19mobility_apple_subregion() %>%
  filter(country=="United States") %>% # we are only going to map the US
  group_by(location,date) %>% #we are going to group by location (which is the state) and date
  summarize_if(is.numeric, mean) %>% #we are going to take the mean mobility score across counties by date and state
  mutate(weeks=round_date(date, "weeks")) %>% #we are going to take only the first date of each week
  group_by(weeks) %>% # we are going to group by each week
  filter(date==min(weeks)) #again we want to take only the first date of each week


## ---- eval=FALSE--------------------------------------------------------------
#  states_sf <- urbnmapr::get_urbn_map("states", sf=TRUE) %>%
#    st_as_sf() # coerce this to a shapefile.

## ---- include = FALSE---------------------------------------------------------
#dealing with urbanmapr not on cran
urbn_url <- "https://github.com/UrbanInstitute/urbnmapr/raw/master/R/sysdata.rda"
f <- tempfile()
utils::download.file(urbn_url, f, quiet = TRUE)
load(f) # loads unlocode
unlink(f)
rm(ccdf) 
rm(territories) 
rm(territories_sf) 
rm(territories_counties_sf) 
rm(territories_counties) 
rm(statedata) 

## ---- out.width="100%"--------------------------------------------------------
total_apple_us  <- left_join(apple_us,states_sf, by=c("location"="state_name")) %>%
  st_as_sf() # this function makes sure the shape files are readable.

total_apple_us <- as.data.frame(total_apple_us) %>%
  st_as_sf()

## ----map, out.width="100%"----------------------------------------------------
ggplot() +
  geom_sf(data=states_sf)


## ----anim, out.width="100%", warning=FALSE, eval=FALSE------------------------
#  ggplot() + #call ggplot
#    geom_sf(data=states_sf) + # map the shape files to the map of the USA
#    geom_sf(data= total_apple_us, aes(fill=value)) + # fill with our data frame and value, which is mobility score
#    labs(fill="% change in mobility",
#         title="Date: {current_frame}",
#         subtitle="Percent Change in Movement, Source: Apple Mobility Data",
#         fill = "% change in mobility") + #add titles
#    scale_fill_viridis_c() +
#    transition_manual(date) #animate by day - this is a gganimate function!

## ---- eval = FALSE, echo = FALSE----------------------------------------------
#  anim_save("./data-raw/covid_mobility_change.gif")

