library(gdata)
library(ggplot2)

activeInfWindow <- function(testMat, mu, budget, beta0, beta1) {
  muP = as.data.frame(matrix(0,nrow=nrow(testMat), ncol = ncol(testMat)-1))
  b0= cbind(beta0,beta0)
  b1= cbind(beta1,beta1)
  #budget= 5
  st = 0
  for(j in (1: ncol(muP)) ) {
    if(j==1) {
      muP[,1]= mu[,1]
    } else {
      muP[,j]= b0[,j] + b1[,j]* muP[,(j-1)]   # compute mean(mu) prediction matrix
    }
    en = (st+budget) %% 50
    
    if(en == (st+budget)) {
      for(k in (st+1):(st+budget)) {
        muP[k,j]= testMat[k,j+1]
      }
    } 
    else {
      for(k in (st+1):50) {
        muP[k,j] = testMat[k,j+1]
        
      }
      for(k in 1 : en) {
        muP[k,j] = testMat[k,j+1]
      }
    }
    st = (st+budget) %% 50
  }  
  cbind(testMat[,1], muP)
}

activeInfVariance<- function(testMat, mu, var,budget, beta0, beta1) {
  #  varP[,j]= varP[,j] + (betaParams$Beta1)^2 * varP[,j-1]    # compute variance prediction matrix
  vTemp = cbind(var,var)
  varP= as.data.frame(matrix(0,nrow=nrow(testMat), ncol = ncol(testMat)-1))
  vMat = as.data.frame(matrix(0,nrow=nrow(testMat), ncol = ncol(testMat)-1))
  b0= cbind(beta0,beta0)
  b1= cbind(beta1,beta1)
  
  for(j in 1:ncol(varP)) {
    #sortedVar =  sort(varMat[,j], decreasing = TRUE) 
    #varMAt takes values var, varHumidity
    if(j==1) {
      varP[,1]= mu[,1]
      vMat[,1] = vTemp[,1]
    } else {
      #varP[,j]= betaParams$Beta0 + betaParams$Beta1* varP[,(j-1)]   # compute mean(mu) prediction matrix
      #vMat[,j] = vTemp[,j] + ((betaParams$Beta1)^2)*vMat[,j-1]
      varP[,j]= b0[,j] + b1[,j]* varP[,(j-1)]   # compute mean prediction matrix
      vMat[,j] = vTemp[,j] + ((b1[,j])^2)*vMat[,j-1]
    }
    if(budget > 0) {
      highVarList =  which (vMat[,j] >= sort(vMat[,j], decreasing = TRUE)[budget], arr.ind= TRUE)
      for(i in 1:budget) {
        varP[highVarList[i],j] = testMat[highVarList[i],j+1]
        vMat[highVarList[i],j] = 0
      }
    }
  }
  cbind(testMat[,1], varP)
}

#compute Beta Parameters 
computeBetaParams<- function(dataMat) {
  # for each sensor at each time there'll be three values for Xprev, Xnxt
  mat  = as.data.frame(matrix(1,nrow = 3, ncol = 2)) 
  colnames(mat)= c("Xprev", "Xnxt")
  
  #compute only 2 to 47 columns of beta0,beta1 matrices
  numCols= round(ncol(dataMat)/3)
  beta0  = as.data.frame(matrix(0,nrow = nrow(dataMat), ncol = numCols))
  beta1  = as.data.frame(matrix(0,nrow = nrow(dataMat), ncol =numCols))
  
  for(i in 1:50 ) {
    for(j in 2:(numCols) ) {
      mat[1,]= c( dataMat[i,j], dataMat[i,j+1] )
      mat[2,]= c( dataMat[i,(j+numCols)], dataMat[i,(j+numCols+1)] )
      mat[3,]= c( dataMat[i,(j+(numCols*2))], dataMat[i,(j+1+(numCols*2))] )
      
      model= lm(mat[,1]~mat[,2])
      beta0[i,j]= coef(model)[1] #  Intercept
      beta1[i,j]= coef(model)[2] #  Slope
    }
  }
  c(beta0,beta1)
}

meanAbsoluteError<- function(realised, predicted) {
  #compute and return meanAbsoluteError
  # value in realised will be tempTestData or humTestData
  errorMat = abs (realised[,2:ncol(realised)] - predicted[,2:ncol(predicted)] ) 
  meanError= sum(errorMat)/ (nrow(errorMat)*ncol(errorMat))
  meanError
}

setwd("D:/IIT IITerm/cs583/MyProject")

tempDataMat <- read.table("dataset\\intelLabDataProcessed\\intelTemperatureTrain.csv", sep=",", header=TRUE)
tempTestMat <- read.table("dataset\\intelLabDataProcessed\\intelTemperatureTest.csv", sep=",", header=TRUE)

humData<- read.table("dataset\\intelLabDataProcessed\\intelHumidityTrain.csv", sep=",", header=TRUE)
humTestData <- read.table("dataset\\intelLabDataProcessed\\intelHumidityTest.csv", sep=",", header=TRUE)

# compute mean and variance for temperature dataset
tempDay1 <- as.matrix(tempDataMat[,2:49])
tempDay2 <- as.matrix(tempDataMat[,50:97])
tempDay3 <- as.matrix(tempDataMat[,98:145])
muTemp = (tempDay1 + tempDay2 + tempDay3)/3
varTemp= ((tempDay1 - muTemp)^2 +(tempDay2 - muTemp)^2 +(tempDay3 - muTemp)^2) / 3

# compute mean and variance for humidity dataset
humDay1 <- as.matrix(humData[,2:49])
humDay2 <- as.matrix(humData[,50:97])
humDay3 <- as.matrix(humData[,98:145])
muHum = (humDay1 + humDay2 + humDay3)/3
varHum= ((humDay1 - muHum)^2 +(humDay2 - muHum)^2 +(humDay3 - muHum)^2) / 3

budgetList = c(0,5,10,20,25)
errorTempWindow= c()
errorTempVar = c()
errorHumWindow = c()
errorHumVar = c()

# Phase2- Model 2 (stationary day wise)
for(i in budgetList) {
  budget = i
  betasTemp= computeBetaParams(tempDataMat)
  b0Temp=  matrix(unlist(betasTemp[1:48]), ncol = 48, byrow = FALSE)
  b1Temp=  matrix(unlist(betasTemp[49:96]), ncol = 48, byrow = FALSE)
  
  ## Section 1- mean for temperature dataset 
  forecastTempWindow =  activeInfWindow(tempTestMat, muTemp, budget,b0Temp, b1Temp)
  #write.csv(forecastTempWindow, file = paste("phase2/results/temperature/d-w",budget,".csv", sep=""),row.names=FALSE)
  errTempWin = meanAbsoluteError(tempTestMat, forecastTempWindow)
  errorTempWindow = c(errorTempWindow, errTempWin)
  write.csv(errorTempWindow, file = paste("phase2/Temperr/M2P2-temp-win",budget,".csv", sep=""),row.names=FALSE)
  
  ## Section 2- Variance for temperature dataset
  forecastTempVar =  activeInfVariance(tempTestMat, muTemp, varTemp,budget,b0Temp, b1Temp)
  #write.csv(forecastTempVar , file = paste("phase2/results/temperature/d-v",budget,".csv",sep=""),row.names=FALSE)
  
  errTmpVar = meanAbsoluteError (tempTestMat, forecastTempVar)
  errorTempVar = c(errorTempVar, errTmpVar)
  write.csv(errorTempVar, file = paste("phase2/Temperr/M2P2-temp-var",budget,".csv", sep=""),row.names=FALSE)
  
  
  ## Section 3 SAME AS SECTION 1- mean for humidity dataset
  betasHum= computeBetaParams(humData)
  b0Hum=  matrix(unlist(betasHum[1:48]), ncol = 48, byrow = FALSE)
  b1Hum=  matrix(unlist(betasHum[49:96]), ncol = 48, byrow = FALSE)
  
  forecastHumWindow =  activeInfWindow(humTestData, muHum, budget, b0Hum,b1Hum)
  #write.csv(forecastHumWindow, file = paste("phase2/results/humidity/d-w",budget,".csv", sep=""),row.names=FALSE)
  
  errHumWin = meanAbsoluteError (humTestData, forecastHumWindow)
  errorHumWindow = c(errorHumWindow, errHumWin)
  write.csv(errorHumWindow, file = paste("phase2/humerr/M2P2-hum-win",budget,".csv", sep=""),row.names=FALSE)
  
  ## Section 4 SAME AS SECTION 2- Variance for humidity dataset
  forecastHumVar =  activeInfVariance(humTestData, muHum, varHum,budget, b0Hum,b1Hum)
  #write.csv(forecastHumVar, file = paste("phase2/results/humidity/d-v",budget,".csv",sep=""),row.names=FALSE)
  
  errHumVar = meanAbsoluteError (humTestData, forecastHumVar)
  errorHumVar = c(errorHumVar, errHumVar)
  write.csv(errorHumVar, file = paste("phase2/humerr/M2P2-hum-var",budget,".csv", sep=""),row.names=FALSE)
  
}

#make bar plots using the error lists created above
barplot(errorTempWindow, main="Data=Temperature ; ActInf=Window", names.arg= budgetList,col=c("darkblue"),
         ylim=c(0,10),xlab="Budget",ylab="Mean Abs Error")
barplot(errorTempVar, main="Data=Temperature ; ActInf=Variance", 
        names.arg=budgetList,col=c("red"), ylim=c(0,10),xlab="Budget",ylab="Mean Abs Error")
barplot(rbind(errorTempWindow,errorTempVar), main="Data=Temperature", 
        names.arg=budgetList,col=c("darkblue","red"),beside = TRUE, 
        legend=c("Window","Variance"), ylim=c(0,10),xlab="Budget",ylab="Mean Abs Error")

barplot(errorHumWindow, main="Data=Humidity ; ActInf=Window", 
        names.arg=budgetList,col=c("darkblue"), ylim=c(0,25),xlab="Budget",ylab="Mean Abs Error")

barplot(errorHumVar, main="Data=Humidity ; ActInf=Variance", names.arg=budgetList,col=c("red"),
        ylim=c(0,25),xlab="Budget",ylab="Mean Abs Error")
barplot(rbind(errorHumWindow,errorHumVar), main="Data=Humidity", names.arg=budgetList,col=c("darkblue","red"),
        beside = TRUE, legend=c("Window","Variance"), 
        ylim=c(0,25),xlab="Budget",ylab="Mean Abs Error")

budgetError=cbind(budgetList,errorTempWindow,errorTempVar,errorHumWindow,errorHumVar)
colnames(budgetError)=c("Budget","Ph2M2_Temp_W","Ph2M2_Temp_V","Ph2M2_Hum_W","Ph2M2_Hum_V")
write.csv(budgetError, file ="phase2/Temperr/P2M2.csv",row.names=FALSE)
