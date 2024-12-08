
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
      menuItem("World & Region Charts", tabName = "charts", icon = icon("chart-bar")),
      menuItem("World Heat Map", tabName = "heatmap", icon = icon("globe-africa")),  # New tab for World Heat Map
      menuItem("Regressions", tabName = "regressions", icon = icon("chart-line")),
      menuItem("Text Analysis", tabName = "text_analysis", icon = icon("font"))
    )
  ),
  dashboardBody(
    tabItems(
      # First tab: User selects country data and displays line chart
      tabItem(tabName = "country_data",
              fluidRow(
                box(title = "Select Country for Revenue & Debt Plot", width = 4, solidHeader = TRUE, status = "primary",
                    selectInput("country_revenue_debt", "Select Country:", choices = unique(merged_data$Country_Name))),
                box(title = "Revenue and Debt Plot", width = 8, solidHeader = TRUE, status = "primary",
                    plotOutput("revenue_debt_plot"))
              ),
              fluidRow(
                box(title = "Select Country for GDP Plot", width = 4, solidHeader = TRUE, status = "primary",
                    selectInput("country_gdp", "Select Country:", choices = unique(merged_data$Country_Name))),
                box(title = "GDP Plot", width = 8, solidHeader = TRUE, status = "primary",
                    plotOutput("gdp_plot"))
              )
      ),
      
      # Second tab: Display 3 plots (Plot 2.1, Plot 2.3, Plot 2.4)
      tabItem(tabName = "charts",
              box(title = "World's GDP Trajectory", width = 12, solidHeader = TRUE, status = "primary",
                  plotOutput("world_gdp_plot")),
              box(title = "World's Debt Trajectory", width = 12, solidHeader = TRUE, status = "primary",
                  plotOutput("world_debt_plot")),
              box(title = "World's Revenue Trajectory", width = 12, solidHeader = TRUE, status = "primary",
                  plotOutput("world_revenue_plot"))
      ),
      
      # Third tab: World Heat Map
      tabItem(tabName = "heatmap",
              box(title = "World Heat Map", width = 12, solidHeader = TRUE, status = "primary",
                  plotlyOutput("world_heatmap"))  
      ),
      
      # Fourth tab: Display regression plots
      tabItem(tabName = "regressions",
              box(title = "Regression: Debt ~ GDP", width = 12, solidHeader = TRUE, status = "primary",
                  plotOutput("regression_plot_1")),
              box(title = "Regression: Debt ~ Revenue", width = 12, solidHeader = TRUE, status = "primary",
                  plotOutput("regression_plot_2"))
      ),
      
      # Fifth tab: Display text analysis plots
      tabItem(tabName = "text_analysis",
              box(title = "Text Analysis I: Topic", width = 12, solidHeader = TRUE, status = "primary",
                  plotOutput("text_analysis_plot_1")),
              box(title = "Text Analysis II: Sentiment Intensity", width = 12, solidHeader = TRUE, status = "primary",
                  plotOutput("text_analysis_plot_2"))
      )
    )
  )
)

# Define server logic
server <- function(input, output) {
  # First Plot: Revenue and Debt for the selected country
  output$revenue_debt_plot <- renderPlot({
    req(input$country_revenue_debt)
    country_data <- merged_data %>% filter(Country_Name == input$country_revenue_debt)
    if (nrow(country_data) == 0) return(NULL)
    
    ggplot(country_data, aes(x = Year)) +
      geom_line(aes(y = Revenue, color = "Revenue"), size = 1.2) +
      geom_line(aes(y = Debt, color = "Debt"), size = 1.2) +
      labs(title = paste("Revenue and Debt for", input$country_revenue_debt),
           x = "Year", y = "In % of GDP", color = "Legend") +
      scale_color_manual(values = c("Revenue" = "green", "Debt" = "red")) +
      theme(
        axis.text.x = element_text(size = 14, angle = 0, hjust = 0.5),
        axis.title.x = element_text(size = 16, face = "bold"),
        axis.text.y = element_text(size = 14, angle = 0, hjust = 0.5),
        axis.title.y = element_text(size = 16, face = "bold"),
        legend.title = element_blank(),
        legend.text = element_text(size = 14),
        plot.title = element_text(size = 20, face = "bold", hjust = 0.5)
      ) + 
      geom_vline(xintercept = 2020, linetype = "dashed", color = "black", size = 1.0)
  })
  
  # Second Plot: GDP for the selected country
  output$gdp_plot <- renderPlot({
    req(input$country_gdp)
    country_data <- merged_data %>% filter(Country_Name == input$country_gdp)
    if (nrow(country_data) == 0) return(NULL)
    
    ggplot(country_data, aes(x = Year, y = GDP)) +
      geom_line(color = "blue", size = 1.2) +
      labs(title = paste("GDP for", input$country_gdp),
           x = "Year", y = "GDP (USD Billion)") +
      theme(
        axis.text.x = element_text(size = 14, angle = 0, hjust = 0.5),
        axis.title.x = element_text(size = 16, face = "bold"),
        axis.text.y = element_text(size = 14, angle = 0, hjust = 0.5),
        axis.title.y = element_text(size = 16, face = "bold"),
        legend.title = element_blank(),
        legend.text = element_text(size = 14),
        plot.title = element_text(size = 20, face = "bold", hjust = 0.5)
      ) + 
      geom_vline(xintercept = 2020, linetype = "dashed", color = "black", size = 1.0)
  })
  
 
  # Other outputs
  output$world_gdp_plot <- renderPlot({ world_gdp_plot })
  output$world_debt_plot <- renderPlot({ world_debt_plot })
  output$world_revenue_plot <- renderPlot({ world_revenue_plot })
  output$world_heatmap <- renderPlotly({ world_heatmap })
  output$regression_plot_1 <- renderPlot({ Debt_GDP_plot })
  output$regression_plot_2 <- renderPlot({ Debt_Rev_plot })
  output$text_analysis_plot_1 <- renderPlot({ text_plot_1 })
  output$text_analysis_plot_2 <- renderPlot({ text_plot_2 })
}

# Run the application
shinyApp(ui = ui, server = server)

