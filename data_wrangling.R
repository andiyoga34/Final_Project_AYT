#setting your working directory (adjust to your own)
setwd("/Users/Lenovo/Documents/GitHub/DAP2-final-project-andiyoga34/Inputs/Raw Files/")

# Load required libraries

library(tidyverse)



# Downloading GDP Per Capita dataset from Wolrd Bank web into designated folder and the ZIP file name
zip_file <- "/Users/Lenovo/Documents/GitHub/DAP2-final-project-andiyoga34/Inputs/Raw Files/worldbank_gdp_per_capita.zip"

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
unzip(zip_file, exdir = "/Users/Lenovo/Documents/GitHub/DAP2-final-project-andiyoga34/Inputs/Raw Files/")



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
gdp_per_capita_long <- load_and_reshape("API_NY.GDP.PCAP.CD_DS2_en_csv_v2_77536.csv", "GDP_Per_Capita") #adjust the automatically retrieved file name accordingly
revenue_long <- load_and_reshape("Revenue.csv", "Revenue", 2015:2023)

# Merge datasets and removing NAs
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




