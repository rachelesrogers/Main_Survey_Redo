library(DBI)
library(RSQLite)

redo_dataset <- dbConnect(RSQLite::SQLite(), "main_redo_database.sqlite")

# resp<-dbGetQuery(redo_dataset, "SELECT * FROM survey_responses")
# View(resp)
consent <- data.frame(
  start_time = character(),
  time = character(),
  page = numeric(),
  randomnumber = numeric(),
  conclusion = character(),
  algorithm = character(),
  picture = character()
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
  conclusion = character(),
  algorithm = character(),
  picture = character()
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
  conclusion = character(),
  algorithm = character(),
  picture = character()
)

dbWriteTable(redo_dataset, "demographics2", demographics2)

notepad <- data.frame(
  prolificid = character(),
  page = numeric(),
  time = character(),
  randomnumber = numeric(),
  start_time = character(),
  notes = character(),
  conclusion = character(),
  algorithm = character(),
  picture = character()
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
  conclusion = character(),
  algorithm = character(),
  picture = character()
)

dbWriteTable(redo_dataset, "survey_responses", survey_responses)

dbDisconnect(redo_dataset)
