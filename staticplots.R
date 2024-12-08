
library(ggplot2)
library(scales)

### 1. Function to create line plots of GDP, Debt, and Revenue of World, Developed, and Developing countries (second tab of shiny dashboard)

create_line_plot <- function(data, y_var, y_label, title, colors = c("red", "blue", "green")) {
  ggplot(data, aes(x = Year, y = !!sym(y_var), color = Category)) +
    geom_line(size = 1) +
    scale_color_manual(values = colors) +
    scale_y_continuous(labels = label_number(scale = 1, big.mark = ",", accuracy = 1)) + # Adjust Y-axis labels
    labs(
      title = title,
      x = "Year",
      y = y_label
    ) +
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
}


# Generate plots
world_gdp_plot <- create_line_plot(gdp_summary, "GDP", "GDP (current US$, in Billion)", "GDP Data by Country Groups (2015-2023)")
world_debt_plot <- create_line_plot(debt_summary, "Debt", "Debt (% of GDP)", "Debt Data by Country Groups (2015-2022)")
world_revenue_plot <- create_line_plot(revenue_summary, "Revenue", "Revenue (% of GDP)", "Revenue Data by Country Groups (2015-2022)")

# Print plots
print(world_gdp_plot)
print(world_debt_plot)
print(world_revenue_plot)




### 2. Create choropleth of World Heat Map displaying countries' annual growth in 2020 (third tab of shiny dashboard)

world_heatmap <- plot_ly(world_data) %>%
  add_trace(
    type = 'choropleth',
    locations = ~iso_a3,  # Use ISO country codes for locations
    z = ~Growth,  # The data to be mapped (Growth values)
    colorscale = list(
      c(0, "purple"),  # Minimum value (-30) in purple
      c(0.6, "red"),  # Middle value close to 0 in red
      c(1, "yellow")  # Maximum value (5) in yellow
    ), 
    zmin = -30,  # Minimum value for scale
    zmax = 5,  # Maximum value for scale
    colorbar = list(title = "Growth"),  # Add color scale label
    hoverinfo = "location+z",  # Show country and growth value in the hover tooltip
    text = ~paste(name, "<br>", "Growth: ", round(Growth, 2))  # Hover text
  ) %>%
  layout(
    title = list(
      text = "<b>World Heat Map of Annual Growth in 2020 (Pandemic Year)</b>",  # Use HTML for bold text
      font = list(size = 14)  # Adjust title font size if needed
    ),
    geo = list(
      showframe = FALSE,
      showcoastlines = TRUE,
      projection = list(type = 'mercator')
    ),
    annotations = list(
      x = 0.95,  # Position in bottom-right
      y = -0.1,  # Position below the map
      text = "Source: IMF",
      showarrow = FALSE,
      xref = "paper",
      yref = "paper",
      font = list(size = 10)
    )
  )

print(world_heatmap)



### 3. Creating regression plots (fourth tab of shiny dashboard)

# Create the plot with regression line and text annotation for GDP
Debt_GDP_plot <- ggplot(cleaned_data, aes(x = GDP, y = Debt)) +
  geom_point() +
  geom_smooth(method = "lm", col = "red") +
  scale_y_continuous(labels = scales::comma) +  
  labs(title = "Linear Regression of Debt on GDP",
       x = "GDP (current US$, in Billion)",
       y = "Debt (% of GDP)") +
  theme(
    axis.text.x = element_text(size = 14, angle = 0, hjust = 0.5),  
    axis.title.x = element_text(size = 16, face = "bold"),  
    axis.text.y = element_text(size = 14, angle = 0, hjust = 0.5),
    axis.title.y = element_text(size = 16, face = "bold"),
    legend.title = element_blank(),  
    legend.text = element_text(size = 14),  
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5)  
  ) +
  # Add the regression coefficient and p-value for GDP as text annotation
  geom_text(aes(x = 0.2, y = max(cleaned_data$Debt) * 0.9, label = regression_text), 
            size = 5, hjust = 0, color = "black")

print(Debt_GDP_plot)


# Create the plot with regression line and text annotation for Revenue
Debt_Rev_plot <- ggplot(cleaned_data, aes(x = Revenue, y = Debt)) +
  geom_point() +
  geom_smooth(method = "lm", col = "red") +
  scale_y_continuous(labels = scales::comma) +  
  labs(title = "Linear Regression of Debt on Revenue",
       x = "Revenue (% of GDP)",
       y = "Debt (% of GDP)") +
  theme(
    axis.text.x = element_text(size = 14, angle = 0, hjust = 0.5),  
    axis.title.x = element_text(size = 16, face = "bold"),  
    axis.text.y = element_text(size = 14, angle = 0, hjust = 0.5),
    axis.title.y = element_text(size = 16, face = "bold"),
    legend.title = element_blank(),  
    legend.text = element_text(size = 14),  
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5)  
  ) +
  # Add regression coefficient and p-value as text annotation
  geom_text(aes(x = 0.2, y = max(cleaned_data$Debt) *0.9, label = regression_text_2), size = 5, hjust = 0, color = "black")

print(Debt_Rev_plot)



### 4. Creating text analysis plots (fifth tab of shiny dashboard)

# Plot bar chart for topic analysis
text_plot_1 <- ggplot(topic_data, aes(x = topic, y = count, fill = topic)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(
    title = "Topic Analysis: Expansion vs. Contraction",  
    x = "Topic",  
    y = "Count"  
  ) +
  scale_fill_manual(values = c("Expansion" = "turquoise", "Contraction" = "salmon")) +  
  theme_minimal() +
  theme(
    axis.text.x = element_text(size = 14), 
    axis.title.x = element_text(size = 16, face = "bold"),  
    axis.text.y = element_text(size = 14),
    axis.title.y = element_text(size = 16, face = "bold"),  
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5),  
    legend.position = "none"  
  )

print(text_plot_1)


# Create a bar plot showing sentiment intensity by region and sentiment type
text_plot_2 <- ggplot(sentiment_summary, aes(x = region, y = intensity, fill = sentiment_type)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(
    title = "Sentiment Intensity Analysis by Region (Developed vs Developing Economies)",
    x = "Region", y = "Sentiment Intensity"
  ) +
  scale_fill_manual(values = c("Positive" = "turquoise", "Negative" = "salmon")) +
  scale_x_discrete(labels = c("EMDE" = "Developing Economies", "Advanced Economies" = "Developed Economies")) +  # Change x-axis labels
  theme_minimal() +
  theme(
    axis.text.x = element_text(size = 14, angle = 0, hjust = 0.5),  
    axis.title.x = element_text(size = 16, face = "bold"),  
    axis.text.y = element_text(size = 14, angle = 0, hjust = 0.5),
    axis.title.y = element_text(size = 16, face = "bold"),
    legend.title = element_blank(),  
    legend.text = element_text(size = 14),  
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5)  
  ) 

print(text_plot_2)



#set directory to save all the static plots (adjust it to your own)
setwd("/Users/Lenovo/Documents/GitHub/DAP2-final-project-andiyoga34/Images/")

ggsave(filename = 'world_gdp_plot.png', plot = world_gdp_plot, units = 'in', width = 5, height = 4, device='png', dpi=700)
ggsave(filename = 'world_debt_plot.png', plot = world_debt_plot, units = 'in', width = 5, height = 4, device='png', dpi=700)
ggsave(filename = 'world_revenue_plot.png', plot = world_revenue_plot, units = 'in', width = 5, height = 4, device='png', dpi=700)
ggsave(filename = 'regression_plot_1.png', plot = Debt_GDP_plot, units = 'in', width = 5, height = 4, device='png', dpi=700)
ggsave(filename = 'regression_plot_2.png', plot = Debt_Rev_plot, units = 'in', width = 5, height = 4, device='png', dpi=700)
ggsave(filename = 'text_plot_1.png', plot = text_plot_1, units = 'in', width = 5, height = 4, device='png', dpi=700)
ggsave(filename = 'text_plot_2.png', plot = text_plot_2, units = 'in', width = 5, height = 4, device='png', dpi=700)

