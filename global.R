#load packages
library(shiny)
library(shinydashboard)
library(tidyverse)
library(snakecase)
library(leaflet)
library(leaflet.extras)
library(geosphere)
library(echarts4r)
library(tigris)
# library(forecast) #coming soon prediction
library(tidycensus)
library(zipcodeR)
library(scales)



#load data
data_market <- readRDS("data_historical.rds")
data_school <-readRDS("school_data.rds")
data_agent <- readRDS("agent_data.rds") %>% 
  mutate(id=1)
data_zip_geometry <- readRDS("zip_geometry.rds")

#make lists
options(tigris_use_cache = TRUE)
cities_list <- sort(unique(data_market$zip_name))
zip_list <- sort(unique(data_market$zip))
current_year <- max(data_market$year)
current_month <- max((data_market %>% filter(year ==current_year))$month)

months <- c("Jan","Feb","Mar",
            "Apr","May","Jun",
            "Jul","Aug","Sep",
            "Oct","Nov","Dec")
