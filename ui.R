library(shiny)

shinyUI(fluidPage(
  titlePanel("MPG Predictor: How thirsty is your car?"),

  tabsetPanel(
    # ---------------------------------------------------------- App tab
    tabPanel("App",
      sidebarLayout(
        sidebarPanel(
          h4("Describe your car"),
          sliderInput("wt", "Weight (1000 lbs):",
                      min = 1.5, max = 5.5, value = 3, step = 0.1),
          sliderInput("hp", "Horsepower:",
                      min = 50, max = 340, value = 120, step = 5),
          radioButtons("trans", "Transmission:",
                       choices = c("Automatic", "Manual")),
          checkboxInput("show_interval", "Show 95% prediction interval",
                        value = TRUE),
          selectInput("xaxis", "Plot against:",
                      choices = c("Weight" = "wt", "Horsepower" = "hp")),
          helpText("Tip: change any control and the results update instantly.")
        ),
        mainPanel(
          h3("Predicted fuel economy"),
          h2(textOutput("mpg")),
          h4(textOutput("kmpl")),
          p(textOutput("interval")),
          plotOutput("plot"),
          p(em(textOutput("r2")))
        )
      )
    ),

    # ------------------------------------------------- Documentation tab
    tabPanel("How to use",
      h3("What does this app do?"),
      p("It predicts a car's fuel economy (miles per gallon) from three things:",
        "its weight, its horsepower and its transmission type. The prediction",
        "comes from a linear regression fitted to R's built-in ", code("mtcars"),
        " dataset (32 cars from a 1974 magazine road test)."),
      h3("Getting started in 4 steps"),
      tags$ol(
        tags$li("Open the ", strong("App"), " tab."),
        tags$li("Move the ", strong("Weight"), " and ", strong("Horsepower"),
                " sliders to describe your car (hover over a slider and drag)."),
        tags$li("Pick ", strong("Automatic"), " or ", strong("Manual"), "."),
        tags$li("Read the big number: it is the predicted MPG, with the same value in km/L below it.")
      ),
      h3("Reading the output"),
      tags$ul(
        tags$li(strong("Predicted fuel economy: "), "the model's best guess."),
        tags$li(strong("Likely range: "), "a 95% prediction interval. A real car with these specs should fall in this range about 95% of the time. Untick the checkbox to hide it."),
        tags$li(strong("Plot: "), "dots are the 32 real cars (blue = automatic, orange = manual). The red diamond is your car; the red line is its prediction interval. Use 'Plot against' to change the x-axis."),
        tags$li(strong("R-squared: "), "how much of the variation in MPG the model explains.")
      ),
      h3("Model details"),
      p(code("lm(mpg ~ wt + hp + transmission, data = mtcars)")),
      tableOutput("coefs"),
      h3("Caveats"),
      p("The data are from 1974 and cover only 32 cars, so treat predictions as a",
        "teaching example, not as advice for buying a car. Values outside the",
        "slider ranges are not supported because the model has never seen such cars.")
    )
  )
))
