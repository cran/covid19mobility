## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, warning=FALSE, message=FALSE--------------------------------------
library(covid19mobility)
library(dplyr)

us_mobile <- refresh_covid19mobility_apple_country() %>%
  filter(location_code == "US")


## ----plot_us_mobility---------------------------------------------------------
library(ggplot2)


ggplot(us_mobile,
       aes(x = date, y = value, color = data_type)) +
  geom_line(size = 1) +
  theme_bw(base_size=14) +
  labs(color = "Mobility Type",
       y = "Relative Value",
       x = "") +
  ggtitle("Apple Mobility Trends")


