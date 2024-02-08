library(shiny)
library(dplyr)
library(shinyWidgets)
library(shinyjs)
library(DBI)
library(RSQLite)
library(pool)

source("Demographics.R")
source("Questions.R")

consenttxt <- read.table("Informed_Consent.txt")
testtxt<- read.csv("Combined_Testimony_Formatted.csv")
question_order<- read.csv("question_order.csv")

# --- Define UI -------
ui <- fluidPage(
  title = "Jury Study",
  style="font-size:20px",
                useShinyjs(),
                tags$head(
                  tags$style(
                    HTML(".shiny-notification {
             position:fixed;
             top: calc(45%);
             left: calc(45%);
             }
             "
                    )
                  )
                ),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "app.css")
  ),
  
  div(splitLayout(titlePanel(h1("Jury Perception Study", align="center", 
                )),
                column(10,style="padding:30px;", 
                       progressBar(id="progress", value=0, display_pct = TRUE))),
                style = "position:fixed; width: 100%; background-color: white;z-index: 1"),
  conditionalPanel(condition= "input.informed==0",
                   column(width=8, offset=2,
                          wellPanel(style="margin-top:70px", p(uiOutput("informed_consent")),
              column(12, actionButton("informed", "I Agree"), align="center"),
              br()))
    ),
  conditionalPanel(condition="input.demopage==2 & input.questionpage < 10",
                   wellPanel(style="background:url(Notebook.jpg); 
                             position: fixed; width: 98%; z-index:1; margin-top:70px", 
                             textAreaInput("notepad","Take Notes Here", rows=5, value=""),)),
  conditionalPanel(condition="input.informed==1 & input.demopage < 2",
                   column(width=8, offset=2,
                   wellPanel(style="margin-top:70px",uiOutput("demoquest"),
                             column(12, actionButton("demopage", "Next"), align="center"),
                             br()))),
  conditionalPanel(condition="input.demopage==2 & input.testimonypage<14",
                   column(width=8, offset=2,
                   wellPanel(style="margin-top:290px", p(uiOutput("testimony"))),
                   column(12, actionButton("testimonypage", "Next"), align="center"))),
  conditionalPanel(condition="input.testimonypage==14 & input.questionpage < 11",
                   column(width=8, offset=2,
                   wellPanel(style="margin-top:290px", uiOutput("finalquest"),
                   column(12, actionButton("questionpage", "Next"), align="center"),
                   br()))),
  conditionalPanel(condition="input.questionpage ==11",
                   wellPanel(style="margin-top:100px","Completion Code: C10EC7YB"))
  
)

# --- server ------

 pool <- dbPool(drv = RSQLite::SQLite(), dbname = "main_redo_database.sqlite")

server <- function(input, output, session) {
  
  id <- NULL
  algorithm <- "No"
  picture <- "No"
  conclusion <- sample(c("Match", "NoMatch"),1, prob=c(0.8, 0.2))
  questorder <- c(c("quest_1"="convict","quest_2"="def_comment","quest_3"="guilt_opinion"),
                       question_order[sample(nrow(question_order),1),], c("quest_11"="comments"))
  random_number <- runif(1,0,100)
  start_time <- Sys.time()
  answer <- reactiveVal()
  question_verification <- reactiveVal(0)
  
  subset_testimony<-testtxt %>% 
    subset((Conclusion=="All"|Conclusion==conclusion) &
             (Algorithm=="All"|Algorithm==algorithm) &
             (Picture=="All"|Picture==picture)) %>%
    aggregate(combined ~ Page, paste, collapse=" ")
  
  #https://stackoverflow.com/questions/65030433/adding-a-count-button-to-a-shiny-app-that-interacts-with-updatenumericinput
  counter <- reactiveVal(0)
  observeEvent(input$informed | input$demopage | input$testimonypage | input$questionpage, {
    shinyjs::runjs("window.scrollTo(0, 0)")
    newcount <- counter() + 1
    counter(newcount)
  })
  
  observe({
    updateProgressBar(session = session, id = "progress", value = (counter()/29)*100)
  })

  output$informed_consent <- renderUI(HTML(consenttxt[1,]))
  
  output$testimony <- renderUI(HTML(subset_testimony[input$testimonypage+1,]$combined))
  
  output$demoquest <- renderUI(demo[input$demopage+1])
    
  output$finalquest <- renderUI(questions[[questorder[[input$questionpage+1]]]])
  
  consentans <- reactive({
    return(data.frame(
      start_time = start_time,
      time = Sys.time(),
      page = counter(),
      randomnumber = random_number,
      conclusion = conclusion
    ))
  })
  
  observeEvent(input$informed,{
               con <- localCheckout(pool, env = parent.frame())
               dbAppendTable(con, "consent_page", consentans())
               })
  
  demo1ans <- reactive({
    return(data.frame(
      prolificid = input$prolificID,
      race = input$race,
      gender = input$gender,
      age = input$age,
      income = input$income,
      gunown = input$gunown,
      guncomfort = input$guncomfort,
      page = counter(),
      time = Sys.time(),
      randomnumber = random_number,
      start_time = start_time,
      conclusion = conclusion
    ))
  })
  
  demo2ans <- reactive({
    return(data.frame(
      prolificid = input$prolificID,
      education = input$educ,
      vote = input$vote,
      political = input$poli,
      arrest = input$arrest,
      state = input$state,
      jury = input$jury,
      crimejury = input$jurycrim,
      page = counter(),
      time = Sys.time(),
      randomnumber = random_number,
      start_time = start_time,
      conclusion = conclusion
    ))
  })
  
  validate_input_list <- function(x, vars) {
    list_of_needs <- purrr::map_lgl(vars, ~ !is.null(x[[.]]))
    all(list_of_needs)
  }
  
  btn_status <- function(vars) {
    # Trying to validate for button - does not work
    observe({
      page_filled <- validate_input_list(input, vars)
      if (!page_filled) {
        question_verification(0)
      } else {
        question_verification(1)
      }
    })
  }
  ###### Button Status ##########
  btn_status( c(
    "prolificID", "race", "gender", "age", "income",
    "gunown", "guncomfort"
  ))
  btn_status(c(
    "educ", "vote", "poli", "arrest", "state",
    "jury", "jurycrim"
  ))
  
  
  observeEvent(input$demopage,{
    con <- localCheckout(pool, env = parent.frame())
    if (input$demopage ==1){
    dbAppendTable(con, "demographics1", demo1ans())} else if (input$demopage ==2){
      dbAppendTable(con, "demographics2", demo2ans())
    }
    question_verification(0)
  })
  
  noteans <- reactive({
    return(data.frame(
      prolificid = input$prolificID,
      page = counter(),
      time = Sys.time(),
      randomnumber = random_number,
      start_time = start_time,
      notes = input$notepad,
      conclusion = conclusion
    ))
  })
  
  observeEvent(input$testimonypage,{
    con <- localCheckout(pool, env = parent.frame())
    dbAppendTable(con, "notepad", noteans())
  })
  
  # observeEvent(input$convict | input$def_comment | input$guilt_opinion | 
  #                input$check | input$evidence_strength | input$hidden_probability |
  #                input$visible_probability | input$chances_fixed, {
  #                  ans_temp <- input[[names(questions)[input$questionpage + 1]]]
  #                  answer(ans_temp)
  #                })
  observeEvent(input$convict, {
    ans_temp <- input$convict
    answer(ans_temp)
  })
  btn_status(c("convict"))
  
  observeEvent(input$comments, {
    ans_temp <- input$comments
    answer(ans_temp)
  })
  btn_status(c("comments"))
  
  observeEvent(input$def_comment, {
    ans_temp <- input$def_comment
    answer(ans_temp)
  })
  btn_status(c("def_comment"))
  
  observeEvent(input$guilt_opinion, {
    ans_temp <- input$guilt_opinion
    answer(ans_temp)
  })
  btn_status(c("guilt_opinion"))
  
  observeEvent(input$check, {
    ans_temp <- input$check
    answer(ans_temp)
  })
  btn_status(c("check"))
  
  observeEvent(input$evidence_strength, {
    ans_temp <- input$evidence_strength
    answer(ans_temp)
  })
  btn_status(c("evidence_strength"))
  
  observeEvent(input$hidden_probability, {
    ans_temp <- input$hidden_probability
    answer(ans_temp)
  })
  btn_status(c("hidden_probability"))
  
  observeEvent(input$visible_probability, {
    ans_temp <- input$visible_probability
    answer(ans_temp)
  })
  btn_status(c("visible_probability"))
  
  observeEvent(input$chances_fixed, {
    ans_temp <- input$chances_fixed
    answer(ans_temp)
  })
  btn_status(c("chances_fixed"))
  
  observeEvent(input$innocent_bet, {
    ans_temp <- input$innocent_bet
    answer(ans_temp)
  })
  btn_status(c("innocent_bet"))
  
  observeEvent(input$guilt_bet, {
    ans_temp <- input$guilt_bet
    answer(ans_temp)
  })
  btn_status(c("guilt_bet"))
  
  observeEvent(input$guilt_choice,{
    ans_temp <- paste0(input$guilt_choice, ",", input$like_num,",", input$like_denom)
    answer(ans_temp)
  })
  
    observeEvent(input$like_num | input$like_denom,{
    ans_temp <- paste0(input$guilt_choice, ",", input$like_num,",", input$like_denom)
    answer(ans_temp)
    if (isTruthy(input$like_num & input$like_denom)){
      if (input$like_num > input$like_denom){
        question_verification(0)
        id <<- showNotification(
          "First number must be less than or equal to second number",
          duration = 10, 
          closeButton = TRUE,
          type = "error"
        )
      } else{
        question_verification(1)
      }
    }
  })
  
  
  
  responseans <- reactive({
    return(data.frame(
      prolificid = input$prolificID,
      page = counter(),
      time = Sys.time(),
      randomnumber = random_number,
      start_time = start_time,
      question = questorder[[input$questionpage]],
      answer = answer(),
      conclusion = conclusion
    ))
  })
  
  observeEvent(input$questionpage,{
    con <- localCheckout(pool, env = parent.frame())
    dbAppendTable(con, "survey_responses", responseans())
    question_verification(0)
  })
  
  observe({
    shinyjs::toggleState("questionpage", question_verification() == 1)
  })
  
  observe({
    shinyjs::toggleState("demopage", question_verification() == 1)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
