map_plot <- function(df, df_public, df_private, agent_radius) {
  
  #
  pal <- colorNumeric(
    palette = "Greens",
    domain = as.numeric(df$median_home_value))
  
  df %>% 
    leaflet() %>% 
    addTiles() %>% 
    addResetMapButton() %>% 
    addPolygons(
      fillColor = ~pal(median_home_value),
      weight = 2,
      opacity = .9,
      color = "black",
      dashArray = "3",
      fillOpacity = .8,
      highlight = highlightOptions(weight = 3,
                                   color = "#666",
                                   dashArray = "",
                                   fillOpacity = 0.2,
                                   bringToFront = FALSE),
      popup = ~as.character(paste(
        paste("Zip: ", zip," (data as of: ", month,"/", year, ")", sep=""),
        # paste("County:", county),
        paste("Median List Price:", median_listing_price),
        # paste("New Listings:", new_listing_count),
        paste("Active Listings:", active_listing_count),
        
        paste("---comparative data for selected area---"),
        paste("area wealth index:", city_cost_index),
        paste("household income:", dollar(median_household_income)),
        paste("home values:", dollar(median_home_value)),
        sep="<br/>") )
    ) %>% 
    addLegend(pal = pal, 
              values = ~median_home_value, 
              opacity = 0.7, 
              title = as.character("Median home values"),
              position = "bottomright") %>% 
    
    addAwesomeMarkers(
      data = df %>%
        select(zip, zip_name, lat, lng) %>%
        unique() %>%
        mutate(id=1) %>%
        left_join(
          data_agent
        ) %>%
        rowwise() %>%
        mutate(dist = distm(c(lng, lat), c(agent_lng, agent_lat), fun=distHaversine)) %>%
        group_by(zip) %>%
        mutate(dist_rank = rank(dist)) %>%
        mutate(dist = dist/1000*.62) %>%
        filter(dist<agent_radius) %>%
        ungroup() %>%
        select(zip_name, name, brokerage, location, phone, email, website, agent_lng, agent_lat) %>%
        unique(),
      ~agent_lng,
      ~agent_lat,
      group="Agents",
      icon=awesomeIcons(
        markerColor = "gray",
        icon= "user",
        iconColor = "red"
      ),
      label = ~as.character(paste(
        "Name",
        name, "/",
        "Location:",
        location
      )
      ),
      popup = ~as.character(paste(
        paste("Agent name: ", name, sep=""),
        paste("Brokerage:", brokerage),
        paste("Phone:", phone),
        paste("Email:", email),
        paste("Website: ", website),
        # paste("Website:", "<a href=\"", website , "\">", "click here", "</a>"),
        # target="_blank"
        sep="<br/>")
      )
    )%>%
    
  
  addCircleMarkers(data= df_public,
                   ~lon,
                   ~lat,
                   color = "green",
                   group="Public Schools",
                   radius = 5,
                   popup =  ~as.character(paste(
                     paste("Name:",name),
                     paste("School Type:", category, sch_type_text),
                     paste("Level:",level),
                     paste("Street:", lstreet1),
                     paste("Phone:", phone),
                     sep="<br/>")),
                   label = ~as.character(paste(
                     name)
                   )
  ) %>%
    addCircleMarkers(data= df_private,
                     ~lon,
                     ~lat,
                     color = "blue",
                     group="Private Schools",
                     radius = 5,
                     popup =  ~as.character(paste(
                       paste("Name:",name),
                       paste("School Type:", category, sch_type_text),
                       paste("Level:",level),
                       paste("Street:", lstreet1),
                       paste("Phone:", phone),
                       sep="<br/>")),
                     label = ~as.character(paste(
                       name)
                     )
    ) %>% 
    
    
  addLayersControl(overlayGroups = c("Agents",
                                     "Public Schools", "Private Schools"),
                   layersControlOptions(collapsed=TRUE))
  
}


analysis_plot <- function (df, feature, feature2, zip, current_month) {
  
  zip_name <- (df %>% 
                 filter(zip==zip) %>%
                 select(zip_name) %>%
                 unique())$zip_name
  

  
  avg <- list(
    type = "average",
    name = "AVG",
    title = "mean"
  )
  
  df %>%
    filter(zip %in% zip, year %in% c("2021", "2022", "2023", "2024")) %>%
    mutate_at(vars(.data[[feature2]]), ~round(.x*100,1)) %>%
    mutate(period = paste(month, year, sep="-")) %>%
    arrange(year, month) %>% 
    e_charts(x = period) %>% 
    
    e_line(serie = median_listing_price, smooth=TRUE) %>% 
    e_area(active_listing_count, y_index = 1) %>% 
    e_title(paste(toupper(zip_name), zip)) %>% 
    e_tooltip(trigger = "axis") %>% 
    e_legend() %>% 
    e_theme("westeros") %>% 
    e_mark_point("median_listing_price", data = list(type = "max")) %>% 
    e_mark_point("active_listing_count", data = list(type = "min")) %>% 
    e_axis_labels(y="Median listing price") %>% 
    e_mark_line(data = avg) %>% 
    
    e_x_axis(axisLabel = list(interval = 0, rotate = 90)) %>% 
    e_datazoom(x_index = 0, type = "slider")
  
}

################## predictions coming soon!
# median_listing_predition <- function(df, zip_select) {
#   
#   df_model_timeseries <-  df %>%
#     ungroup() %>% 
#     mutate(date = dmy(paste0("01", month, year, sep="/"))) %>% 
#     filter(grepl(zip_select, zip)) %>% 
#     select(date, year, month, zip, zip_name, median_listing_price) %>% 
#     arrange(date)
#   
#   # glimpse(df_model_timeseries)
#   
#   mts <- ts(df_model_timeseries$median_listing_price, frequency = 12, start = c(
#     min(df_model_timeseries$year),
#     min((df_model_timeseries %>%
#            filter(year==min(df_model_timeseries$year)))$month)))
#   
#   fit_arima <- auto.arima(mts, d=1, D=1, stepwise = FALSE, approximation = FALSE, trace=TRUE)
#   
#   output_forecasted_values <- forecast(fit_arima, h = 12, level = .9)
  
  # output <- forecasted_values %>% 
  #   as.data.frame() %>% 
  #   rename(predicted_median_listing_price = 1) %>% 
  #   rename(CI_lower = 2, CI_upper=3) %>% 
  #   rownames_to_column("date") %>% 
  #   separate(date, into=c("month", "year")) %>%
  #   mutate_at(vars(month), ~match(.x, month.abb)) %>% 
  #   mutate_at(vars(month), ~str_pad(.x, width = 2, pad = "0")) %>% 
  #   mutate(zip = zip_name)
  # 
  # 
# }

# median_listing_predition(data_market, "70448")

# print(forecasted_values)
# plot_median_listing_prediction <- function(forecasted_values) {
#   plot(forecasted_values, main="Sales Forecast for Next 12 Months")
# }

