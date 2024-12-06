setwd("~/2025 Fall Quarter/R2/Final Project/")

# Load required libraries

library(tidyverse)
library(ggplot2)


# Downloading GDP Per Capita dataset from Wolrd Bank web into designated folder and the ZIP file name
zip_file <- "/Users/Lenovo/Documents/2025 Fall Quarter/R2/Final Project/worldbank_gdp_per_capita.zip"

# Check if the ZIP file already exists before downloading
if (!file.exists(zip_file)) {
  # If the ZIP file doesn't exist, download it
  url <- "https://api.worldbank.org/v2/en/indicator/NY.GDP.PCAP.CD?downloadformat=csv"
  download.file(url, zip_file, mode = "wb")
  print("Dataset downloaded.")
} else {
  print("Dataset already downloaded. Skipping download.")
}

# Unzip the ZIP file
unzip(zip_file, exdir = "/Users/Lenovo/Documents/2025 Fall Quarter/R2/Final Project/")



# Function to load, clean, rename, and reshape data
load_and_reshape <- function(file_path, value_name, years = 2015:2023) {
  read.csv(file_path, skip = 4) %>%
    rename(Country_Name = Country.Name, Country_Code = Country.Code) %>%  # Rename columns
    select(Country_Name, Country_Code, paste0("X", years)) %>%
    pivot_longer(
      cols = starts_with("X"),
      names_to = "Year",
      values_to = value_name
    ) %>%
    mutate(Year = as.numeric(sub("X", "", Year)))
}

# Load and reshape datasets with renamed columns
debt_long <- load_and_reshape("Debt.csv", "Debt", 2015:2022)
gdp_long <- load_and_reshape("GDP.csv", "GDP", 2015:2023)
gdp_per_capita_long <- load_and_reshape("API_NY.GDP.PCAP.CD_DS2_en_csv_v2_142.csv", "GDP_Per_Capita")
revenue_long <- load_and_reshape("Revenue.csv", "Revenue", 2015:2023)

# Merge datasets after removing NAs
merged_data <- reduce(
  list(debt_long, gdp_long, gdp_per_capita_long, revenue_long),
  ~ left_join(.x, .y, by = c("Country_Name", "Country_Code", "Year"))
) %>%
  drop_na(Country_Name, Country_Code)  # Handle NAs early

# Add category based on GDP per capita
merged_data <- merged_data %>%
  mutate(Category = case_when(
    Country_Name == "World" ~ "World",
    GDP_Per_Capita >= 12000 ~ "Developed",
    GDP_Per_Capita < 12000 ~ "Developing",
    TRUE ~ NA_character_
  ))

# Adjust GDP to billions
merged_data <- merged_data %>%
  mutate(GDP = GDP / 1e9)

# Function to summarize data
summarize_metric <- function(data, metric, start_year, end_year, agg_fn = mean) {
  data %>%
    filter(Year >= start_year & Year <= end_year) %>%
    group_by(Year, Category) %>%
    summarize(
      !!metric := agg_fn(.data[[metric]], na.rm = TRUE),
      .groups = "drop"
    ) %>%
    drop_na()
}

# Summarize datasets
debt_summary <- summarize_metric(merged_data, "Debt", 2015, 2022)
gdp_summary <- summarize_metric(merged_data, "GDP", 2015, 2023, sum)
revenue_summary <- summarize_metric(merged_data, "Revenue", 2015, 2022)

# Function to create line plots
create_line_plot <- function(data, y_var, y_label, title, colors = c("red", "blue", "green", "black")) {
  ggplot(data, aes(x = Year, y = !!sym(y_var), color = Category)) +
    geom_line(size = 1) +
    scale_color_manual(values = colors) +
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


