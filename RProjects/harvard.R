library(dslabs)
library(tidyverse)

data("murders")

murders %>%
  ggplot(aes(population, total, label = abb, color = region)) + 
  geom_label()


a <- 2
b <- -1
c <- -4

(-b + sqrt(b^2 - 4*a*c)) / (2 * a)
(-b - sqrt(b^2 - 4*a*c)) / (2 * a)

head(murders)

class(murders$region)

data("movielens")

dim(movielens)

nlevels(movielens$genres)
