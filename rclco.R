  library(shiny)
  library(sf)
  library(tidyverse)
  library(leaflet)
  library(shiny)
  library(sp)
  library(shinyWidgets)
  library(colorspace)
  library(DT)
  
  poi = readRDS('C:/Users/Owner/Documents/poi_in_location.rds')
  poi<-poi %>%
    mutate(long = unlist(map_dbl(poi$geometry,1)),
           lat = unlist(map_dbl(poi$geometry,2)))%>%
    mutate_if(is.character, utf8::utf8_encode)
  my_sf <- st_as_sf(poi, xcol="long", ycol="lat", crs = 4326)
  
  tracts_demo <- readRDS('C:/Users/Owner/Documents/census_blocks.rds')
  
  pal <- colorNumeric(
    palette = "YlOrRd",
    domain = my_sf$visits)

    ui <- fluidPage(
    
    # Application title
    titlePanel("Geo_space Demo"),
    
    sidebarLayout(
      sidebarPanel(
        pickerInput("tracts",
                    "Select  Tracts byTract_ID:",
                    choices = c( as.list(tracts_demo$geoid)),multiple = T, selected=tracts_demo$geoid,
                    options = list(`actions-box` = TRUE)
        ),
        pickerInput("location",
                    "Select Location:",
                    choices = c( as.list(my_sf$location_name)),multiple = T, selected=my_sf$location_name,
                    options = list(`actions-box` = TRUE)
        )
      ),
      
      mainPanel(
        leafletOutput("travelshed_map", height = "100vh"),
        dataTableOutput("census_data")
        
      )
    )
  )
  
  
  server <- function(input, output) {
    
    tracts_reactive <-reactive({

       tracts_demo %>% filter(tracts_demo$geoid %in% input$tracts)
      

    }) 
    
    
    markers_reactive <-reactive({
      

      my_sf %>% filter(my_sf$location_name %in% input$location)
      
    }) 
    
    popup <-  reactive({
      HTML(paste0("<b>","Tract No: ","</b>", tracts_reactive()$geoid))
    })
    

    
    output$travelshed_map <- renderLeaflet({
  
      leaflet() %>%
        addProviderTiles("CartoDB.Positron") 
      
      leaflet(my_sf) %>% addTiles() %>% addMarkers(popup = ~location_name)  %>% addCircleMarkers(
        color = ~pal(visits),
        lng = ~long,
        lat = ~lat)
    })

    observe({ 
      proxy<-  leafletProxy("travelshed_map") %>% clearGroup("tracts")
     # markers<-  leafletProxy("travelshed_map") %>% clearGroup("location")
      
     markers<- leafletProxy("travelshed_map", data=markers_reactive()) %>%
       clearMarkers() 
      
       markers%>% addMarkers(popup = ~location_name) %>%
         addCircleMarkers(data = markers_reactive(),
                       color=~pal(visits),
                       lng  = ~long,
                       lat  = ~lat,
      )
      

      proxy %>%
        addPolygons(data= tracts_reactive(), color = "#444444", weight = 1, smoothFactor = 0.5,
                    opacity = 1.0, fillOpacity = 0.5,
                    fillColor = "Black", group = "tracts",
                    highlightOptions = highlightOptions(color = "white", weight = 2,
                                                        bringToFront = TRUE),
                    label = popup()) 
      
    })
    
    output$census_data<-renderDataTable({
      
tracts_demo<-      tracts_demo %>% filter(tracts_demo$geoid %in% input$tracts)
tracts_demo
})
    
    
  }
  
  
  
  # Run the application 
  shinyApp(ui = ui, server = server)
