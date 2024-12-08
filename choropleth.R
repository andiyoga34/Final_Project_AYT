
library(plotly)
library(sf)
library(rnaturalearth)


imf_data <- read_excel("/Users/Lenovo/Documents/GitHub/DAP2-final-project-andiyoga34/Inputs/Raw Files/Annual Growth_IMF.xls")

imf_data <- imf_data %>%
  rename(Country = 1)  # Renaming the first column to 'Country'


# Pivot the data from wide to long format
imf_data_long <- imf_data %>%
  pivot_longer(cols = starts_with("20"),  # Select all columns starting with '20'
               names_to = "Year",         # New column for years
               values_to = "Growth") |> # New column for the growth rates 
  select(Country, Year, Growth) |>
  drop_na()

imf_data_2020 <- imf_data_long %>%
  filter(Year == 2020)

# Load world map data (using rnaturalearth package)

world <- ne_countries(scale = "medium", returnclass = "sf")

# Merge the filtered IMF data with the world map data based on country name
world_data <- world %>%
  left_join(imf_data_2020, by = c("name_long" = "Country"))


# Convert Growth to numeric
world_data$Growth <- as.numeric(world_data$Growth)



# Check for missing data
missing_countries <- world_data %>%
  filter(is.na(Growth)) %>%
  select(name, Growth)
print(missing_countries)
