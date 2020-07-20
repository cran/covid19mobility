## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
options(rmarkdown.html_vignette.check_title = FALSE)

## ----setup, warning = FALSE, message = FALSE----------------------------------
library(covid19mobility)
library(ggplot2)
library(dplyr)
library(tidyr)

goog <- refresh_covid19mobility_google_subregions()

goog %>%
  pull(data_type) %>%
  unique

## ----goog_wp, include = FALSE, results = "hide"-------------------------------
goog_wp <- goog %>%
  filter(data_type %in% c("workplaces_perc_ch",
                          "residential_perc_ch")) %>%
  filter(!is.na(value),
         !is.na(date))

## ----weird_ts_plot, message=FALSE, warning=FALSE, eval = FALSE----------------
#  goog_wp <- goog %>%
#    filter(data_type %in% c("workplaces_perc_ch",
#                            "residential_perc_ch")) %>%
#    filter(!is.na(value))
#  
#  ggplot(goog_wp,
#         aes(x = date, y = value,
#             group = location_code)) +
#    geom_line(alpha = 0.15, color = "lightgrey") +
#    facet_wrap(~data_type) +
#    theme_bw() +
#    stat_smooth(group = 1,
#                method = "gam",
#                fill = NA,
#                color = "black")+
#    labs(caption = "Data from Google Covid-19 Mobility Report\n
#         https://www.google.com/covid19/mobility/") +
#    xlab("") + ylab("Relative % Change")

## ----cor_plot, message=FALSE, warning=FALSE-----------------------------------
goog_wp_wide <- pivot_wider(goog_wp,
                            names_from = data_type,
                            values_from = value) %>%
  filter(!is.na(residential_perc_ch)) #some unevenness is reporting

ggplot(goog_wp_wide %>% filter(workplaces_perc_ch<=100), #a few outliers
       aes(x = workplaces_perc_ch, 
           y = residential_perc_ch,
           color = as.numeric(date))) +
  geom_point(alpha = 0.2) +
  scale_color_viridis_c("Date",
                        breaks = as.numeric(pretty(goog_wp_wide$date)),
                        labels = pretty(goog_wp_wide$date)) +
  scale_x_continuous("Percent Change in Visits to Workplaces from baseline",
                     labels = function(x) paste0(x, '%'),
                     limits = c(-100,100)) +
  scale_y_continuous("Percent Change in Visits to Residences from baseline",
                     labels = function(x) paste0(x, '%')) +
  theme_bw() +
  labs(caption = "Data from Google Covid-19 Mobility Report\n
       https://www.google.com/covid19/mobility/")

