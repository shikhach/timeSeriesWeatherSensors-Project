library(gdata)

activeInfWindowP1 <- function(testData, mu, budget) {
  #mu will take values muTemp or muHum AND testData will take values tempTestData or humTestData  
  result= cbind(mu,mu)
  st = 0
  for(j in 2:ncol(testData)) {
    en = (st+budget) %% 50
    if(en == (st+budget)) {
      for(k in (st+1) : (st+budget)) {
        result[k,j-1]= testData[k,j]
      }
    } else {
      for(k in (st+1) : 50) {
        result[k,j-1] = testData[k,j]
      }
      for(k in 0 : en) {
        result[k,j-1] = testData[k,j]
      }
      
    }
    st = (st+budget) %% 50
    
  }  
  cbind(testData[,1], result)
}

activeInfVarianceP1 <- function(testData, mu, budget, varMat) {
  varResult= cbind(mu,mu)
  vMat = cbind(varMat,varMat)
  for(j in 2:ncol(testData)) {
    #sortedVar =  sort(varMat[,j], decreasing = TRUE) 
    #varMAt takes values varTemp, varHumidity
    if(budget > 0) {
      highVarList =  which (vMat[,j-1] >= sort(vMat[,j-1], decreasing = TRUE)[budget], arr.ind= TRUE)
      for(i in 1:budget) {
        varResult[highVarList[i],j-1] = testData[highVarList[i],j]
      }
    }
  }
  cbind(testData[,1], varResult)
}

meanAbsoluteErrorP1<- function(realised, predicted) {
  #compute and return meanAbsoluteErrorP1
  #value in predicted will be muTemp or muHum
  errorMat = abs (realised[,2:ncol(realised)] - predicted[,2:ncol(predicted)] ) # value in realised will be tempTestData or humTestData
  meanError= sum(errorMat)/ (nrow(errorMat)*ncol(errorMat))
  meanError
}

setwd("D:/IIT IITerm/cs583/MyProject")

humData = read.table("dataset\\intelLabDataProcessed\\intelHumidityTrain.csv", sep=",", header=TRUE)
humTestData = read.table("dataset\\intelLabDataProcessed\\intelHumidityTest.csv", sep=",", header=TRUE)
tempData <- read.table("dataset\\intelLabDataProcessed\\intelTemperatureTrain.csv", sep=",", header=TRUE)
tempTestData <- read.table("dataset\\intelLabDataProcessed\\intelTemperatureTest.csv", sep=",", header=TRUE)


#create tempDay1(50 X 48) , tempDay2(50 X 48) , tempDay3(50 X 48)
tMat <- as.matrix(tempData)
tempDay1 <- as.matrix(tMat[,2:49])
tempDay2 <- as.matrix(tMat[,50:97])
tempDay3 <- as.matrix(tMat[,98:145])

#For 'temperature' calculate Mean and Variance
muTemp = (tempDay1 + tempDay2 + tempDay3)/3
varTemp= ((tempDay1 - muTemp)^2 +(tempDay2 - muTemp)^2 +(tempDay3 - muTemp)^2) / 3

#For 'humidity' calculate Mean and Variance
hMat <- as.matrix(humData)
humDay1 <- as.matrix(hMat[,2:49])
humDay2 <- as.matrix(hMat[,50:97])
humDay3 <- as.matrix(hMat[,98:145])
muHum = (humDay1 + humDay2 + humDay3)/3
varHum= ((humDay1 - muHum)^2 +(humDay2 - muHum)^2 +(humDay3 - muHum)^2) / 3

budgetList = c(0,5,10,20,25)
errorTempWindowP1= c()
errorTempVarP1 = c()
errorHumWindowP1 = c()
errorHumVarP1 = c()

for(i in budgetList) {
  budget = i
  ## Section 1 
  forecastTempWindowP1 =  activeInfWindowP1(tempTestData, muTemp, budget)
  #write.csv(forecastTempWindowP1, file = paste("Phase1Final/results/temperature/w",budget,".csv", sep=""),row.names=FALSE)
  errTempWin = meanAbsoluteErrorP1 (tempTestData, forecastTempWindowP1)
  errorTempWindowP1 = c(errorTempWindowP1, errTempWin)
  ## Section 2
  forecastTempVarP1 =  activeInfVarianceP1(tempTestData, muTemp, budget, varTemp)
  #write.csv(forecastTempVarP1   , file = paste("Phase1Final/results/temperature/v",budget,".csv",sep=""),row.names=FALSE)
  errTmpVar = meanAbsoluteErrorP1 (tempTestData, forecastTempVarP1)
  errorTempVarP1 = c(errorTempVarP1, errTmpVar)
  ## Section 3 SAME AS SECTION 1 FOR HUMIDITY
  forecastHumWindowP1 =  activeInfWindowP1(humTestData, muHum, budget)
  #write.csv(forecastHumWindowP1, file = paste("Phase1Final/results/humidity/w",budget,".csv", sep=""),row.names=FALSE)
  errHumWin = meanAbsoluteErrorP1 (humTestData, forecastHumWindowP1)
  errorHumWindowP1 = c(errorHumWindowP1, errHumWin)
  ## Section 4 SAME AS SECTION 2 FOR HUMIDITY
  forecastHumVarP1 =  activeInfVarianceP1(humTestData, muHum, budget, varHum)
  #write.csv(forecastHumVarP1   , file = paste("Phase1Final/results/humidity/v",budget,".csv",sep=""),row.names=FALSE)
  errHumVar = meanAbsoluteErrorP1(humTestData, forecastHumVarP1)
  errorHumVarP1 = c(errorHumVarP1, errHumVar)
  
#   write.csv(errorHumVarP1, file = paste("phase2/humerr/P1-hum-var",budget,".csv", sep=""),row.names=FALSE)
#   write.csv(errorHumWindowP1, file = paste("phase2/humerr/P1-hum-win",budget,".csv", sep=""),row.names=FALSE)
#   write.csv(errorTempVarP1, file = paste("phase2/Temperr/P1-temp-var",budget,".csv", sep=""),row.names=FALSE)
#   write.csv(errorTempWindowP1, file = paste("phase2/Temperr/P1-temp-win",budget,".csv", sep=""),row.names=FALSE)
}

#make for bar plots using the error lists created as above
barplot(errorTempWindowP1, main="Data=Temperature ; ActInf=Window", names.arg=budgetList,col=c("darkblue"), ylim=c(0,1.6),xlab="Budget",ylab="Mean Abs Error")
barplot(errorTempVarP1, main="Data=Temperature ; ActInf=Variance", names.arg=budgetList,col=c("red"), ylim=c(0,1.6),xlab="Budget",ylab="Mean Abs Error")
barplot(rbind(errorTempWindowP1,errorTempVarP1), main="Data=Temperature", names.arg=budgetList,col=c("darkblue","red"),beside = TRUE, legend=c("Window","Variance"), ylim=c(0,1.6),xlab="Budget",ylab="Mean Abs Error")

barplot(errorHumWindowP1, main="Data=Humidity ; ActInf=Window", names.arg=budgetList,col=c("darkblue"), ylim=c(0,5),xlab="Budget",ylab="Mean Abs Error")
barplot(errorHumVarP1, main="Data=Humidity ; ActInf=Variance", names.arg=budgetList,col=c("red"), ylim=c(0,5),xlab="Budget",ylab="Mean Abs Error")
barplot(rbind(errorHumWindowP1,errorHumVarP1), main="Data=Humidity", names.arg=budgetList,col=c("darkblue","red"),beside = TRUE, legend=c("Window","Variance"), ylim=c(0,5),xlab="Budget",ylab="Mean Abs Error")
budgetError=cbind(budgetList,errorTempWindowP1,errorTempVarP1,errorHumWindowP1,errorHumVarP1)
colnames(budgetError)=c("Budget","Ph1_Temp_W","Ph1_Temp_V","Ph1_Hum_W","Ph1_Hum_V")
write.csv(budgetError, file ="phase2/Temperr/P1.csv",row.names=FALSE)

## Relation Between temperature and humidity
# listTemp = unlist(tempTestData[,2:97])
# listHum = unlist(humTestData[,2:97])
# plot(listTemp, listHum, main="Humidity Vs Temperature", xlab="Temperature ", ylab="Humidity ", pch=1,col="blue")
