##Regression Model

# Remove rows with NA in GDP, Debt, and Revenue & pandemic years (2020-2021) as dummy variable for time fixed effects
cleaned_data <- merged_data %>%
  drop_na(GDP, Debt, Revenue)

cleaned_data$pandemic_year <- ifelse(cleaned_data$Year %in% c(2020, 2021), 1, 0)



# Fit the linear model of Debt on GDP

library(plm)

lm_model <- plm(Debt ~ GDP + GDP_Per_Capita, 
                data = cleaned_data, 
                index = c("Country.Name", "Year"), 
                effect = "twoways", # Including both country and time fixed effects
                model = "within") # "within" transformation to remove fixed effects

#  pandemic_year is perfectly collinear with time fixed effect (thus its coefficient is zero), so it's not included in the equation due to redundancy.


# Extract the coefficient and p-value for GDP
model_summary <- summary(lm_model)
coef_GDP <- coef(model_summary)[1, 1]  # Coefficient for GDP
p_value_GDP <- coef(model_summary)[1, 4]  # P-value for GDP

print(model_summary)

# Create formatted text for GDP coefficient and p-value
regression_text <- paste("GDP Coef: ", round(coef_GDP, 4), "\n", 
                         "p-value: ", round(p_value_GDP, 4), sep = "")

# Create the plot with regression line and text annotation for GDP
Debt_GDP_plot <- ggplot(cleaned_data, aes(x = GDP, y = Debt)) +
  geom_point() +
  geom_smooth(method = "lm", col = "red") +
  scale_y_continuous(labels = scales::comma) +  # Use comma formatting for y-axis
  labs(title = "Linear Regression of Debt on GDP",
       x = "GDP (current US$, in Billion)",
       y = "Debt (% of GDP)") +
  theme(
    axis.text.x = element_text(size = 14, angle = 0, hjust = 0.5),  # Center labels horizontally (hjust = 0.5 centers them)
    axis.title.x = element_text(size = 16, face = "bold"),  # Make x-axis title bold
    axis.text.y = element_text(size = 14, angle = 0, hjust = 0.5),
    axis.title.y = element_text(size = 16, face = "bold"),
    legend.title = element_blank(),  # Remove the legend title
    legend.text = element_text(size = 14),  # Increase the size of the legend labels
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5)  # Increase and bold the title
  ) +
  # Add the regression coefficient and p-value for GDP as text annotation
  geom_text(aes(x = 0.2, y = max(cleaned_data$Debt) * 0.9, label = regression_text), 
            size = 5, hjust = 0, color = "black")

# Show the plot
print(Debt_GDP_plot)





# Fit the linear model of Debt on Revenue
lm_model_2 <- plm(Debt ~ Revenue + GDP_Per_Capita, 
                  data = cleaned_data, 
                  index = c("Country.Name", "Year"), 
                  effect = "twoways", # Including both country and time fixed effects
                  model = "within") # "within" transformation to remove fixed effects

# Extract coefficient and p-value from the model
model_summary_2 <- summary(lm_model_2)
coef_value_2 <- coef(model_summary_2)[1, 1]  # Coefficient for Revenue
p_value_2 <- coef(model_summary_2)[1, 4]    # P-value for Revenue

print(model_summary_2)

# Create a formatted text to display on the plot
regression_text_2 <- paste("Revenue Coef: ", round(coef_value_2, 4),
                           "\n", "p-value: ", round(p_value_2, 4), sep = "")

# Create the plot
Debt_Rev_plot <- ggplot(cleaned_data, aes(x = Revenue, y = Debt)) +
  geom_point() +
  geom_smooth(method = "lm", col = "red") +
  scale_y_continuous(labels = scales::comma) +  # Use comma formatting for y-axis
  labs(title = "Linear Regression of Debt on Revenue",
       x = "Revenue (% of GDP)",
       y = "Debt (% of GDP)") +
  theme(
    axis.text.x = element_text(size = 14, angle = 0, hjust = 0.5),  # Center labels horizontally (hjust = 0.5 centers them)
    axis.title.x = element_text(size = 16, face = "bold"),  # Make x-axis title bold
    axis.text.y = element_text(size = 14, angle = 0, hjust = 0.5),
    axis.title.y = element_text(size = 16, face = "bold"),
    legend.title = element_blank(),  # Remove the legend title
    legend.text = element_text(size = 14),  # Increase the size of the legend labels
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5)  # Increase and bold the title# Make y-axis title bold
  ) +
  # Add regression coefficient and p-value as text annotation
  geom_text(aes(x = 0.2, y = max(cleaned_data$Debt) *0.9, label = regression_text_2), size = 5, hjust = 0, color = "black")

# Print the plot
print(Debt_Rev_plot)

