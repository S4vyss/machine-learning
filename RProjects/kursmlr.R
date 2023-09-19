library(tidyverse)
library(data.table)
library(readr)
library(mlr3)

winequality_red <- read.csv("wine+quality/winequality-red.csv", sep=';')
winequality_white <- read.csv("wine+quality/winequality-white.csv", sep=';')

winequality_red$type <- 'red'
winequality_white$type <- 'white'

properties <- bind_rows(winequality_red, winequality_white)

mlr::summarizeColumns(properties)

wine <- filter(properties, type == 'red')
high_quality_wines <- filter(properties, type == 'red' & quality > 7)
extreme_cases <- filter(properties, quality < 5 | quality > 9)

wine <- select(wine, -type)
wine <- mutate(wine, quality = as.numeric(quality))

properties <- mutate_if(properties, is.numeric, function(x) ifelse(is.na(x), mean(x), x))

properties %>%
  group_by(type) %>%
  summarise(ile_obserwacji = n(),
            srednia_jakos = mean(quality))

wine_stats <- properties %>%
  group_by(type) %>%
  summarise_all(c('mean', 'max', 'min', 'length'))
wine_stats

wine_gathered <- gather(wine, 'property', 'value', -quality)
ggplot(wine_gathered, aes(x = property, y = value)) +
  geom_boxplot() +
  facet_wrap(~property, scales = 'free') +
  theme_bw()

spread(wine_gathered, key = 'property', value = 'value')

properties <- as.data.table(properties)
properties[, high_quality := quality > 7]
properties[, .(mean_quality = mean(as.numeric(quality))), type]
properties[quality > 7, .N, type]

wine <- normalizeFeatures(wine, target = "quality")

mlr::summarizeColumns(wine)

wine$quality <- as.numeric(wine$quality)