#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(shinythemes)
library(readxl)
library(tidyverse)
library(ggplot2)
library(lubridate)
library(stringr)
library(magrittr)
library(reshape2)
library(DT)
library(grDevices)
library(ggthemes)
library(zip)

#setwd("/Users/malcalakovalski/Documents/GitHub/liang_GaR/Output/")

results_long <- read.csv("result.csv", stringsAsFactors = FALSE) 
GaR <- read_excel("Result_original2.xlsx") %>% 
  mutate(Time = as.Date(Time)) #%>% 
 # mutate(Quarter = paste(year(Time), "Q", quarter(Time)) %>% str_replace("Q\\s", "Q"))

# Define UI for the application
ui <- fluidPage(theme = shinytheme("lumen"), navbarPage("Growth at Risk",
    tabPanel("Coefficients",
             sidebarLayout(
        sidebarPanel(
            # Add a percentile dropdown selector
            selectizeInput("percentile", "Percentile",
                        choices = unique(results_long$percentile),
                        multiple = TRUE,
                        selected = "5th"),
            selectizeInput("coefficient", "Coefficient", choices = c("dlgdp" = "dlgdp", "infl" = "infl", "fci" = "fci", "CredGr" = "CredGr",
                                                                     "interact" =  "interact", "cons" = "cons"),
                           multiple = FALSE, selected = "dlgdp")
        ),
        mainPanel(
            tabsetPanel(type = "tabs",
                        tabPanel("Plot", 
                                 plotOutput("plot")
                        ),
                        tabPanel("Table", 
                                 dataTableOutput("table")
                        )
            )
            
        )
      )
    ),
    tabPanel("GaR_timeseries",
             sidebarLayout(
                 sidebarPanel(
                   # Add a year dropdown selector
                  dateRangeInput(inputId = "dRange",
                               label = "Date Range",
                               start="1974-01-01",
                               end = "2021-04-01",
                               format = "yyyy-mm-dd",
                               min = "1974-01-01",
                               max = "2021-04-01",
                               startview = c("month"),
                               separator = "-"),
                   selectizeInput(
                     "horizon","Horizon", choices = c("4","8"), multiple = FALSE, selected = "4")
                  ),
                 mainPanel(
                   tabsetPanel(type = "tabs",
                               tabPanel("Plot", 
                                        plotOutput("GaR.plot")
                               ),
                               tabPanel("Table", 
                                        dataTableOutput("table.GaR")
                               )
                   )
                 )
              )
          )
     )
)





# Define the server logic
server <- function(input, output) {
  
  ### Coefficients 
    output$plot <- renderPlot({
        # Subset data by chosen filters

        plot_data <- reactive({ #Something that's not an output of shiny but responsive to input
            data <- results_long %>%
                filter(percentile %in% input$percentile)%>%
                select(horizon, percentile, value = paste0(input$coefficient, "_bb"), value_ub = paste0(input$coefficient, "_ub"), 
                       value_lb = paste0(input$coefficient, "_lb"))
        })

        p <- ggplot(plot_data()) +
            geom_line(aes(x = horizon, y = value, colour = percentile)) +
            geom_line(aes(x = horizon, y = value_lb, colour = percentile)) +
            geom_line(aes(x = horizon, y = value_ub, colour = percentile))
        
        print(p)

    })
    
    data_input <- reactive({
      data <- results_long %>% 
        filter(percentile %in% input$percentile)%>%
        select(horizon, percentile, value = paste0(input$coefficient, "_bb"), value_ub = paste0(input$coefficient, "_ub"), 
               value_lb = paste0(input$coefficient, "_lb"))
    })
    
    output$table <- renderDataTable(
      
      datatable(data_input(),options=list(pagelength = 25))
    )
    
    ### GaR
    
    output$GaR.plot <- renderPlot({
      plot_data <- reactive({
        df <- GaR %>% 
          filter(Time >= input$dRange[1] & Time <= input$dRange[2]) %>%
          select(Time, value = paste0("GaR_h", input$horizon))
      })
      p2 <- ggplot(plot_data()) +
        geom_line(aes(x = Time, y = value))
      print(p2)
        
    })
    data_input.GaR <- reactive({
      df <- GaR %>% 
        filter(Time >= input$dRange[1] & Time <= input$dRange[2]) %>% 
        select(Time, value = paste0("GaR_h", input$horizon)) 
    })
    output$table.GaR <- renderDataTable(
      
      datatable(data_input.GaR(),options=list(pagelength = 25))
    )
    
   
}
shinyApp(ui = ui, server = server)

