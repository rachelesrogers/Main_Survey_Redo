questions <- list(
 convict= list(
    radioButtons(
      "convict",
      "The State has the burden of proving beyond a reasonable doubt that the
                      defendant is the person who committed the alleged crime. If you are not
                      convinced beyond a reasonable doubt that the defendant is the person who
                      committed the alleged crime, you must find the defendant not guilty.
                     Would you convict this defendant (Richard Cole), based on the evidence that you have heard?",
      c("Yes", "No"), selected=character(0)
    )
  ),
  
  def_comment = list(
    textInput("def_comment", "After reading this information, what do you think about the defendant, Richard Cole?", value="")
  ),
  
 gun_opinion = list(
    radioButtons(
      "gun_opinion", "Do you personally believe that the defendant's gun was used in the crime?",
      c("Yes", "No"), selected=character(0)
    )  
    ),
 
 guilt_opinion = list(
   radioButtons(
     "guilt_opinion", "Do you personally believe that the defendant, Richard Cole, is guilty of committing the crime?",
     c("Yes", "No"), selected=character(0)
   )
 ),
  
  check = list(
  radioButtons(
    "check", "What caliber bullet was recovered from the crime scene?",
    c("9mm", "22mm", "Rifle slug"), selected=character(0)
  )
  ),

def_probability = list(
  tags$head(tags$style('.irs-from, .irs-to, .irs-min, .irs-max {
            visibility: visible !important;
    } .irs-single {
            visibility: hidden !important;
    }')),
  sliderInput("def_probability",
              label = "What would you say is the percent chance that the
                    defendant, Richard Cole, is the man who fired the shot in the convenience store?",
              min = 0, max = 100, value = 50,
              ticks=FALSE,
              animate=FALSE
  )
),

gun_probability = list(
  tags$head(tags$style('.irs-from, .irs-to, .irs-min, .irs-max {
            visibility: visible !important;
    } .irs-single {visibility: hidden !important;}')),
  sliderInput("gun_probability",
              label = "What would you say is the percent chance that the
                    defendant's gun was used to fire the shot in the convenience store?",
              min = 0, max = 100, value = 50,
              ticks=FALSE,
              animate=FALSE
  )
),

scientific = list(
  tags$head(tags$style('.irs-from, .irs-to, .irs-min, .irs-max, .irs-single {
            visibility: hidden !important;
    }')),
  fluidRow(column(2, align="center", p("unscientific", 
                                       style="padding:20px; margin-top:80px;")),
           column(8,    sliderInput("scientific",
                                    label = "How scientific did you find the firearms examiner
                                    (Terry Smith)'s manual comparison of the test fired bullet to the bullet 
                                    recovered from the crime scene?",
                                    min = 0, max = 100, value = 50,
                                    ticks=FALSE,
                                    animate=FALSE)),
           column(2, align="center", p("scientific", 
                                       style="padding:20px; margin-top:80px;")))
),

mistakes = list(
  radioButtons("mistakes", 
               "How often do you think the firearms examiner, Terry Smith, makes mistakes?",
               choices = c("Always makes mistakes", "About 9,999 comparisons in 10,000", 
                           "About 999 comparisons in 1,000","About 99 comparisons in 100", 
                           "About 9 comparisons in 10", "1 comparison in 2 (half of comparisons)",
                           "About 1 comparison in 10","About 1 comparison in 100","About 1 comparison in 1,000",
                           "About 1 comparison in 10,000", "Never makes mistakes"),
               selected = character(0))
), 

consistency = list(
  radioButtons("consistency", 
               "If other examiners were asked to make the same bullet comparison,
               how many do you believe would agree with the firearms examiner (Terry Smith)'s conclusion?",
               choices = c("All examiners", "About 9,999 examiners in 10,000", 
                           "About 999 examiners in 1,000","About 99 examiners in 100", 
                           "About 9 examiners in 10", "1 examiner in 2 (half of examiners)",
                           "About 1 examiner in 10","About 1 examiner in 100","About 1 examiner in 1,000",
                           "About 1 examiner in 10,000", "No examiner"),
               selected = character(0))
), 

numeric_chance = list(
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
  fluidRow(column(7, align="center", p("that the defendant, Richard Cole, is guilty", 
                                       style="padding:20px;")))
),

def_chance = list(
  radioButtons("def_chance", "What are the chances that the defendant, Richard Cole, is guilty?",
                    choices = c("Certain to be guilty", "About 9,999 chances in 10,000", 
                                "About 999 chances in 1,000","About 99 chances in 100", 
                                "About 9 chances in 10", "1 chance in 2 (fifty-fifty chance)",
                                "About 1 chance in 10","About 1 chance in 100","About 1 chance in 1,000",
                                "About 1 chance in 10,000", "Impossible that he is guilty"),
                    selected = character(0))
),

gun_chance = list(
  radioButtons("gun_chance", "What are the chances that the defendant's gun was used in the crime?",
               choices = c("Certain that gun was used", "About 9,999 chances in 10,000", 
                           "About 999 chances in 1,000","About 99 chances in 100", 
                           "About 9 chances in 10", "1 chance in 2 (fifty-fifty chance)",
                           "About 1 chance in 10","About 1 chance in 100","About 1 chance in 1,000",
                           "About 1 chance in 10,000", "Impossible that gun was used"),
               selected = character(0))
),

comments = list(
  textInput("comments", "Do you have any thoughts about the study
                              that you would like to share?", value = "")
),

#################### Algorithm Questions #############################

alg_consistency = list(
  radioButtons("alg_consistency", 
               "What are the chances that a different bullet matching algorithm (developed
               by another research group) would come to the same conclusion?",
               choices = c("Guaranteed to reach the same conclusion", "About 9,999 chances in 10,000", 
                           "About 999 chances in 1,000","About 99 chances in 100", 
                           "About 9 chances in 10", "1 chances in 2 (half of the time)",
                           "About 1 chance in 10","About 1 chance in 100","About 1 chance in 1,000",
                           "About 1 chance in 10,000", "Impossible to reach the same conclusion"),
               selected = character(0))
), 

alg_mistakes = list(
  radioButtons("alg_mistakes", 
               "How often do you think the algorithm makes mistakes?",
               choices = c("Always makes mistakes", "About 9,999 comparisons in 10,000", 
                           "About 999 comparisons in 1,000","About 99 comparisons in 100", 
                           "About 9 comparisons in 10", "1 comparison in 2 (half of comparisons)",
                           "About 1 comparison in 10","About 1 comparison in 100","About 1 comparison in 1,000",
                           "About 1 comparison in 10,000", "Never makes mistakes"),
               selected = character(0))
), 

alg_scientific = list(
  tags$head(tags$style('.irs-from, .irs-to, .irs-min, .irs-max, .irs-single {
            visibility: hidden !important;
    }')),
  fluidRow(column(2, align="center", p("unscientific", 
                                       style="padding:20px; margin-top:40px")),
           column(8,    sliderInput("alg_scientific",
                                    label = "How scientific did you find the algorithmic comparison 
                                    of the test fired bullet to the bullet 
                                    recovered from the crime scene?",
                                    min = 0, max = 100, value = 50,
                                    ticks=FALSE,
                                    animate=FALSE)),
           column(2, align="center", p("scientific", 
                                       style="padding:20px; margin-top:40px")))
)

)




