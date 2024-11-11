# server.R

library(shiny)

# Define the server logic
shinyServer(function(input, output) {
  
  output$distPlot <- renderPlot({
    # Generate a histogram based on the number of observations chosen
    dist <- rnorm(input$obs)
    hist(dist, main = "Histogram of Random Normal Distribution",
         xlab = "Value", col = "skyblue", border = "white")
  })
  
})

