library(DBI)
library(RSQLite)

redo_dataset <- dbConnect(RSQLite::SQLite(), "redo_database.sqlite")

dbGetQuery(redo_dataset, "SELECT * FROM survey_responses")
# dbRemoveTable(redo_dataset, "consent_page")
# dbDisconnect(redo_dataset)
consent <- data.frame(
  start_time = character(),
  time = character(),
  page = numeric(),
  randomnumber = numeric(),
  conclusion = character()
)

dbWriteTable(redo_dataset, "consent_page", consent)

demographics1 <- data.frame(
  prolificid = character(),
  race = character(),
  gender = character(),
  age = character(),
  income = character(),
  gunown = character(),
  guncomfort = character(),
  page = numeric(),
  time = character(),
  randomnumber = numeric(),
  start_time = character(),
  conclusion = character()
)

dbWriteTable(redo_dataset, "demographics1", demographics1)

demographics2 <- data.frame(
  prolificid = character(),
  education = character(),
  vote = character(),
  political = character(),
  arrest = character(),
  state = character(),
  jury = character(),
  crimejury = character(),
  page = numeric(),
  time = character(),
  randomnumber = numeric(),
  start_time = character(),
  conclusion = character()
)

dbWriteTable(redo_dataset, "demographics2", demographics2)

notepad <- data.frame(
  prolificid = character(),
  page = numeric(),
  time = character(),
  randomnumber = numeric(),
  start_time = character(),
  notes = character(),
  conclusion = character()
)

dbWriteTable(redo_dataset, "notepad", notepad)

survey_responses <- data.frame(
  prolificid = character(),
  page = numeric(),
  time = character(),
  randomnumber = numeric(),
  start_time = character(),
  question = character(),
  answer = character(),
  conclusion = character()
)

dbWriteTable(redo_dataset, "survey_responses", survey_responses)

dbDisconnect(redo_dataset)

# library(combinat)
# 
# full_perm <- permn(c("check", "evidence_strength", "hidden_probability", 
#                      "visible_probability", "numeric_chance", "betting", "chances_fixed"))
# 
# perm_df<-do.call(rbind.data.frame, full_perm)
# 
# names(perm_df)<- c("quest_4", "quest_5", "quest_6", "quest_7", "quest_8", "quest_9", "quest_10")
# 
# keep_list <- NA
# for (i in 1:dim(perm_df)[1]){
#   if (abs(which(perm_df[i,]=="hidden_probability")-which(perm_df[i,]=="visible_probability"))==1 |
#       abs(which(perm_df[i,]=="numeric_chance")-which(perm_df[i,]=="chances_fixed"))==1){
#     keep_list[i] <- FALSE
#   }else{
#     keep_list[i] <- TRUE
#   }
# }
# 
# red_df <- perm_df[keep_list,]
# 
# write.csv(red_df, "question_order.csv", row.names=FALSE)
