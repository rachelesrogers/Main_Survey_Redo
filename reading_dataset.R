library(DBI)
library(RSQLite)
library(tidyverse)

redo_dataset <- dbConnect(RSQLite::SQLite(), "main_redo_database.sqlite")

responses <- dbGetQuery(redo_dataset, "SELECT * FROM survey_responses")

wide_response <- responses %>% filter(time > 1706123631 & prolificid !="Rachel") %>%
  select(!c(time, page)) %>% 
  pivot_wider(names_from = question, values_from = answer)

View(wide_response)

dbDisconnect(redo_dataset)

table(wide_response$conclusion)

chisq.test(table(wide_response$conclusion))

unique(wide_response$visible_probability)
names(wide_response)

table(wide_response[wide_response$conclusion=="Match",]$convict)
table(wide_response$check)

# Not significantly different from the first trial
prop.test(x=c(38, 82), n=c(61, 149), alternative = "greater")

tail(responses, 11)

dbListTables(redo_dataset)

consent <- dbGetQuery(redo_dataset, "SELECT * FROM consent_page")

demo1 <- dbGetQuery(redo_dataset, "SELECT * FROM demographics1")

demo2 <- dbGetQuery(redo_dataset, "SELECT * FROM demographics2")

notes <- dbGetQuery(redo_dataset, "SELECT * FROM notepad")

View(consent)

View(demo1)

View(demo2)

View(notes)

library(tidyverse)

# Time at start of the study
# > as.numeric(Sys.time())
# [1] 1706123631

demo1_response <- demo1 %>% filter(time > 1706123631 & prolificid !="Rachel") %>%
  select(!race) %>% distinct()
demo2_response <- demo2 %>% filter(time > 1706123631 & prolificid !="Rachel")
names(demo1_response)

demo_joined <- right_join(demo1_response, demo2_response, 
                          by=c("prolificid", "randomnumber", "start_time", "conclusion"))

response_joined <- right_join(demo_joined, wide_response)

response_clean <- response_joined %>% select(!c(comments, prolificid))

write.csv(response_clean, "mircrostudy_response_redo_clean.csv")

## Time Code
#demo1$actual_time1<-format(as.POSIXct((demo1$time), origin = "1970-01-01", tz = "America/Chicago"))
