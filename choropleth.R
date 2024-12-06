
library(plotly)
library(sf)
library(rnaturalearth)


imf_data <- read_excel("~/2025 Fall Quarter/R2/Final Project/Annual Growth_IMF.xls")

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


# Convert Growth to numeric (if it's not already)
world_data$Growth <- as.numeric(world_data$Growth)

# Plotting the choropleth map using add_sf() 
# Create choropleth map using plot_ly()

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
      font = list(size = 20)  # Adjust title font size if needed
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



# Check for missing data

missing_countries <- world_data %>%
  filter(is.na(Growth)) %>%
  select(name, Growth)
missing_countries
