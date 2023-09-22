library(tidyverse)
library(data.table)
library(readr)
library(mlr)

winequality_red <- read.csv("C:/DataScience/kursmlr/wine+quality/winequality-red.csv", sep = ';')
winequality_white <- read.csv("C:/DataScience/kursmlr/wine+quality/winequality-white.csv", sep=';')

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

wine_task <- makeRegrTask(id = 'wine', data = wine, target = 'quality', fixup.data = 'no', check.data = FALSE)

head(getTaskData(wine_task))

wine_subset <- subsetTask(wine_task, wine$quality > 7, c('alcohol', 'sulphates'))

tibble::as.tibble(mlr::listLearners(obj = 'regr'))

rf_model <- train('regr.randomForest', wine_task)

unwraped_model <- getLearnerModel(rf_model)

wine_lm <- lm(quality ~., data = wine)
summary(wine_lm)

library(party)
wine_tree <- ctree(quality ~., data = wine)
plot(wine_tree)

library(randomForest)
wine_rf <- randomForest(quality ~., data = wine)

fitted <- predict(rf_model, wine_task)
fitted

performance(fitted)

mean((fitted[['data']]$response - fitted[['data']]$truth)^2)

listMeasures(wine_task)

training_set <- sample(1:nrow(wine), floor(0.8*nrow(wine)))
test <- setdiff(1:nrow(wine), training_set)
wine_task_training <- subsetTask(wine_task, training_set)
wine_task_training

wine_rf_training <- train('regr.randomForest', wine_task_training)
performance(predict(wine_rf_training, wine_task_training))
performance(predict(wine_rf_training, newdata = wine[test, ]))

wine_benchmark <- benchmark(makeLearners(c('lm', 'randomForest', 'svm'), type = 'regr'), resamplings = cv10, wine_task)
wine_benchmark

plotBMRSummary(wine_benchmark)
plotBMRBoxplots(wine_benchmark)

getParamSet('regr.randomForest')

rf <- makeLearner('regr.randomForest')

rf_params <- makeParamSet(
  makeDiscreteParam('mtry', values = 1:11),
  makeDiscreteParam('ntree', values = seq(500, 2000, 250))
)

rf_tuned_params <- tuneParams(rf, resampling = cv3, task = wine_task, par.set = rf_params, control = makeTuneControlRandom(maxit = 50))

rf_tuned_params

rf_tuned_data <- generateHyperParsEffectData(rf_tuned_params)
plotHyperParsEffect(rf_tuned_data, x = 'mtry', y = 'ntree', z = 'mse.test.mean', plot.type = 'heatmap')

rf <- setHyperPars(rf, par.vals = rf_tuned_params$x)

model_final <- train(rf, wine_task)

final_fit <- predict(model_final, wine_task)
final_fit

performance(final_fit)

library(parallelMap)

# parallelStartSocket/parallelStop to use more cpu cores

plotResiduals(predict(model_final, wine_task))

plotResiduals(predict(model_final, wine_task), type = 'hist')


wine_pdp <- generatePartialDependenceData(model_final, wine_task)

plotPartialDependence(wine_pdp)
