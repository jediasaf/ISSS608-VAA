library(shiny)
library(bslib)
library(tidyverse)
library(plotly)
library(DT)

exam <- readr::read_csv("Exam_data.csv", show_col_types = FALSE)

subjects <- c("MATHS", "ENGLISH", "SCIENCE")
genders  <- sort(unique(exam$GENDER))
classes  <- sort(unique(exam$CLASS))

ui <- page_sidebar(
  title = "ISSS608 · Hands-on 6a: Exam Scores Explorer",
  theme = bs_theme(version = 5, bootswatch = "cosmo", primary = "#1e3a6b"),
  sidebar = sidebar(
    title = "Controls",
    selectInput("subject", "Subject", choices = subjects, selected = "MATHS"),
    radioButtons("plot_type", "Plot type",
                 choices = c("Histogram", "Boxplot", "Density")),
    selectInput("group", "Colour by",
                choices = c("None", "GENDER", "RACE", "CLASS"), selected = "GENDER"),
    conditionalPanel(
      "input.plot_type == 'Histogram'",
      sliderInput("bins", "Number of bins", min = 5, max = 40, value = 20)
    ),
    hr(),
    strong("Filter the data"),
    checkboxGroupInput("f_gender", "Gender", choices = genders,
                       selected = genders, inline = TRUE),
    selectizeInput("f_class", "Class", choices = classes,
                   selected = classes, multiple = TRUE)
  ),
  layout_columns(
    col_widths = c(4, 4, 4),
    value_box("Students in view", textOutput("n_students"),
              showcase = bsicons::bs_icon("people")),
    value_box("Mean score", textOutput("mean_score"),
              showcase = bsicons::bs_icon("bar-chart-line")),
    value_box("Median score", textOutput("median_score"),
              showcase = bsicons::bs_icon("graph-up"))
  ),
  card(card_header("Distribution"), plotlyOutput("dist_plot", height = "380px")),
  card(card_header("Records"), DTOutput("tbl"))
)

server <- function(input, output, session) {

  # Real reactive filter: the sidebar Gender / Class controls actually subset the data.
  filtered <- reactive({
    d <- exam
    if (length(input$f_gender)) d <- dplyr::filter(d, GENDER %in% input$f_gender)
    if (length(input$f_class))  d <- dplyr::filter(d, CLASS %in% input$f_class)
    d
  })

  output$n_students   <- renderText(nrow(filtered()))
  output$mean_score   <- renderText({ d <- filtered(); if (nrow(d)) round(mean(d[[input$subject]], na.rm = TRUE), 1) else "NA" })
  output$median_score <- renderText({ d <- filtered(); if (nrow(d)) round(median(d[[input$subject]], na.rm = TRUE), 1) else "NA" })

  output$dist_plot <- renderPlotly({
    d <- filtered()
    validate(need(nrow(d) > 0, "No students match the current filters."))
    grp <- input$group

    if (input$plot_type == "Boxplot") {
      if (grp != "None") {
        p <- ggplot(d, aes(x = .data[[grp]], y = .data[[input$subject]], fill = .data[[grp]])) +
          geom_boxplot(alpha = 0.75)
      } else {
        p <- ggplot(d, aes(y = .data[[input$subject]])) + geom_boxplot()
      }
    } else {
      p <- ggplot(d, aes(x = .data[[input$subject]]))
      if (input$plot_type == "Histogram") {
        p <- p + geom_histogram(
          aes(fill = if (grp != "None") .data[[grp]] else NULL),
          bins = input$bins, colour = "white", position = "identity", alpha = 0.7
        )
      } else {
        p <- p + geom_density(
          aes(colour = if (grp != "None") .data[[grp]] else NULL), linewidth = 0.9
        )
      }
    }

    p <- p + labs(x = input$subject, fill = NULL, colour = NULL) +
      theme_minimal(base_size = 13)
    ggplotly(p)
  })

  output$tbl <- renderDT({
    datatable(filtered(), options = list(pageLength = 8, scrollX = TRUE),
              class = "compact stripe hover", rownames = FALSE)
  })
}

shinyApp(ui, server)
