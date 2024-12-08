*SUMMARY OF THE CODE AND THE ORDER OF THE FILES*


*The files should be run as the following order*:
1. data_wrangling.R
2. models.R
3. texprocess.R
4. choropleth.R
5. staticplots.R
6. shinyapp.R


*Summary of the code*

A. Data_wrangling.R

Processing and merging four datasets (GDP, GDP Per Capita, Debt, and Revenue) into one dataset (merged_data).
GDP Per Capita is automatically retrieved via World Bank API while the other three datasets have been provided before in the Raw Files folder to be loaded.

1. Setting the Working Directory
Adjust the working directory path to your system configuration.

2. Load Required Libraries
Ensure the required libraries are installed and loaded.

3. Retrieve the GDP Per Capita Dataset

Source: World Bank API.
File Format: Compressed ZIP file.
Steps:
Check if the ZIP file already exists in the designated folder.
If not, retrieve the file using the provided URL.
Unzip the file into the working directory.

4. Data Cleaning and Reshaping
A custom function, load_and_reshape, is used to:
-Load CSV files.
-Rename and clean columns (Country_Name, Country_Code).
-Select data for specified years (e.g., 2015–2023).
-Transform data into a long format for easier analysis.

Example Datasets:
Debt Data (Debt.csv): Reshaped into debt_long.
GDP Data (GDP.csv): Reshaped into gdp_long.
GDP Per Capita Data: Reshaped into gdp_per_capita_long.
Revenue Data (Revenue.csv): Reshaped into revenue_long.

5. Merge and Clean Data
The cleaned datasets are merged into a single dataset (merged_data):

-Merging is based on Country_Name, Country_Code, and Year.
-Rows with missing values (NAs) are removed.

6. Add Categorization
Countries are categorized based on GDP Per Capita:

World: Aggregate data for all countries.
Developed: Countries with GDP Per Capita ≥ 12,000.
Developing: Countries with GDP Per Capita < 12,000.

7. Adjust GDP to Billions
GDP values are scaled to billions for easier interpretation.

8. Summarize Data
The summarize_metric function is used to calculate summaries:

-Aggregates data (e.g., mean or sum) by Year and Category.
-Filters data within specified years.
-Outputs clean summary datasets.

Summary Datasets:
-Debt Summary (debt_summary): Mean debt (2015–2022).
-GDP Summary (gdp_summary): Total GDP (2015–2023).
-Revenue Summary (revenue_summary): Mean revenue (2015–2022).



B. models.R

 Running the regression models, printing the summary, and extracting parts of the regression results (Coefficient and p-value for GDP are extracted and formatted for display).


1. Data Cleaning

Objective: Prepare the dataset for analysis by removing missing values and defining variables for fixed effects.

Steps:
-Rows with missing values in GDP, Debt, and Revenue are removed.
-A new variable, pandemic_year, is added to identify years 2020 and 2021 as a dummy variable (value of 1 for these years, 0 otherwise)


2.  First Linear Model: Debt on GDP
Objective: Fit a linear regression model to examine the relationship between Debt and GDP, controlling for GDP Per Capita as well as both country and time fixed effects.

Methodology:

-Panel Data Model: Fixed effects model using the plm package. [loade the plm package: library(plm)]
-Effects Included: Both country and time fixed effects (effect = "twoways").
-Fixed Effects Removal: Within transformation to eliminate fixed effects.

Key Observations:

The pandemic_year variable is perfectly collinear with time fixed effects and is excluded from the model due to redundancy.

Extracting Results:
Coefficient and p-value for GDP are extracted and formatted for display.


3.  Second Linear Model: Debt on Revenue

All of the explanations are the same with the first model above, except in this case is regressing Debt on Revenue.



C. choropleth.R

The code integrates IMF economic growth data with geospatial data (world_data) to create a world choropleth (visualization of in this case, countries' economic data in 2020, on a world map)

1. Load Required Libraries:

-plotly for interactive visualization.
-sf for handling spatial data.
-rnaturalearth for loading world map data.


2. Import and Prepare IMF Data:

-The IMF annual growth data is loaded from an Excel file that has been pre-downloaded in working folder.
-The first column is renamed to "Country".
-The data is pivoted to long format for easier analysis, with columns for Country, Year, and Growth.
-Rows with missing growth data are dropped.
-A subset for the year 2020 is extracted.


3. Load and Prepare World Map Data:

-World map data is loaded using the rnaturalearth package as a spatial object (sf).
-The map data is merged with the filtered IMF data (year 2020) using the country names as the key.


4. Clean and Validate the Data:

-The Growth column is converted to numeric for analysis or visualization.
-Missing growth data is identified by filtering merged data for rows with NA in the Growth column, and the names of the missing countries are printed for review.



D. textprocess.R

This code performs text analysis and sentiment analysis on the World Bank's Global Economic Prospects Report (January 2023) to extract insights about economic trends and regional sentiment.

Key Steps
1. Load Required Libraries
Ensure the required libraries are installed and loaded.

2. Text Parsing and Preprocessing
Input: A large PDF report from the World Bank is loaded.

Process:
-The report's text is extracted using the pdftools package.
-The text is parsed into structured data using udpipe for natural language processing (NLP), including part--of-speech tagging and lemmatization.
-Stopwords, punctuation, and conjunctions are removed.
-Keywords (lemmas) are counted for frequency analysis.

3. Topic Analysis
Objective: Analyze the occurrence of key economic terms related to expansion and contraction.

Process:
-Keywords for expansion (e.g., "growth", "positive") and contraction of economies (e.g., "recession", "negative") are defined.
-A custom function counts occurrences of these keywords in parsed sentences.
-Counts are summarized for the entire report to identify overall trends in expansion and contraction mentions.

Output: A dataset summarizing the counts for Expansion and Contraction topics.

4. Sentiment Intensity Analysis
Objective: Measure the sentiment intensity for different regions mentioned in the report.
Process:

-Sentences referring to EMDE (Emerging Market and Developing Economies) or Advanced Economies are identified and classified into regions.
-The AFINN sentiment lexicon is used to assign sentiment scores (positive or negative values) to the text based on lemmatized words.
-Sentiment scores are grouped by region and sentence, with intensities summed to determine overall sentiment.
-Sentiments are classified into Positive or Negative, with intensities aggregated for each region and sentiment type.

Output: A summary of sentiment intensity for EMDE (Developing) and Advanced (Developed) Economies.



E. staticplots.R

Creating all the static plots from the second through the fifth tab of the shiny dashboard.

Load Required Libraries
Ensure the required libraries are installed and loaded.

1. Function to create line plots of GDP, Debt, and Revenue of World, Developed, and Developing countries (second tab of shiny dashboard).
2. Create choropleth of World Heat Map displaying countries' annual GDP growth in 2020 (third tab of shiny dashboard).
3. Creating regression plots (fourth tab of shiny dashboard).
4. Creating text analysis plots (fifth tab of shiny dashboard).

Al the plots saved are with the formatting (i.e. labels' size of title, X axis, Y Axis, legend, etc) chosen to fit perfectly on the shiny dashboard, adjust the labels' size accordingly based on your needs!


F. shinyapp.R

Creating dashboard to display interactive graphs of individual country's debt, revenue, and GDP in the first tabs and all static plots mentioned above created by staticplots.R.



*VARIABLES DEFINITION*

All variables in X and Y axis in all plots are clear and self-explanatory from their axis labels.



*ORIGINAL DATA SOURCE*

Main Datasets
•	GDP: data.worldbank.org/indicator/NY.GDP.MKTP.CD 
•	GDP Per Capita: data.worldbank.org/indicator/NY.GDP.PCAP.CD (auto retrieved from API)
•	Debt: data.worldbank.org/indicator/GC.DOD.TOTL.GD.ZS
•	Revenue: data.worldbank.org/indicator/GC.REV.XGRT.GD.ZS
 
Text Analysis: World Bank’s Global Economic Prospect Report (January 2023)
https://openknowledge.worldbank.org/entities/publication/59695a57-f323-5fa8-8c6f-d58bfa8918cd/full
 
Choropleth using IMF Data and World geospatial data:
- IMF Data (choose All Country Data, excel file): https://www.imf.org/external/datamapper/NGDP_RPCH@WEO/OEMDC/ADVEC/WEOWORLD
- World Geospatial Data: library(rnaturalearth)


*VERSION OF R USED*
2024.9.0.0



*DATA CREATED/MODIFIED*


1. data_wrangling.R: Created on November 30, 2024, last modified on December 7, 20:30 
2. models.R: Created on November 30, 2024, last modified on December 7, 20:30 
3. texprocess.R: Created on November 30, 2024, last modified on December 7, 20:30 
4. choropleth.R: Created on December 5, 2024, last modified on December 7, 20:30 
5. staticplots.R: Created on November 30, 2024, last modified on December 7, 20:30 
6. shinyapp.R: Created on November 30, 2024, last modified on December 7, 20:30 



*REQUIRED PACKAGES*

1. tidyverse
2. plm
3. pdftools
4. tidytext
5. udpipe
6. tidyverse
7. plotly
8. sf
9. rnaturalearth
10. ggplot2
11. scales
12.shiny
13.shinydashboard


*Final, Clean Data*
Two final datasets are stored in directory: /Users/Lenovo/Documents/GitHub/DAP2-final-project-andiyoga34/Data/Final, clean data

merged_data is the merged dataset as output from data_wrangling (1752 rows). This is used as a base for plots on the first and second tab of shiny dashboard.

clean_data is the merge_data with the NAs cleaning of Debt, Revenue, and GDP columns for regression purpose (605 rows; so many NAs in debt data).

