##Regression Model

# Remove rows with NA in GDP, Debt, and Revenue & pandemic years (2020-2021) as dummy variable for time fixed effects
cleaned_data <- merged_data %>%
  drop_na(GDP, Debt, Revenue)

cleaned_data$pandemic_year <- ifelse(cleaned_data$Year %in% c(2020, 2021), 1, 0)



# Fit the linear model of Debt on GDP

library(plm)

lm_model <- plm(Debt ~ GDP + GDP_Per_Capita, 
                data = cleaned_data, 
                index = c("Country_Name", "Year"), 
                effect = "twoways", # Including both country and time fixed effects
                model = "within") # "within" transformation to remove fixed effects

#  pandemic_year is perfectly collinear with time fixed effect (thus its coefficient is zero), so it's not included in the equation due to redundancy.


# Extract the coefficient and p-value for GDP to display on the plot
model_summary <- summary(lm_model)
coef_GDP <- coef(model_summary)[1, 1]  # Coefficient for GDP
p_value_GDP <- coef(model_summary)[1, 4]  # P-value for GDP

print(model_summary)

# Create formatted text to display on the plot
regression_text <- paste("GDP Coef: ", round(coef_GDP, 4), "\n", 
                         "p-value: ", round(p_value_GDP, 4), sep = "")



# Fit the linear model of Debt on Revenue
lm_model_2 <- plm(Debt ~ Revenue + GDP_Per_Capita, 
                  data = cleaned_data, 
                  index = c("Country_Name", "Year"), 
                  effect = "twoways", # Including both country and time fixed effects
                  model = "within") # "within" transformation to remove fixed effects

# Extract coefficient and p-value from the model to display on the plot
model_summary <- summary(lm_model)
model_summary_2 <- summary(lm_model_2)
coef_value_2 <- coef(model_summary_2)[1, 1]  # Coefficient for Revenue
p_value_2 <- coef(model_summary_2)[1, 4]    # P-value for Revenue

print(model_summary_2)

# Create a formatted text to display on the plot
regression_text_2 <- paste("Revenue Coef: ", round(coef_value_2, 4),
                           "\n", "p-value: ", round(p_value_2, 4), sep = "")



