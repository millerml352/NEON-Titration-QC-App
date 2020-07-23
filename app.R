# Load dependencies
library(shiny)
library(neonUtilities)
library(data.table)
library(tidyverse)
#library(rlang)
#library(plotly)

# Define UI
ui <- fluidPage(
    
    titlePanel("Plot Lab Titration Values"),
    
    # Sidebar
    sidebarLayout(
        
        sidebarPanel(width = 3,
            
            helpText("Select site, date range, and which sample types and units you would like to view."),
            
            selectInput(inputId = "siteInput",
                        label = "Select a siteID",
                        choices = c(" ","ARIK","BARC","BIGC","BLWA","BLDE","BLUE","CARI","COMO","CRAM",
                                    "CUPE","FLNT","GUIL","KING","LECO","LEWI","LIRO","HOPB","MART",
                                    "MAYF","MCDI","MCRA","OKSR","POSE","PRLA","PRPO","PRIN","REDB",
                                    "SUGG","SYCA","TECR","TOMB","TOOK","WALK","WLOU"),
                        selected = " ",
                        width = '60%'),
            
        # single date range input form, unsure how to access start and end separately

        # dateRangeInput('dateRange',
        #     label = 'Date range input: yyyy-mm-dd',
        #     start = Sys.Date() - 2, end = Sys.Date() + 2
        # ),
            
            dateInput(inputId = "startDateInput",
                      label="Start Date",
                      value=Sys.Date()-2,
                      min="2010-01-01",
                      max="2040-01-01",
                      format="yyyy-mm-dd",
                      startview = "month",
                      weekstart = 0,
                      language= "en",
                      width='80%'), #try yyyy-mm at some point
            
            dateInput(inputId = "endDateInput",
                      label="End Date",
                      min="2010-01-01",
                      max="2040-01-01",
                      format="yyyy-mm-dd",
                      startview = "month",
                      weekstart = 0,
                      language= "en",
                      width='80%'),
            
            br(),
            
            # maybe just display all 4 plots? already made the request might as well plot em
            # instead of downloading again
            # 
            # checkboxGroupInput(inputId = "sampleTypeInput",
            #                    h5("Sample Type"),
            #                    choices = list("ALK" = "alk",
            #                                   "ANC" = "anc"),
            #                    selected = "alk"),
            # 
            # checkboxGroupInput(inputId = "unitInput",
            #                    h5("Units to View"),
            #                    choices = list("meq/L" = "equivalents",
            #                                   "mg/L" = "milligrams"),
            #                    selected = "equivalents"),
            
            # Load enough JavaScripppp to make this work
            # Just for message alerts/debugging
            tags$head(tags$script(src = "message-handler.js")),
            actionButton("get", label = "Retrieve Data", width="120px"),
            # on click run a function that executes the loadByProduct sequence
            # figure out scope for variables
            
            br(),
            
            br(),
            
            actionButton("plot", label = "Plot Data", width="120px"),
            
            br(),
            
            br(),
            
            img(src = "neon.png", height = 'auto', width = "80%"),
            
            br(),
            
            "Shiny is a product of ",
            span("RStudio", style = "color:blue")
        ),
        
        # Main Panel
        mainPanel(
            
            h1("Is water wet? ", strong("Hell yeah it is!")),
            
                p("This app uses the ",
                  
                  code("neonUtilities"),
                  " package to download NEON SWC domain lab titration data and plot alkalinity (ALK) and acid neutralizing capacity (ANC) in milligrams per liter (mg/L) and milliequivalents per liter (mEq/L). Local data files are not required; an API call using the ",
                  
                  code("loadByProduct"),
                  " function will be made to retrieve your selected data. Certain R package dependencies may be required. Select a site and date range, first press retrieve data, then plot data."),
            
            br(),
            
                p("Please reference the table below from the SWC protocol for recommended sample volume and titrant normality."),
            
            div(img(src = "titrationVolumesKBA.png", height = "auto", width = "60%"), style="text-align: center"),
            
            br(),
            
            h2("Plot"),

            # headers to verify sidebar selections are correct
            fluidRow(
                column(12,
                       h4("Headers")
                )  
            ),
            fluidRow(
                column(4,
                   verbatimTextOutput("site")
                ),
                column(4,
                   verbatimTextOutput("startDate")
                ),
                column(4,
                   verbatimTextOutput("endDate")
                )
            ),
            
            # plot ALK and ANC in mEq/L 6 col ea
            fluidRow(
                column(12,
                       h3("Plots (mEq/L)")
                )  
            ),
            fluidRow(
                column(6, 
                       # output plot1
                       plotOutput(outputId = "plot1")
                       ),
                column(6,
                       # output plot2
                       plotOutput(outputId = "plot2")
                       )
            ),
            
            # plot ALK and ANC in mg/L 6 col ea
            fluidRow(
                column(12,
                       h3("Plots (mg/L)")
                )  
            ),
            fluidRow(
                column(6, 
                       # output plot3
                       plotOutput(outputId = "plot3")
                       ),
                column(6, 
                       # output plot4
                       plotOutput(outputId = "plot4")
                       )
            )
            
        )
        
    )
   
)
br()

# Define server logic ----
server <- function(input, output, session) {
    
    # HEADER ROW
    # output selected site to header row
    output$site <- renderText({
        paste("Site:", as.character(input$siteInput))
    })
    
    # output selected start date to header row
    output$startDate  <- renderText({
        paste("Start:", substr(as.character(input$startDateInput),1,7))
    })
    
   # substr(as.character(x2), 1, 7)
    
    # output selected end date to header row
    output$endDate <- renderText({
        paste("End:", substr(as.character(input$endDateInput),1,7))
    })
    
    # retrieve user selected inputs OH MY GOD ITS ALIVEEEEEEE
    dataInputs <- reactive({
        startdate = substr(as.character(input$startDateInput),1,7)
        enddate = substr(as.character(input$endDateInput),1,7)
        site = input$siteInput
    })
    
    # define getData function to be called when user presses retrieve button
    #######
    # chemData is being superassigned to the .GlobalEnv here (because I can't figure out scoping)
    # that will have to be refactored for a production environment to avoid sharing of
    # global environment variables between users during the same "session"
    getData <- function() {
        chemData <<- loadByProduct(dpID=c("DP1.20093.001"),
                                dataInputs(),
                                startdate = substr(as.character(input$startDateInput),1,7),
                                enddate = substr(as.character(input$endDateInput),1,7),
                                package="expanded",
                                check.size = FALSE)
        
        # extract swc_domainLabData dataframe out
        chemDataFrame <<- chemData$swc_domainLabData
        
    # figure out how to work with df rather than exporting variables to global env, function waits until app ends to set globalenv anyways 
    
    # list2env(df, envir=.GlobalEnv)
        
    # titrationValues <- swc_domainLabData
    }
    
    # extract swc_domainLabData dataframe out
    #chemDataFrame <- chemData$swc_domainLabData
    
    

    
    
    # debugging JS alert from retrieve button
    observeEvent(input$get, {
        session$sendCustomMessage(type = 'testmessage',
                                  message = "Pressed Retrieve data button!")
    })
    
    # call getData()
    observeEvent(input$get, {
        getData()

    })
    
    # debugging js alert from plot button
    observeEvent(input$plot, {
       session$sendCustomMessage(type = 'testmessage',
                                 message = "Pressed Plot data button!")
    })
    
    # render plots to UI, call createPlots() then outputPlots()
    observeEvent(input$plot, {
        # hardcode for BIGC first, then create a plot function that can accept the reactive inputs from above
        # render site ALK meq/l
        output$plot1 <- renderPlot({
            plot(alkMeqPerL~titrationDate, 
                 data = chemDataFrame[which(chemDataFrame$sampleType=="ALK" & chemDataFrame$siteID=="BIGC"),],
                 type="b", main = "BIGC ALK Values", sub = date())
            abline(h = 1, col = 'red')
        })
        # render site ANC meq/l
        output$plot2 <- renderPlot({
            plot(ancMeqPerL~titrationDate, 
                 data = chemDataFrame[which(chemDataFrame$sampleType=="ANC" & chemDataFrame$siteID=="BIGC"),],
                 type="b", main = "BIGC ANC Values", sub = date())
            abline(h = 1, col = 'red')
        })
        # render site ALK mg/l
        output$plot3 <- renderPlot({
            plot(alkMgPerL~titrationDate, 
                 data = chemDataFrame[which(chemDataFrame$sampleType=="ALK" & chemDataFrame$siteID=="BIGC"),],
                 type="b", main = "BIGC ALK Values", sub = date())
            abline(h = 1, col = 'red')
        })
        # render site ANC mg/l
        output$plot4 <- renderPlot({
            plot(ancMgPerL~titrationDate, 
                 data = chemDataFrame[which(chemDataFrame$sampleType=="ANC" & chemDataFrame$siteID=="BIGC"),],
                 type="b", main = "BIGC ANC Values", sub = date())
            abline(h = 1, col = 'red')
        })
    })

    # # Retrieve selected siteID via reactive expression
    # # store selected siteID as a one-item character vector to use in loadByProduct
    # selectedSite <- reactive({
    #     c(input$siteInput)
    # })
    
    # # retrieve startDateInput
    # selectedStart <- reactive ({
    #     c(input$startDateInput)
    # })
    # 
    #     # Send to UI startInput
    #     output$text2 <- renderText({
    #         selectedStart()
    #     })    
    #     
    # # retrieve endDateInput
    # selectedEnd <- reactive ({
    #     c(input$endDateInput)
    # })
    # 
    #     # Send to UI startInput
    #     output$text3 <- renderText({
    #         selectedEnd()
    #     })
}
# Run the app ----
shinyApp(ui = ui, server = server)
