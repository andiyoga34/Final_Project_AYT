library(pdftools)
library(tidytext)
library(udpipe)
library(tidyverse)



# Loading the World Bank's Global Economic Prospect Report released in January 2023 for text analysis
# The report has been downloaded beforehand into the working folder. Note that since the document is sizeable, 
# it really takes time (probably one to two minutes or more) to process to parsed_text


pdf_file <- "/Users/Lenovo/Documents/GitHub/DAP2-final-project-andiyoga34/Data/Raw Files/GEP-January-2023.pdf"

wb_report <- pdf_text(pdf_file)

parsed_text <- udpipe(wb_report, "english")
View(parsed_text)

parsed_text %>%
  filter(!upos  %in% c("PUNCT", "CCONJ")) %>%
  anti_join(stop_words, by = c("lemma" = "word")) %>%
  group_by(lemma) %>%
  count(sort = TRUE)



##1. Topic Analysis##

# Define keywords for expansion and contraction
expansion_keywords <- c("growth", "expansion", "positive", "upward", "improvement")
contraction_keywords <- c("recession", "contraction", "decline", "negative", "downturn")

# Create a function to count keyword occurrences in the sentences
count_keywords <- function(sentence, keywords) {
  sum(sapply(keywords, function(keyword) grepl(keyword, sentence, ignore.case = TRUE)))
}

# Apply the counting function to `parsed_text$sentence` to count keywords

parsed_text$expansion_count <- map_dbl(parsed_text$sentence, count_keywords, keywords = expansion_keywords)
parsed_text$contraction_count <- map_dbl(parsed_text$sentence, count_keywords, keywords = contraction_keywords)


# Summarize the counts by sentiment and region
topic_counts <- parsed_text %>%
  summarise(
    expansion = sum(expansion_count),
    contraction = sum(contraction_count)
  )

print(topic_counts)

# Prepare data for plotting
topic_data <- data.frame(
  topic = c("Expansion", "Contraction"),
  count = c(topic_counts$expansion, topic_counts$contraction)
)




## 2. Sentiment Intensity Analysis
# Load the AFINN sentiment lexicon
afinn <- get_sentiments("afinn")


# Filter sentences containing "EMDE" or "advanced economies"
parsed_text$region <- ifelse(
  str_detect(parsed_text$sentence, "EMDE|advanced economies"),
  ifelse(str_detect(parsed_text$sentence, "EMDE"), "EMDE", "Advanced Economies"),
  NA
)

# Remove rows where the region is NA (those that don't contain "EMDE" or "advanced economies")
region_sentences <- parsed_text %>%
  filter(!is.na(region))


# Join the parsed text with AFINN lexicon using 'lemma' (or 'word') from parsed_text and 'word' from AFINN
sentiment_scores <- region_sentences %>%
  inner_join(afinn, by = c("lemma" = "word")) %>%
  group_by(region, sentence) %>%
  summarise(sentiment = sum(value))  # Summing the sentiment scores for each sentence

# Check the sentiment scores
head(sentiment_scores)

# Classify sentiment as positive or negative based on the summed sentiment score
sentiment_summary <- sentiment_scores %>%
  mutate(sentiment_type = ifelse(sentiment > 0, "Positive", "Negative")) %>%
  group_by(region, sentiment_type) %>%
  summarise(intensity = sum(sentiment))  # Summing the intensities for each sentiment type

# Check the summarized sentiment data
print(sentiment_summary)


