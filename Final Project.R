setwd("~/2025 Fall Quarter/R2/Final Project/")

# Load required libraries
library(tidyr)
library(dplyr)
library(ggplot2)

# Load the data
debt_data <- read.csv("Debt.csv", skip = 4)
gdp_data <- read.csv("GDP.csv", skip = 4)
gdp_per_capita_data <- read.csv("GDP_Per_Capita.csv", skip = 4)
revenue_data <- read.csv("Revenue.csv", skip = 4)

# Select relevant years (2015-2023 for GDP and Revenue, 2015-2022 for Debt) - Correct column names
years <- paste0("X", 2015:2023) # Prefix years with 'X'
debt_data <- debt_data[, c("Country.Name", "Country.Code", years)]
gdp_data <- gdp_data[, c("Country.Name", "Country.Code", years)]
gdp_per_capita_data <- gdp_per_capita_data[, c("Country.Name", "Country.Code", years)]
revenue_data <- revenue_data[, c("Country.Name", "Country.Code", years)]

# Reshape datasets to long format
debt_long <- pivot_longer(debt_data, cols = all_of(years), 
                          names_to = "Year", values_to = "Debt")
gdp_long <- pivot_longer(gdp_data, cols = all_of(years), 
                         names_to = "Year", values_to = "GDP")
gdp_per_capita_long <- pivot_longer(gdp_per_capita_data, cols = all_of(years), 
                                    names_to = "Year", values_to = "GDP_per_Capita")
revenue_long <- pivot_longer(revenue_data, cols = all_of(years), 
                             names_to = "Year", values_to = "Revenue")

# Remove the 'X' prefix from Year and convert to numeric
debt_long$Year <- as.numeric(sub("X", "", debt_long$Year))
gdp_long$Year <- as.numeric(sub("X", "", gdp_long$Year))
gdp_per_capita_long$Year <- as.numeric(sub("X", "", gdp_per_capita_long$Year))
revenue_long$Year <- as.numeric(sub("X", "", revenue_long$Year))

# Merge datasets
merged_data <- merge(debt_long, gdp_long, by = c("Country.Name", "Country.Code", "Year"), all = TRUE)
merged_data <- merge(merged_data, gdp_per_capita_long, by = c("Country.Name", "Country.Code", "Year"), all = TRUE)
merged_data <- merge(merged_data, revenue_long, by = c("Country.Name", "Country.Code", "Year"), all = TRUE)

# Add category based on GDP per Capita
merged_data <- merged_data |>
  mutate(Category = case_when(
    Country.Name == "World" ~ "World",
    GDP_per_Capita >= 12000 ~ "Developed",
    !is.na(GDP_per_Capita) & GDP_per_Capita < 12000 ~ "Developing",
    TRUE ~ NA_character_
  )) 

# Making the nominal GDP in Billion US Dollars to make an easier read
merged_data <- merged_data |> mutate (GDP = GDP / 1e9)


write.csv(merged_data, "merged_data.csv", row.names = FALSE)

# Summarize Debt by average
debt_summary <- merged_data %>%
  filter(Year >= 2015 & Year <= 2022) %>%
  group_by(Year, Category) %>%
  summarize(Debt = mean(Debt, na.rm = TRUE), .groups = "drop") |> 
  drop_na()

# Summarize GDP by sum
gdp_summary <- merged_data %>%
  filter(Year >= 2015 & Year <= 2023) %>%
  group_by(Year, Category) %>%
  summarize(GDP = sum(GDP, na.rm = TRUE), .groups = "drop") |> 
  drop_na()

# Summarize Revenue by average
Revenue_summary <- merged_data %>%
  filter(Year >= 2015 & Year <= 2022) %>%
  group_by(Year, Category) %>%
  summarize(Revenue = mean(Revenue, na.rm = TRUE), .groups = "drop") |> 
  drop_na()

# Plot corrected GDP data
ggplot(gdp_summary, aes(x = Year, y = GDP, color = Category)) +
  geom_line(size = 1) +
  scale_color_manual(values = c("red", "blue", "green", "black")) + 
  scale_y_continuous(labels = scales::comma) +  # Use comma formatting for y-axis
  labs(title = "GDP Data by Country Groups  (2015-2023) ",
       x = "Year", y = "GDP (current US$, in Billion)") +
  theme_minimal() +
  theme(legend.title = element_blank())

# Plot Debt data
ggplot(debt_summary, aes(x = Year, y = Debt, color = Category)) +
  geom_line(size = 1) +
  scale_color_manual(values = c("red", "blue", "green", "black")) + # Red for World, Blue for Developed, Green for Developing
  labs(title = "Debt Data (2015-2022) by Country Groups",
       x = "Year", y = "Debt (% of GDP)") +
  theme_minimal() +
  theme(legend.title = element_blank())

# Plot Revenue data
ggplot(Revenue_summary, aes(x = Year, y = Revenue, color = Category)) +
  geom_line(size = 1) +
  scale_color_manual(values = c("red", "blue", "green", "black")) + # Red for World, Blue for Developed, Green for Developing
  labs(title = "Revenue Data (2015-2022) by Country Groups",
       x = "Year", y = "Revenue (% of GDP)") +
  theme_minimal() +
  theme(legend.title = element_blank())






# Remove rows with NA in GDP, Debt, and Revenue
cleaned_data <- merged_data[!is.na(merged_data$GDP) & !is.na(merged_data$Debt) & !is.na(merged_data$Debt), ]

write.csv(cleaned_data, "cleaned_data.csv", row.names = FALSE)

# Perform a Pearson correlation test
correlation <- cor.test(cleaned_data$GDP, cleaned_data$Debt, method = "pearson")
print(correlation)

# Fit a linear regression model
reg_debt_GDP <- lm(Debt ~ GDP, data = cleaned_data)
summary(reg_debt_GDP)

reg_debt_revenue <- lm(Debt ~ Revenue, data = cleaned_data)
summary(reg_debt_revenue )

# Plot the regression line

Debt_GDP_plot <- ggplot(cleaned_data, aes(x = GDP, y = Debt)) +
  geom_point() +
  geom_smooth(method = "lm", col = "red") +
  scale_y_continuous(labels = scales::comma) +  # Use comma formatting for y-axis
  labs(title = "Linear Regression of Debt vs GDP",
       x = "GDP (current US$, in Billion)",
       y = "Debt (% of GDP)") +
  theme_minimal()

print(Debt_GDP_plot)

# Plot the regression line

Debt_Rev_plot <- ggplot(cleaned_data, aes(x = Revenue, y = Debt)) +
  geom_point() +
  geom_smooth(method = "lm", col = "red") +
  scale_y_continuous(labels = scales::comma) +  # Use comma formatting for y-axis
  labs(title = "Linear Regression of Debt vs Revenue",
       x = "Revenue (% of GDP)",
       y = "Debt (% of GDP)") +
  theme_minimal()

print(Debt_Rev_plot)


library(ggplot2)
library(broom)  # For tidy model results

# Fit the linear model
lm_model <- lm(Debt ~ GDP, data = cleaned_data)

# Extract coefficient and p-value from the model
model_summary <- summary(lm_model)
coef_value <- coef(model_summary)[2, 1]  # Coefficient for Revenue
p_value <- coef(model_summary)[2, 4]    # P-value for Revenue

# Create a formatted text to display on the plot
regression_text <- paste("Coef: ", round(coef_value, 4), "\n", "p-value: ", round(p_value, 4), sep = "")

# Create the plot
Debt_GDP_plot <- ggplot(cleaned_data, aes(x = GDP, y = Debt)) +
  geom_point() +
  geom_smooth(method = "lm", col = "red") +
  scale_y_continuous(labels = scales::comma) +  # Use comma formatting for y-axis
  labs(title = "Linear Regression of Debt vs GDP",
       x = "GDP (current US$, in Billion)",
       y = "Debt (% of GDP)") +
  theme_minimal() +
  # Add regression coefficient and p-value as text annotation
  geom_text(aes(x = 0.2, y = max(cleaned_data$Debt) *0.95, label = regression_text), size = 3, hjust = 0, color = "black")

# Print the plot
print(Debt_GDP_plot)


# Fit the linear model
lm_model_2 <- lm(Debt ~ Revenue, data = cleaned_data)

# Extract coefficient and p-value from the model
model_summary_2 <- summary(lm_model_2)
coef_value_2 <- coef(model_summary_2)[2, 1]  # Coefficient for Revenue
p_value_2 <- coef(model_summary_2)[2, 4]    # P-value for Revenue

# Create a formatted text to display on the plot
regression_text_2 <- paste("Coef: ", round(coef_value_2, 4), "\n", "p-value: ", round(p_value_2, 4), sep = "")

# Create the plot
Debt_Rev_plot <- ggplot(cleaned_data, aes(x = Revenue, y = Debt)) +
  geom_point() +
  geom_smooth(method = "lm", col = "red") +
  scale_y_continuous(labels = scales::comma) +  # Use comma formatting for y-axis
  labs(title = "Linear Regression of Debt vs Revenue",
       x = "Revenue (% of GDP)",
       y = "Debt (% of GDP)") +
  theme_minimal() +
  # Add regression coefficient and p-value as text annotation
  geom_text(aes(x = 0.2, y = max(cleaned_data$Debt) *0.9, label = regression_text), size = 3, hjust = 0, color = "black")

# Print the plot
print(Debt_Rev_plot)

