library(shiny)
library(dplyr)
library(shinyWidgets)
library(shinyjs)
library(DBI)
library(RSQLite)
library(pool)

source("Demographics.R")
source("Questions.R")

completionCode <- "CURSXIHI" # Replace with prolific completion code

consenttxt <- read.table("Informed_Consent.txt")
testtxt<- read.csv("Combined_Testimony_Formatted.csv")

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
  conditionalPanel(condition="input.demopage==2 & input.questionpage < output.num_quest",
                   wellPanel(style="background:url(Notebook.jpg); 
                             position: fixed; width: 98%; z-index:1; margin-top:70px", 
                             textAreaInput("notepad","Take Notes Here", rows=5, value=""),)),
  conditionalPanel(condition="input.informed==1 & input.demopage < 2",
                   column(width=8, offset=2,
                          wellPanel(style="margin-top:70px",uiOutput("demoquest"),
                                    column(12, actionButton("demopage", "Next"), align="center"),
                                    br()))),
  conditionalPanel(condition="input.demopage==2 & 
                   input.testimonypage < output.testpages",
                   column(width=8, offset=2,
                          wellPanel(style="margin-top:290px", p(uiOutput("testimony"))),
                          column(12, actionButton("testimonypage", "Next"), align="center"))),
  conditionalPanel(condition="input.testimonypage == output.testpages & 
                   input.questionpage < output.num_quest",
                   column(width=8, offset=2,
                          wellPanel(style="margin-top:290px", uiOutput("finalquest"),
                                    column(12, actionButton("questionpage", "Next"), align="center"),
                                    br()))),
  conditionalPanel(condition="input.questionpage == output.num_quest",
                   wellPanel(style="margin-top:100px",sprintf("Completion Code: %s", completionCode)))
  
)

# --- server ------

pool <- dbPool(drv = RSQLite::SQLite(), dbname = "main_redo_database.sqlite")

server <- function(input, output, session) {
  
  id <- NULL
  algorithm <- sample(c("Yes", "No"),1, prob=c(0.5, 0.5))

  if (algorithm == "Yes"){
    output$testpages <- reactive(23)
    servpages <- reactive(23)
  } else if (algorithm=="No"){
    output$testpages <- reactive(14)
    servpages <- reactive(14)
                          }
  outputOptions(output, "testpages", suspendWhenHidden = FALSE)
  
  picture <- sample(c("Yes", "No"),1, prob=c(0.5, 0.5))
  conclusion <- sample(c("Match", "NoMatch"),1, prob=c(0.5, 0.5))

  if (algorithm == "Yes"){
    questorder <- c(c("convict","def_comment","guilt_opinion"),
                    sample(c("check", "def_probability", "mistakes",
                               "numeric_chance", "def_chance", "consistency",
                               "scientific", "gun_opinion", "gun_probability", 
                               "gun_chance", "alg_consistency", "alg_mistakes",
                             "alg_scientific")),
                    c("comments"))
  } else if (algorithm == "No"){
    questorder <- c(c("convict","def_comment","guilt_opinion"),
                    sample(c("check", "def_probability", "mistakes",
                             "numeric_chance", "def_chance", "consistency",
                             "scientific", "gun_opinion", "gun_probability", 
                             "gun_chance")),
                    c("comments"))
  }

  
  numquest <- length(questorder)
  output$num_quest <- reactive(length(questorder))
  outputOptions(output, "num_quest", suspendWhenHidden = FALSE)
  
  # Assigning a non-identifiable random number to match participants across databases
  random_number <- runif(1,0,100) 
  start_time <- Sys.time()
  answer <- reactiveVal()
  question <- reactiveVal()
  question_verification <- reactiveVal(0)
  prob_counter <- reactiveVal(0)
  
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
    updateProgressBar(session = session, id = "progress", 
                      value = (counter()/(servpages() + 4 + numquest))*100)
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
      conclusion = conclusion,
      algorithm = algorithm,
      picture = picture
    ))
  })
  
  observeEvent(input$informed,{
               con <- localCheckout(pool, env = parent.frame())
               dbAppendTable(con, "consent_page", consentans())
               })
  
  demo1ans <- reactive({
    return(data.frame(
      prolificid = input$prolificID,
      race = paste(input$race, collapse = ", "),
      gender = input$gender,
      age = input$age,
      income = input$income,
      gunown = input$gunown,
      guncomfort = input$guncomfort,
      page = counter(),
      time = Sys.time(),
      randomnumber = random_number,
      start_time = start_time,
      conclusion = conclusion,
      algorithm = algorithm,
      picture = picture
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
      conclusion = conclusion,
      algorithm = algorithm,
      picture = picture
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
      conclusion = conclusion,
      algorithm = algorithm,
      picture = picture
    ))
  })
  

  
  observeEvent(input$testimonypage,{
    con <- localCheckout(pool, env = parent.frame())
    dbAppendTable(con, "notepad", noteans())
  })
  
  observeEvent(input$testimonypage,{
    shinyjs::disable("testimonypage")
    # Initialize the timer, 10 seconds, not active.
    timer <- reactiveVal(2)
    active <- reactiveVal(TRUE)
    shinyjs::logjs("2s timer start")
    shinyjs::delay(2000, {
      shinyjs::logjs("timer up, enable next btn")
      shinyjs::enable("testimonypage")
    })
  })
  
  

  
  observeEvent(input$convict, {
    ans_temp <- input$convict
    answer(ans_temp)
    question("convict")
  })
  btn_status(c("convict"))
  
  observeEvent(input$def_comment, {
    ans_temp <- input$def_comment
    answer(ans_temp)
    question("def_comment")
  })
  btn_status(c("def_comment"))
  
  observeEvent(input$gun_opinion, {
    ans_temp <- input$gun_opinion
    answer(ans_temp)
    question("gun_opinion")
  })
  btn_status(c("gun_opinion"))
  
  observeEvent(input$guilt_opinion, {
    ans_temp <- input$guilt_opinion
    answer(ans_temp)
    question("guilt_opinion")
  })
  btn_status(c("guilt_opinion"))
  
  observeEvent(input$check, {
    ans_temp <- input$check
    answer(ans_temp)
    question("check")
  })
  btn_status(c("check"))
  
  observeEvent(input$def_probability, {
    ans_temp <- input$def_probability
    answer(ans_temp)
    question("def_probability")
    
    newcount <- prob_counter() + 1
    prob_counter(newcount)
    if (prob_counter()==1){
      question_verification(0)
    } else if (prob_counter() > 1){
      question_verification(1)
    }
  })
  
  observeEvent(input$gun_probability, {
    ans_temp <- input$gun_probability
    answer(ans_temp)
    question("gun_probability")
    
    newcount <- prob_counter() + 1
    prob_counter(newcount)
    if (prob_counter()==1){
      question_verification(0)
    } else if (prob_counter() > 1){
      question_verification(1)
    }
  })
  
  observeEvent(input$scientific, {
    ans_temp <- input$scientific
    answer(ans_temp)
    question("scientific")
    
    newcount <- prob_counter() + 1
    prob_counter(newcount)
    if (prob_counter()==1){
      question_verification(0)
    } else if (prob_counter() > 1){
      question_verification(1)
    }
  })
  
  observeEvent(input$mistakes, {
    ans_temp <- input$mistakes
    answer(ans_temp)
    question("mistakes")
  })
  btn_status(c("mistakes"))
  
  observeEvent(input$consistency, {
    ans_temp <- input$consistency
    answer(ans_temp)
    question("consistency")
  })
  btn_status(c("consistency"))
  
  observeEvent(input$def_chance, {
    ans_temp <- input$def_chance
    answer(ans_temp)
    question("def_chance")
  })
  btn_status(c("def_chance"))
  
  observeEvent(input$gun_chance, {
    ans_temp <- input$gun_chance
    answer(ans_temp)
    question("gun_chance")
  })
  btn_status(c("gun_chance"))
  
  observeEvent(input$comments, {
    ans_temp <- input$comments
    answer(ans_temp)
    question("comments")
  })
  btn_status(c("comments"))
  
  observeEvent(input$alg_consistency, {
    ans_temp <- input$alg_consistency
    answer(ans_temp)
    question("alg_consistency")
  })
  btn_status(c("alg_consistency"))
  
  observeEvent(input$alg_mistakes, {
    ans_temp <- input$alg_mistakes
    answer(ans_temp)
    question("alg_mistakes")
  })
  btn_status(c("alg_mistakes"))
  
  observeEvent(input$alg_scientific, {
    ans_temp <- input$alg_scientific
    answer(ans_temp)
    question("alg_scientific")
    newcount <- prob_counter() + 1
    prob_counter(newcount)
    if (prob_counter()==1){
      question_verification(0)
    } else if (prob_counter() > 1){
      question_verification(1)
    }
  })
  
  observeEvent(input$innocent_bet, {
    ans_temp <- input$innocent_bet
    answer(ans_temp)
    question("innocent_bet")
  })
  btn_status(c("innocent_bet"))
  
  observeEvent(input$guilt_bet, {
    ans_temp <- input$guilt_bet
    answer(ans_temp)
    question("guilt_bet")
  })
  btn_status(c("guilt_bet"))
  
    observeEvent(input$like_num | input$like_denom,{
    ans_temp <- paste0(input$like_num,",", input$like_denom)
    answer(ans_temp)
    question("numeric_chance")
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
      question = question(),
      answer = answer(),
      conclusion = conclusion,
      algorithm = algorithm,
      picture = picture
    ))
  })
  
  observeEvent(input$questionpage,{
    con <- localCheckout(pool, env = parent.frame())
    dbAppendTable(con, "survey_responses", responseans())
    question_verification(0)
    prob_counter(0)
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
