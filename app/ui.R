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
library(readxl)
library(tidyverse)
library(ggplot2)
wd <-list()
wd$output <- paste0(getwd(),"/Output")

results_long <- read_excel("Output/Result_original2.xlsx", sheet = "longCoefficient") %>%
    group_by(horizon, percentile)

# Define UI for the application
ui <- fluidPage(
    sidebarLayout(
        sidebarPanel(

            # Add a continent dropdown selector
            selectInput("percentile", "Percentile",
                        choices = levels(results_long$percentile),
                        multiple = TRUE,
                        selected = "5th")
        ),
            selectInput("coefficient", "Coefficient", choices = c("dlgdp", "infl", "fci", "CredGr", "intercept", "cons")),
        mainPanel(
            plotOutput("plot")
        )
    )
)



# Define the server logic
server <- function(input, output) {
    output$plot <- renderPlot({
        # Subset the gapminder dataset by the chosen continents
        data <- subset(results_long,
                       percentile %in% input$percentiles)
        
        plot_data <- reactive({ #Something that's not an output of shiny but responsive to input
            data <- results_long %>%
                filter(percentile %in% input$percentile)%>%
                select(horizon, percentile, value = paste0(input$coefficient, "_bb"), value_ub = paste0(input$coefficient, "_ub"), value_lb = paste0(input$coefficient, "lb"))
        })
        
        p <- ggplot(plot_data()) +
            geom_line(aes(x = horizon, y = value, colour = percentile)) +
            geom_line(aes(x = horizon, y = value_lb, colour = percentile)) +
            geom_line(aes(x = horizon, y = value_ub, colour = percentile)) 
    
    })
    
}
shinyApp(ui = ui, server = server)
