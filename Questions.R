questions <- list(
 convict= list(
    br(),
    radioButtons(
      "convict",
      "The State has the burden of proving beyond a reasonable doubt that the
                      defendant is the person who committed the alleged crime. If you are not
                      convinced beyond a reasonable doubt that the defendant is the person who
                      committed the alleged crime, you must find the defendant not guilty.
                     Would you convict this defendant, based on the evidence that you have heard?",
      c("Yes", "No"), selected=character(0)
    ),
    br()
  ),
  
  def_comment = list(
    br(),
    textInput("def_comment", "After reading this information, what do you think about the defendant?", value=""),
    br()
  ),
  
 guilt_opinion = list(
    br(),
    radioButtons(
      "guilt_opinion", "Do you personally believe that the defendant is guilty of committing the crime?",
      c("Yes", "No"), selected=character(0)
    ),
    br()
  ),
  
  check = list(
  br(),
  radioButtons(
    "check", "What caliber bullet was recovered from the crime scene?",
    c("9mm", "22mm", "Rifle slug"), selected=character(0)
  ),
  br()
  ),
  
 evidence_strength = list(
  br(),
  radioGroupButtons("evidence_strength", "How strong would you say the case against the defendant is?",
                    choices = c("1 Not at all strong", "2", "3","4", "5 Moderately strong", "6","7","8","9 Extremely strong"),
                    selected = character(0)),
  br()
  ),
  
  hidden_probability = list(
  br(),
  tags$head(tags$style('.irs-single {
            visibility: hidden !important;
    }')),
  sliderInput("hidden_probability",
              label = "What would you say is the percent chance that the
                    defendant is the man who fired the shot in the convenience store?",
              min = 0, max = 100, value = 50,
              ticks=FALSE,
              animate=FALSE
  ),
  br()
),

visible_probability = list(
  br(),
  tags$head(tags$style('.irs-single {
            visibility: visible !important;
    }')),
  sliderInput("visible_probability",
              label = "What would you say is the percent chance that the
                    defendant is the man who fired the shot in the convenience store?",
              min = 0, max = 100, value = 50
  ),
  br()
), 

numeric_chance = list(
  br(),
                   fluidRow(
                     column(4,align="center", p("There is about", style="padding:20px;")),
                     column(2,
                   shinyWidgets::autonumericInput("like_num", "",
                                                  value=NA, minimumValue=1, 
                                                  maximumValue=1000000000000)),
                   column(3, align="center", p("chance(s) in", style="padding:20px;")),
                   column(2,
                   shinyWidgets::autonumericInput("like_denom", 
                                                  "", value=NA, minimumValue=1, 
                                                  maximumValue=1000000000000))),
  fluidRow(column(4, align="center", p("that the defendant is", style="padding:20px;")),
           column(4,  selectInput("guilt_choice", "", 
                                  c("innocent", "guilty"), width = "200px"))),
  br()
),

betting = list(
  br(),
  conditionalPanel(condition=("input.guilt_opinion == 'Yes'"),
                   value="guilty_panel_bet",
               shinyWidgets::autonumericInput("guilt_bet", 
                                              "If the researchers provided you with $50, how much would you be willing to bet on Cole being guilty?
                                              If you are correct, you double your money.", 
                                              value = "", 
                                           currencySymbol="$",
                                          currencySymbolPlacement = "p",
                                              minimumValue= 0, 
                                              maximumValue= 50
                                           )
               ),
  conditionalPanel(condition=("input.guilt_opinion == 'No'"),
                   value="innocent_panel_bet",
                   shinyWidgets::autonumericInput("innocent_bet", 
                                "If the researchers provided you with $50, how much would you be willing to bet on Cole being innocent?
                                If you are correct, you double your money.", 
                                value = "", 
                                currencySymbol="$",
                                currencySymbolPlacement = "p",
                                minimumValue= 0, 
                                maximumValue= 50,
                                width="100%"
                                )
               ),
  br()
),

chances_fixed = list(
  br(),
  radioButtons("chances_fixed", "What are the chances that the defendant is guilty?",
                    choices = c("Certain to be guilty", "About 9,999 chances in 10,000", 
                                "About 999 chances in 1,000","About 99 chances in 100", 
                                "About 9 chances in 10", "1 chance in 2 (fifty-fifty chance)",
                                "About 1 chance in 10","About 1 chance in 100","About 1 chance in 1,000",
                                "About 1 chance in 10,000", "Impossible that he is guilty"),
                    selected = character(0)),
  br()
),

comments = list(
  br(),
  textInput("comments", "Do you have any thoughts about the study
                              that you would like to share?", value = ""),
  br()
)

)




