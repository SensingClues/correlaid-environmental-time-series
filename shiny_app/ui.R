library(shiny)

# Define UI for the application
shinyUI(fluidPage(
  
  # Add custom CSS for styling
  includeCSS("www/styles.css"),
  
  # Top navigation bar
  div(class = "navbar",
    div(class = "collab-logo",
        a(href = "https://sensingclues.org", target = "_blank",
          img(src = "sensing-clues-logo.png", alt = "Sensing Clues Logo", class = "collab-image black-logo")
        ),
      span(class = "collab-separator", "×"),
        a(href = "https://correlaid.nl", target = "_blank",
          img(src = "logo.svg", alt = "Correlaid Logo", class = "collab-image")
        )
      ),
      div(class = "nav-item", "Home"),
      div(class = "nav-item expandable", "About",
           div(class = "expand-content",
              div(class = "about-group",
                  h4("Correlaid"),
                  actionLink("project_overview", "Project Overview", class = "dropdown-item"),
              ),
          ),
      ),
      div(class = "nav-item expandable", "Conservation Tools",
          div(class = "expand-content",
              div(class = "tools-group",
                  h4("Data Collection"),
                  actionLink("sensor_deployment", "Sensor Deployment", class = "dropdown-item"),
                  actionLink("camera_traps", "Camera Traps", class = "dropdown-item"),
              ),
              div(class = "tools-group",
                  h4("Analysis"),
                  p("Data Processing"),
                  p("Species Recognition"),
              ),
         )
      ),
  ),
  
  # Main content area
  div(class = "content",
      uiOutput("pageContent")
  ),

  div(class = "footer",
    p("CorrelAid x Sensing Clues"),
    p("Built with ❤️  by volunteers. ")
  )
))

