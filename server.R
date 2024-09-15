function(input, output, session) {

  updateSelectizeInput(
    session,
    inputId = "city_name",
    choices = cities_list,
    server = TRUE)
  
  df_map <- reactive({
    data_zip_geometry %>% 
      filter(zip_name %in% c(input$city_name)) %>% 
      left_join(
        data_market %>%
          filter(zip_name %in% c(input$city_name)) %>% 
          filter(year==current_year, month==current_month) %>%
          mutate(median_household_income_scale = scale(median_household_income),
                 median_home_value_scale = scale(median_home_value)) %>% 
          mutate(city_cost_index = (median_household_income_scale + median_home_value_scale)/2) %>% 
          mutate_at(vars(city_cost_index),
                    ~if_else(.x < (-.5), "Lowest", 
                             if_else(.x <= .5, "Median",
                                     if_else(.x > .5, "Highest", "Unknown")))) %>% 
          mutate_at(vars(city_cost_index), ~replace_na(.x, "Median")) %>% 
          mutate(median_listing_price = dollar(median_listing_price)),
        join_by("zip", "zip_name")
      ) 
  })
  
  df_public_school <- reactive({
    data_school %>%
      filter(zip_name %in% input$city_name, category=="Public")
  })
  
  df_private_school <- reactive({
    data_school %>%
      filter(zip_name %in% input$city_name, category=="Private")
  })
  
  output$map <- renderLeaflet({
    shiny::validate(
      need(input$city_name, "-- AWAITING INPUT OF CITY --")
    )
    
    map_plot(df_map(), df_public_school(), df_private_school(), input$agent_radius)
  })
  
  city_zip_list <- reactive({
    (df_map() %>% select (zip) %>% unique() %>% 
       arrange(zip))$zip
  })
  
  observe({
    updateSelectInput(
      session=session,
      inputId = "zip",
      choices = city_zip_list())
    
  })
  
  df_zip <- reactive({
    data_market %>%
      filter(zip == input$zip)
    
  })
  
  output$plot_price <- renderEcharts4r({
    shiny::validate(
      need(input$zip, "- AWAITING INPUT OF ZIP CODE -")
    )
    analysis_plot(df_zip(), "median_listing_price", "median_listing_price_mm", input$zip, current_month)
  })
  

  output$citation_shiny <- renderPrint({print(citation("shiny"), style="text")})
  output$citation_shinydashboard <- renderPrint({print(citation("shinydashboard"), style="text")})
  output$citation_tidyverse <- renderPrint({print(citation("tidyverse"), style="text")})

  output$citation_snakecase <- renderPrint({print(citation("snakecase"), style="text")})
  output$citation_leavlet <- renderPrint({print(citation("leaflet"), style="text")})
  output$citation_leafletextras <- renderPrint({print(citation("leaflet.extras"), style="text")})
  output$citation_geosphere <- renderPrint({print(citation("geosphere"), style="text")})
  output$citation_echarts4r <- renderPrint({print(citation("echarts4r"), style="text")})
  output$citation_tigris <- renderPrint({print(citation("tigris"), style="text")})
 # output$citation_forecast <- renderPrint({print(citation("forecast"), style="text")})
  output$citation_tidycensus <- renderPrint({print(citation("tidycensus"), style="text")})
  output$citation_zipcodeR <- renderPrint({print(citation("zipcodeR"), style="text")})
  output$citation_scales <- renderPrint({print(citation("scales"), style="text")})
  
}
