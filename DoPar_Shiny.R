library(shiny)

library(dplyr)

library(readr)

library(purrr) # just for `%||%`

library(readxl)

library(plotly)

library(DT)

source("C:\\Users\\Documents\\certs\\Pie_chart_all.R")



my_data <-as.data.frame(read_excel("C:\\Users\\OneDrive\\Documents\\Certs-Expiring.xlsx", 

                  sheet = 1, 

                  col_types = c("text","skip","date")))



#Getting rid of any duplicate websites

my_data<-unique(my_data)



categories <- unique(f$Status)



ui <- fluidPage(plotlyOutput("pie"),

        uiOutput("back"),

        dataTableOutput('dto'), 

        dateInput("date", "Date range:", min = Sys.Date()),

        mainPanel(tags$div(id = "placeholder")))



server <- function(input, output, session) {

  

 # for maintaining the current category (i.e. selection)

 current_category <- reactiveVal()

 date_change <- reactiveVal()

  

  

  

 # report sales by category, unless a category is chosen

 sales_data <- reactive({

  if (!length(current_category())) {

    

   return(count(f, f$Status))

  }else{

   

  

   f%>%

    filter(Status %in% current_category()) %>%

    count(Status)

  }

 })



  filter_datatable <- reactive({

  # if (!length(date_change())) {

  #  return(f)

  # }

    

   if (!length(current_category())&input$date== Sys.Date()) {

    return(f)

   }

    

    f%>%filter(as.Date(as.POSIXct(f$Website.Expiration.Date, format = "%m/%d/%Y")) < input$date,

          Status %in% current_category())

 })

   

  # filter_datatable <- reactive({

  #  if(input$date== Sys.Date()&!length(current_category())){

  #   f%>%filter(as.Date(as.POSIXct(f$Website.Expiration.Date, format = "%m/%d/%Y")) < input$date)

  #  }else {

  #   

  #  }

  #  

  # })

   

   

 output$dto <- renderDataTable({

  status_table<- setNames(filter_datatable(), c("Entrust MSO Common Name", "Entrust MSO Expiration Date","Website Expiration Date","Port#", "Status"))

  # status_table%>%filter(as.Date(as.POSIXct(status_table$`Website Expiration Date`, format = "%m/%d/%Y")) >input$daterange[1]& as.Date(as.POSIXct(status_table$`Website Expiration Date`, format = "%m/%d/%Y")) < input$daterange[2])

  datatable(status_table, extensions = 'Buttons', 

                options = list(dom = 'Bfrtip',

                        buttons = c('copy', 'csv', 'excel', 'pdf', 'print')))

 })



  

 # Note that pie charts don't currently attach the label/value 

 # with the click data, but we can include as `customdata`

 output$pie <- renderPlotly({

     d <- setNames(sales_data(), c("labels", "values"))

   plot_ly(d) %>%

    add_pie(

     labels = ~labels, 

     values = ~values, 

     customdata = ~labels

    ) %>%

    layout(title = current_category() %||% "Certificate Verification Pie Chart")

   

 })

  

 # update the current category when appropriate

 observe({



  cd <- event_data("plotly_click")$customdata[[1]]

  if (isTRUE(cd %in% categories)) {current_category(cd)}

   



 })

  

 # observe({

 #  

 #  cd <- event_data("plotly_click")$date

 #  date_change(cd)

 # 

 # 

 # })

  

 # obsB<-observe({

 #  #user_date<-input$date

 #  click_date <- event_data("plotly_click")

 #  date_change(click_date)

 #  

 # })

  

  

 # populate back button if category is chosen

 output$back <- renderUI({

  if (length(current_category())) 

   actionButton("clear", "Back", icon("chevron-left"))

 })

  

 # clear the chosen category on back button press

 observeEvent(input$clear,current_category(NULL))

 # observeEvent(input$clear, {

 #  removeUI("#dto")

 #  insertUI("#placeholder", "afterEnd", ui = DT::dataTableOutput('dto'))

 # })





}



shinyApp(ui, server, options = list(port = 443) )

