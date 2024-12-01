
library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)

# Define UI
ui <- dashboardPage(
  dashboardHeader(title = "Shiny Dashboard Example"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Country Data", tabName = "country_data", icon = icon("globe")),
      menuItem("Charts", tabName = "charts", icon = icon("chart-bar")),
      menuItem("Regressions", tabName = "regressions", icon = icon("chart-line")),
      menuItem("Text Analysis", tabName = "text_analysis", icon = icon("font"))
    )
  ),
  dashboardBody(
    tabItems(
      # First tab: User selects country data and displays line chart
      tabItem(tabName = "country_data",
              fluidRow(
                # Select country
                box(title = "Select Country", width = 4, solidHeader = TRUE, status = "primary",
                    selectInput("country", "Select Country:", choices = unique(cleaned_data$Country.Name))),
                
                # Line chart showing Debt, GDP, and Revenue for the selected country
                box(title = "Country Data (Debt, GDP, Revenue)", width = 8, solidHeader = TRUE, status = "primary",
                    plotOutput("country_line_chart"))
              )
      ),
      
      # Second tab: Display 3 plots (Plot 2.1, Plot 2.3, Plot 2.4)
      tabItem(tabName = "charts",
              box(title = "Plot 2.1: Debt vs Revenue", width = 12, solidHeader = TRUE, status = "primary",
                  plotOutput("plot_2_1")),
              box(title = "Plot 2.3: GDP vs Debt", width = 12, solidHeader = TRUE, status = "primary",
                  plotOutput("plot_2_3")),
              box(title = "Plot 2.4: GDP vs Revenue", width = 12, solidHeader = TRUE, status = "primary",
                  plotOutput("plot_2_4"))
      ),
      
      # Third tab: Display regression plots
      tabItem(tabName = "regressions",
              box(title = "Regression: Debt ~ Revenue", width = 12, solidHeader = TRUE, status = "primary",
                  plotOutput("regression_plot_1")),
              box(title = "Regression: GDP ~ Debt", width = 12, solidHeader = TRUE, status = "primary",
                  plotOutput("regression_plot_2"))
      ),
      
      # Fourth tab: Display text analysis plots
      tabItem(tabName = "text_analysis",
              box(title = "Text Analysis: Revenue vs Debt", width = 12, solidHeader = TRUE, status = "primary",
                  plotOutput("text_analysis_plot_1")),
              box(title = "Text Analysis: GDP vs Revenue", width = 12, solidHeader = TRUE, status = "primary",
                  plotOutput("text_analysis_plot_2"))
      )
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  # First tab: Generate line chart for selected country showing Debt, GDP, and Revenue over time with dual axis
  output$country_line_chart <- renderPlot({
    req(input$country)  # Ensure input$country is selected
    
    # Filter data for the selected country
    country_data <- cleaned_data %>% filter(Country.Name == input$country)
    
    # Check if country_data is empty (for debugging)
    if(nrow(country_data) == 0) {
      print("No data found for the selected country.")
      return(NULL)  # Return NULL if no data for selected country
    }
    
    # Get max value for Debt and Revenue to set the left axis scale
    max_debt_revenue <- max(c(country_data$Debt, country_data$Revenue), na.rm = TRUE)
    
    # Get max value for GDP to set the right axis scale
    max_gdp <- max(country_data$GDP, na.rm = TRUE)
    
    # We will scale the GDP to make sure it appears correctly on the graph
    # Factor to scale GDP (to match the scale of Debt and Revenue on the primary axis)
    scale_factor <- max_gdp / max_debt_revenue
    
     # Create a line plot for Debt, GDP, and Revenue over time
    ggplot(country_data, aes(x = Year)) +
      # Plot GDP on the right axis, scaled by the factor
      geom_line(aes(y = GDP / scale_factor, color = "GDP"), size = 1.2) +
      # Plot Debt on the left axis
      geom_line(aes(y = Debt, color = "Debt"), size = 1.2) +
      # Plot Revenue on the left axis
      geom_line(aes(y = Revenue, color = "Revenue"), size = 1.2) +
      labs(title = paste("Debt, GDP, and Revenue for", input$country),
           x = "Year",
           y = "Debt & Revenue (% of GDP)",
           color = "Legend") +
      scale_color_manual(values = c("GDP" = "blue", "Debt" = "red", "Revenue" = "green")) +
      scale_y_continuous(
        name = "Debt & Revenue (% of GDP)",  # Primary y-axis name (Debt/Revenue in % of GDP)
        limits = c(0, max_debt_revenue * 1.1),  # Ensure the left axis goes up to a little higher than the max Debt/Revenue value
        sec.axis = sec_axis(~ . * scale_factor, name = "GDP (USD Billion)")  # Secondary axis for GDP (actual USD, scaled by factor)
      ) +
      theme_minimal() +
      theme(
        axis.title.y = element_text(color = "black"),
        axis.title.y.right = element_text(color = "blue"),
        axis.text.y.right = element_text(color = "blue")
      )
  })
  
  
  
  
  
  
  # Other outputs (Plot 2.1, Plot 2.3, etc.)
  output$plot_2_1 <- renderPlot({ plot_2_1 })
  output$plot_2_3 <- renderPlot({ plot_2_3 })
  output$plot_2_4 <- renderPlot({ plot_2_4 })
  output$regression_plot_1 <- renderPlot({ regression_plot_1 })
  output$regression_plot_2 <- renderPlot({ regression_plot_2 })
  output$text_analysis_plot_1 <- renderPlot({ text_analysis_plot_1 })
  output$text_analysis_plot_2 <- renderPlot({ text_analysis_plot_2 })
}

# Run the application 
shinyApp(ui = ui, server = server)
