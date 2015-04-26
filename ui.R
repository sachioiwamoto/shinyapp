library(shiny)

# Define Indicators in scope
inames <- c("Primary income payments (BoP, current US$)",
            "Imports of goods and services (BoP, current US$)",
            "Exports of goods and services (BoP, current US$)",
            "Foreign direct investment, net inflows (BoP, current US$)",
            "Total reserves (includes gold, current US$)",
            "General government final consumption expenditure (current US$)",
            "Gross national expenditure (current US$)",
            "Agriculture, value added (current US$)",
            "Manufacturing, value added (current US$)",
            "Industry, value added (current US$)",
            "Services, etc., value added (current US$)",
            "GDP (current US$)",
            "Gross domestic savings (current US$)",
            "Gross national expenditure (current US$)")

# Read and Cleanse Metadata_Indicator
meta_i <- read.table("./Metadata_Indicator_3_Topic_en_csv_v2.csv", header = TRUE, sep = ",")
meta_i <- meta_i[meta_i$INDICATOR_NAME %in% as.factor(inames),c(1,2)]
colnames(meta_i) <- c("Indicator.Code","Indicator.Name")
rownames(meta_i) <- NULL

# Read and cleanse Metadata_Country
meta_c <- read.table("./Metadata_Country_3_Topic_en_csv_v2.csv", header = TRUE, sep = ",")
colnames(meta_c)[1] <- c("Country.Name")

# Define UI for miles per gallon application
shinyUI(
    pageWithSidebar(
        
        # Application title
        headerPanel("World Economic & Growth"),

        sidebarPanel(
            h3('How to use'),
            p('This application shows various economic data such as Gross Domestic Product
               (GDP) for many countries in the world in the form of table and plot based on
               simple regression models so you can compare the trends between the two countries. 
               Please select two countries and one economic data item from the drop down menu
               below and specify the year range.'),
            h3('Input Form'),
            selectInput('country1', 'Country1', 
                        as.character(meta_c$Country.Name), selected = "Canada"),
            selectInput('country2', 'Country2', 
                        as.character(meta_c$Country.Name), selected = "United States"),
            selectInput('indicator', 'Economic Data', 
                        as.character(meta_i$Indicator.Name), selected = "GDP (current US$)"),
            sliderInput('year', 'Year Range', min=1960, max=2013, 
                        value=c(2000, 2013), step=1, round=0)
        ),
        
        mainPanel(
            tabsetPanel(type = "tabs", 
                        tabPanel("Your Input", 
                                 h4('Selected first country is:'),
                                 verbatimTextOutput("ocountry1"),
                                 h4('Selected second country is:'),
                                 verbatimTextOutput("ocountry2"),
                                 h4('Selected indicator is:'),
                                 verbatimTextOutput("oindicator"),
                                 h4('Selected year range is:'),
                                 h5('From'),
                                 verbatimTextOutput("ofrom"),
                                 h5('To'),
                                 verbatimTextOutput("oto")),
                        tabPanel("Plot", plotOutput('plot')),
                        tabPanel("Data Table", dataTableOutput(outputId="table")),
                        tabPanel("Model Summary", 
                                 h4('Model Summary for country1 is:'),
                                 verbatimTextOutput("model1"),
                                 h4('Model Summary for country2 is:'),
                                 verbatimTextOutput("model2"))
            )
        )
    )
)