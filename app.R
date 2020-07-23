# Load dependencies
library(shiny)
library(neonUtilities)
library(data.table)
library(tidyverse)
#library(plotly)

# Define UI
ui <- fluidPage(
    
    # javaScript library for debugging alerts
    tags$head(tags$script(src = "message-handler.js")),
    
    titlePanel("Plot Lab Titration Values"),
    
    # Sidebar
    sidebarLayout(
        
        sidebarPanel(width = 3,
            
            helpText("Select site, date range, and which sample types and units you would like to view."),
            
            # site selection
            selectInput(inputId = "siteInput",
                        label = "Select a siteID",
                        choices = c(" ","ARIK","BARC","BIGC","BLDE","BLUE","BLWA","CARI","COMO","CRAM",
                                    "CUPE","FLNT","GUIL","KING","LECO","LEWI","LIRO","HOPB","MART",
                                    "MAYF","MCDI","MCRA","OKSR","POSE","PRIN","PRLA","PRPO","REDB",
                                    "SUGG","SYCA","TECR","TOMB","TOOK","WALK","WLOU"),
                        selected = " ",
                        width = '60%'),
            
        # single date range input form accessed w/: from <-  input[1], to <- input[2]
        # dateRangeInput('dateRange',
        #     label = 'Date range input: yyyy-mm-dd',
        #     start = Sys.Date() - 2, end = Sys.Date() + 2
        # ),
            
            # start date selection
            # loadByProduct() only takes YYYY-MM, changing format here will change what displays to the user
            # but it doesnt actually change what is passed to the functions
            # hard-coded to substr()[1,7] in server-side
            dateInput(inputId = "startDateInput",
                      label="Start Date",
                      value=Sys.Date()-2,
                      min="2010-01-01",
                      max="2040-01-01",
                      format="yyyy-mm-dd",
                      startview = "month",
                      weekstart = 0,
                      language= "en",
                      width='80%'),
            
            # end date selection
            # same issue as start :/
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
        
            # initially wanted to give the option to plot ALK or ANC or both, and meq/l or mg/l or both
            # now just plotting all options for each site/date combination to reduce unnecessary requests to
            # loadbyproduct API
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
            
            # executes getData function using loadByProduct()
            actionButton("get", label = "Retrieve Data", width="120px"),
            
            br(),
            
            br(),
            # executes plot function tbd
            actionButton("plot", label = "Plot Data", width="120px"),
            
            br(),
            
            br(),
            # neon logo
            img(src = "neon.png", height = 'auto', width = "80%"),
            
            br(),
            # shiny tm
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
            
            # SWC protocol table
            div(img(src = "titrationVolumesKBA.png", height = "auto", width = "60%"), style="text-align: center"),
            
            h2("Plot"),

            # headers to verify sidebar selections are outputting correctly
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
    ### chemData and chemDataFrame is being superassigned to the .GlobalEnv here to escape function scope
    ### cant do that if hosting live or first generated df will be shared between users
    getData <- function() {
        chemData <<- loadByProduct(dpID=c("DP1.20093.001"),
                                dataInputs(),
                                startdate = substr(as.character(input$startDateInput),1,7),
                                enddate = substr(as.character(input$endDateInput),1,7),
                                package="expanded",
                                check.size = FALSE)
        
        # extract swc_domainLabData dataframe out
        chemDataFrame <<- chemData$swc_domainLabData
    }

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
            ggplot(data = chemDataFrame[which(chemDataFrame$sampleType=="ALK"),], mapping = aes(x = titrationDate, y = alkMeqPerL)) +
                geom_point(aes(color = factor(sampleVolume))) +
                geom_line() +
                #meq/l thresholds from table
                geom_abline(slope = 0, intercept = 1, color = 'red') +
                geom_abline(slope = 0, intercept = 4, color = 'red') +
                geom_abline(slope = 0, intercept = 20, color = 'red') +
                labs(title = "Alkalinity, milliequivalents per liter",
                     x = "Titraton Date",
                     y = "ALK mEq/L") +
                scale_x_datetime(date_breaks = "4 months") +
                theme_bw() +
                theme(legend.title = element_blank(), 
                      text = element_text(size = 14), 
                      axis.text.x = element_text(angle=45, vjust=1.0, hjust=1.0))
        })
        # render site ANC meq/l
        output$plot2 <- renderPlot({
            ggplot(data = chemDataFrame[which(chemDataFrame$sampleType=="ANC"),], mapping = aes(x = titrationDate, y = ancMeqPerL)) +
                geom_point(aes(color = factor(sampleVolume))) +
                geom_line() +
                #meq/l thresholds from table
                geom_abline(slope = 0, intercept = 1, color = 'red') +
                geom_abline(slope = 0, intercept = 4, color = 'red') +
                geom_abline(slope = 0, intercept = 20, color = 'red') +
                labs(title = "Acid-neutralizing capacity, milliequivalents per liter",
                     x = "Titraton Date",
                     y = "ANC mEq/L") +
                theme_bw() +
                theme(legend.title = element_blank(),
                      text = element_text(size = 14),
                      axis.text.x = element_text(angle=45, vjust=1.0, hjust=1.0))
            
        })
        # render site ALK mg/l
        output$plot3 <- renderPlot({
            ggplot(data = chemDataFrame[which(chemDataFrame$sampleType=="ALK"),], mapping = aes(x = titrationDate, y = alkMgPerL)) +
                geom_point(aes(color = factor(sampleVolume))) +
                geom_line() +
                geom_abline(slope = 0, intercept = 50, color = 'red') +
                geom_abline(slope = 0, intercept = 200, color = 'red') +
                geom_abline(slope = 0, intercept = 1000, color = 'red') +
                labs(title = "Alkalinity, milligrams per liter",
                     x = "Titraton Date",
                     y = "ALK mg/L") +
                theme_bw() +
                theme(legend.title = element_blank(),
                      text = element_text(size = 14),
                      axis.text.x = element_text(angle=45, vjust=1.0, hjust=1.0))
            
        })
        # render site ANC mg/l
        output$plot4 <- renderPlot({
            ggplot(data = chemDataFrame[which(chemDataFrame$sampleType=="ANC"),], mapping = aes(x = titrationDate, y = ancMgPerL)) +
                geom_point(aes(color = factor(sampleVolume))) +
                geom_line() +
                geom_abline(slope = 0, intercept = 50, color = 'red') +
                geom_abline(slope = 0, intercept = 200, color = 'red') +
                geom_abline(slope = 0, intercept = 1000, color = 'red') +
                labs(title = "Acid-neutralizing capacity, milligrams per liter",
                     x = "Titraton Date",
                     y = "ANC mg/L") +
                theme_bw() +
                theme(legend.title = element_blank(),
                      text = element_text(size = 14), 
                      axis.text.x = element_text(angle=45, vjust=1.0, hjust=1.0))
        })
    })
}
# Run the app ----
shinyApp(ui = ui, server = server)
