rsconnect::setAccountInfo(name='divyansh27', token='1A824994B8E2049A8315A80316C60AAB', secret='qjkrWvlYUtsU4IKqV90pkhsi82L7bBjcHequ52Qf')library(shiny)

# ---- Model is fit once, when the app starts -------------------------------
data(mtcars)
cars_df <- mtcars
cars_df$trans <- factor(cars_df$am, levels = c(0, 1),
                        labels = c("Automatic", "Manual"))
fit <- lm(mpg ~ wt + hp + trans, data = cars_df)

shinyServer(function(input, output) {

  # Reactive: new car described by the widgets
  new_car <- reactive({
    data.frame(wt = input$wt,
               hp = input$hp,
               trans = factor(input$trans, levels = levels(cars_df$trans)))
  })

  # Reactive: prediction with a 95% prediction interval
  pred <- reactive({
    predict(fit, newdata = new_car(), interval = "prediction", level = 0.95)
  })

  output$mpg <- renderText({
    sprintf("%.1f MPG", pred()[1, "fit"])
  })

  output$kmpl <- renderText({
    # 1 US mile per gallon = 0.425144 km per litre
    sprintf("%.1f km/L", pred()[1, "fit"] * 0.425144)
  })

  output$interval <- renderText({
    if (!input$show_interval) return("(interval hidden)")
    sprintf("Likely range: %.1f to %.1f MPG",
            max(pred()[1, "lwr"], 0), pred()[1, "upr"])
  })

  output$plot <- renderPlot({
    xvar  <- input$xaxis
    xlab  <- if (xvar == "wt") "Weight (1000 lbs)" else "Horsepower"
    cols  <- ifelse(cars_df$trans == "Automatic", "steelblue", "darkorange")
    plot(cars_df[[xvar]], cars_df$mpg, pch = 19, col = cols,
         xlab = xlab, ylab = "Miles per gallon",
         main = "Your car vs. the 32 cars in mtcars")
    legend("topright", legend = c("Automatic", "Manual", "Your car"),
           col = c("steelblue", "darkorange", "red"),
           pch = c(19, 19, 18), bty = "n")
    points(new_car()[[xvar]], pred()[1, "fit"], pch = 18, cex = 2.5, col = "red")
    if (input$show_interval) {
      segments(new_car()[[xvar]], max(pred()[1, "lwr"], 0),
               new_car()[[xvar]], pred()[1, "upr"], col = "red", lwd = 2)
    }
  })

  output$coefs <- renderTable({
    s <- summary(fit)$coefficients
    data.frame(Term = rownames(s),
               Estimate = round(s[, 1], 3),
               `P value` = signif(s[, 4], 3),
               check.names = FALSE)
  })

  output$r2 <- renderText({
    sprintf("Model R-squared: %.2f (the model explains about %.0f%% of the variation in MPG).",
            summary(fit)$r.squared, 100 * summary(fit)$r.squared)
  })
})
