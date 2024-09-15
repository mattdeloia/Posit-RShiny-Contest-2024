shinyUI(
  dashboardPage(
    
    
    skin = "green",
    dashboardHeader(title = "MustWants Agent App"),
    dashboardSidebar(
      
      width = 300,
      column( width=12,
              
              h4("Markets by Zip"),
              selectizeInput("city_name", 
                             label = em("Select cities to explore."),
                             choices = NULL, multiple=TRUE), 
              h4("MustWants Agents"),
              sliderInput("agent_radius", label=em("Distance (miles) to nearby Agents"), min=50, max=500, value=50, ticks=FALSE),
              
              
              hr(style = "border-top: 1px solid #00FF00"),
              
              h4("Listing Prices"),
              selectInput("zip", label = em("Select zip code to explore."), 
                          choices = NULL, selected = NULL),
              
              hr(style = "border-top: 1px solid #00FF00;"), 
              h4("Objective"),

              h5("MustWants is a home search platform specifically designed to assist military personnel and their families in finding their dream homes. This RShiny App is a prototype for the visual data analysis pages on the MustWants website."), br(),
              tags$a(href="https://www.mustwants.com/", "For more on MustWants, Click here!"), br(),
 em(" Please share suggestions or requests to: matt@mustwants.com"), br(),
  
      )
    ),
    
    dashboardBody(
      tabsetPanel(type="pills",
                  
                  tabPanel(title = "Tab 1 - Markets by Zip", 
                           icon = icon("house"),
                           
                           leafletOutput("map", height = 700)
                           
                  ), 
                  
                  tabPanel(title = "Tab 2 - Listing Prices",
                           icon = icon("dollar-sign"),
                           echarts4rOutput("plot_price", height = 700) 
                           
                  ),
                  # 
                  tabPanel(title = "Tab 3 - References",
                           icon = icon("info"),
                           h3("Data Sources"),
                           h4("1. 2022 Census Bureau data from the American Community Survey. Data downloaded using the tidycensus package and 'get_acs' function for the variable 'B25077_001,' median household income. "),
                           verbatimTextOutput("citation_tidycensus"),
                           h4("2. Zip code geometry data downloaded from the 'tigris' package and 'zctas' function."),
                           verbatimTextOutput("citation_tigris"),
                           h4("3. Zip code lat and long downloaded from 'zipcodeR' package."),
                           verbatimTextOutput("citation_zipcodeR"),
                           h4("4. Real estate data (e.g., median listing price, active listing counts) downloaded from realtor.com monthly inventory zip data."),
                           tags$a(href="https://www.realtor.com/research/data/", "Realtor.com data, Click here!"),
                           h4("5. Public School location information downloaded from the National Center for Education Statistics."),
                           tags$a(href="https://data-nces.opendata.arcgis.com/maps/0e8df2dcbbc54e13833344e2ca8c0fa4", "NCES Public School Locations, Click here!"),
                           h4("6. Public School general information downloaded from the National center for Education Statistics Common Core of Data."),
                           tags$a(href="https://nces.ed.gov/ccd/", "NCES Public School information, Click here!"),
                           h4("7. Private School location information downloaded from the National Center for Education Statistics."),
                           tags$a(href="https://data-nces.opendata.arcgis.com/datasets/1c004a108b18460bba1ddb29ec1f7982", "NCES Private School Locations, Click here!"),
                           h4("8. Real Estate Agent data, such as personal information and coverage location, provided by Scott Hayford, CEO of MustWants."),
                           h3("References to R packages used in the performance of the app."),
                           
                           verbatimTextOutput("citation_shiny"),
                           verbatimTextOutput("citation_shinydashboard"),
                           verbatimTextOutput("citation_tidyverse"),
                           verbatimTextOutput("citation_snakecase"),
                           verbatimTextOutput("citation_leaflet"),
                           verbatimTextOutput("citation_leafletextras"),
                           verbatimTextOutput("citation_geosphere"),
                           verbatimTextOutput("citation_echarts4r"),
                           verbatimTextOutput("citation_scales"),
                  )
      )
    )
  )
)
