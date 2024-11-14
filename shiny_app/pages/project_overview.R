library(shiny)

# UI function for Project Overview
projectOverviewUI <- function(id) {
  ns <- NS(id)  # Create a namespace for modularization
  tagList(
    h2("Project Overview"),
    div(class = "project-section",
        h3("Overview of the Project"),
        p("Partner organization: ", a("https://sensingclues.org/", href = "https://sensingclues.org/")),
        p("Team: 3 Data Enthusiasts, 1 Project Manager, 1 Project Trainee"),
        p("Topic: Tracking Landscape Vitality using Geo-Spatial Data through Sensor Deployment"),
        p("Skills: R, statistical modeling, visualization, GitHub. Familiarity with Geographic Information Systems (GIS) and Shiny app development is considered a plus"),
        p("Project start: ~ 04-11-2024"),
        p("Project end: ~ 31-01-2025"),
        p("Place: Remote"),
        p("Application deadline: 18-10-2024")
    ),
    
    div(class = "project-section",
        h3("About Sensing Clues"),
        p("Sensing Clues is a non-profit organization dedicated to global nature conservation through the development of a sophisticated suite of data-driven tools. By integrating real-time data collection, monitoring, and predictive analytics, Sensing Clues supports wildlife rangers, conservationists, and communities in their mission to protect biodiversity and ecosystems. The organization offers hands-on support to its users, making advanced technology accessible to field operators around the world, from Africa to Europe.")
    ),
    
    div(class = "project-section",
        h3("Vision"),
        p("Sensing Clues envisions a future where the power of data transforms conservation efforts, by enabling more proactive protection of wildlife and natural habitats globally.")
    ),
    
    div(class = "project-section",
        h3("Mission"),
        p("Sensing Clues’ mission is to provide nature conservation organizations with tools and interdisciplinary workspaces to turn data into actionable information. Our goal is to help professionals make timely, informed decisions that prevent threats to biodiversity and promote the sustainable coexistence of humans and wildlife.")
    ),
    
    div(class = "project-section",
        h3("Project Goals"),
        p("The main objective of this project is to implement a system for tracking vegetation conditions in protected areas using satellite imagery from publicly available sources, provided by the Sensing Clues team. In particular, the system will monitor the vegetation index over time, ensuring that it remains within its healthy range. This system will be integrated into Sensing Clues’ existing suite of tools, enabling local management and nature conservation organizations to utilize the information effectively and take timely actions to address any potential environmental concerns."),
        p("The project tasks can be broken down into the following parts:"),
        tags$ul(
          tags$li("Analysis of the currently available historical geospatial data"),
          tags$li("Using statistical approaches to determine the ‘normal’ bandwidth of the vegetation index"),
          tags$li("Implementing time series visualization maps for the levels of vegetation vigor"),
          tags$li("(Optional) Embedding of the implemented algorithms into a Shiny application")
        )
    ),
    
    # Interactive Plot Section
    h3("Sample Visualization"),
    p("Below is a sample interactive plot demonstrating hypothetical data on animal sightings based on distance to the road."),
    plotlyOutput(ns("samplePlot"))
  )
}

# Server function for Project Overview (no plot rendering)
projectOverviewServer <- function(id) {
    moduleServer(id, function(input, output, session) {
                       # No plot rendering needed
                     })
}

# Define main app to call UI and server
shinyApp(
  ui = fluidPage(
    projectOverviewUI("projectOverview")  # Calling the project overview UI
  ),
  server = function(input, output, session) {
    projectOverviewServer("projectOverview")  # Calling the project overview server logic
  }
)

