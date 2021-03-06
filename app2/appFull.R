# In this app, we want to allow people to look at
# not only the electricity usage of area of interest
# but also the year of interest. The output will be
# a linegraph with month as x-axis, and different
# line refers to different year.

library(shiny)
library(tidyverse)

monthly <- read_rds("gru_monthly.rds")

# Define UI
ui <- fluidPage(
  
  # Application title
  titlePanel("GRU Monthly Electricity Usage"),
  
  # Now that there are two input parameters: Area and year
  # We need two input elements. Since we may want to allow
  # user to choose more than one year, drop down may not
  # be the best idea. What about checkboxes?
  sidebarLayout(
    sidebarPanel(
      selectInput("Area",
                  "Area of interest:",
                  choices = c("All" = "All",
                              "Northeast" = "NE",
                              "Northwest" = "NW",
                              "Southwest" = "SW",
                              "Southeast" = "SE")
      ),
      checkboxGroupInput("Year",
                         "Year of interest:",
                         choices = 2014:2018,
                         selected = 2017
                        )
    ),
    
    # Showing the output plot
    # And to make it abit more complicated, we'll also
    # show a line of text that explains the plot
    mainPanel(
      textOutput("plotTitle"),
      plotOutput("usagePlot")
    )
  )
)

# Define server logic
server <- function(input, output) {
  output$plotTitle <- renderText({
    area <- ifelse(input$Area == "All", "", input$Area)
    year <- paste(input$Year, collapse = ", ")
    t <- paste("Mean monthly eletricity usage per unit in ",
               area, " Gainesville in year ",
               year)
    t
  })
  
  output$usagePlot <- renderPlot({
    # generate plot based on area and year of interest from ui
    p <- monthly %>%
      dplyr::filter(zone == input$Area) %>%
      dplyr::filter(Year %in% input$Year) %>%
      ggplot(aes(x=Month, y=KWH, group=as.factor(Year), 
                 color=as.factor(Year))) +
      geom_line()
    p
  })
}

# Run the application 
shinyApp(ui = ui, server = server)