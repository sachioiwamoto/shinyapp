library(shiny)
library(reshape2)
library(ggplot2)

# Read and cleanse data (Economy and Growth Topic)
data <- read.table("./3_Topic_en_csv_v2.csv", header = TRUE, sep = ",", skip = 1)
data <- data[, -c(59,60)]
colnames(data)[c(5:58)] <- c(1960:2013)

# average <- function(country, indicator, year) (function here)

# Define server logic required to plot various variables against mpg
shinyServer(function(input, output) {
    
    output$ocountry1 <- renderPrint({ input$country1 })
    output$ocountry2 <- renderPrint({ input$country2 })
    output$oindicator <- renderPrint({ input$indicator })
    output$ofrom <- renderPrint({ input$year[1] })
    output$oto <- renderPrint({ input$year[2] })
    
    tmpdat1 <- reactive({
        data[(data$Country.Name == input$country1 &
              data$Indicator.Name == input$indicator),]
    })
    tmpdat2 <- reactive({
        data[(data$Country.Name == input$country2 &
                  data$Indicator.Name == input$indicator),]
    })
    tmpdat3 <- reactive({
        t(rbind(tmpdat1(), tmpdat2()))[c((as.numeric(input$year[1])-1955):
                                     (as.numeric(input$year[2])-1955)),]
    })
    resultset <- reactive({
        ylist <- c((input$year[1]):(input$year[2]))
        temp <- as.data.frame(cbind(ylist, tmpdat3()))
        colnames(temp) <- c("Year", input$country1, input$country2)
        temp[, 1:3] <- sapply(temp[, 1:3], as.character)
        temp[, 1:3] <- sapply(temp[, 1:3], as.numeric)
        rownames(temp) <- NULL
        temp
    })

    meltedset <- reactive({
        melt(resultset(), id='Year')
    })
    
    fit1 = reactive({
        lm(resultset()[,c(2)] ~ poly(resultset()[,c(1)], 4), data = resultset())
    })
    fit2 = reactive({
        lm(resultset()[,c(3)] ~ poly(resultset()[,c(1)], 4), data = resultset())
    })
    
    output$plot <- renderPlot({
        gp = ggplot(meltedset(), 
                    aes(x=meltedset()[,c(1)], y=meltedset()[,c(3)], colour=meltedset()[,c(2)]),
                    environment=environment())
        gp = gp + geom_smooth(method = "lm", formula = y~poly(x, 4))
        gp = gp + geom_point(size=3, alpha=0.7)
        gp = gp + xlab("Year") + ylab(input$indicator)
        gp = gp + labs(colour="Countries")
        print(gp)
    })
    output$table <- renderDataTable({ resultset() })
    output$model1 <- renderPrint({ summary(fit1()) })
    output$model2 <- renderPrint({ summary(fit2()) })

})