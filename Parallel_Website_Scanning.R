rm(list=ls())

#Libraries needed/relevant to running the script

library(openssl)

library(readxl)

library("tidyverse")

library(dplyr)

library(xlsx)

library(openxlsx)

library(plumber)

library(sys)

library(foreach)

library(doParallel)

library(doSNOW)

library(flock)

library(future)

library(R.utils)

#library(plotly)

# library(progress)

# library(tcltk)

# library(svMisc)



# USPersonalExpenditure <- data.frame("Categorie"=rownames(USPersonalExpenditure), USPersonalExpenditure)

# data <- USPersonalExpenditure[,c('Categorie', 'X1960')]

# 

# p <- plot_ly(data, labels = ~Categorie, values = ~X1960, type = 'pie') %>%

#  layout(title = 'United States Personal Expenditures by Categories in 1960',

#     xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),

#     yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))



#Storing the list of websites from an excelsheet and a specific column into a variable

my_data <-as.data.frame(read_excel("C:\\Users\\OneDrive\\Documents\\Certs-Expiring.xlsx", sheet = 1, col_types = c("text","skip","date")))



#Getting rid of any duplicate websites

my_data<-unique(my_data)



#creating variable to store contents of my nmap scan

nmap_scan<- data.frame()



#changing data frame to characters because download_ssl_cert only takes strings for host argument

nmap_scan <- as.data.frame.character(nmap_scan)



#Removing the file in order to start with a brand new file later on

#system(paste("rm -f Book2.csv"))








results <- setNames(data.frame(matrix(ncol = 5, nrow = 0)), c("Common Name","Expiration Date", "Website Expiration Date", "Port#", "Status"))





#creating 8 different cores to get the script to run in parallel to optimize speed

cluster = makeCluster(detectCores() ,outfile ="")



#cluster = makeForkCluster(8, outfile = "")





#register the cluster(needed to run the cluster)

registerDoSNOW(cluster)



#register the cluster(needed to run the cluster)

#registerDoParallel(cluster)





#foreach loop that allows the operation to run for each element at the same time thanks to dopar

#System.time checks how long the script takes to run









#f<-foreach(i = 1:50,.inorder=FALSE, .combine = rbind) %dopar% {

  

f <-foreach(i = 1:50,.combine = rbind , .inorder=FALSE, .packages = c('sys','doSNOW' , 'openxlsx', 'future', 'R.utils','flock','openssl','readxl','tidyverse','dplyr','xlsx','plumber', 'doParallel')) %dopar% {

 

  

 cat("Starting I=",as.character(i), "Loop", collapse="\n")

  

 #scans websites in held in my_data for 100 most common open ports

  nmap_scan<-system(paste("nmap -F -Pn --open --defeat-rst-ratelimit", toString(my_data[i,1])), intern = TRUE)

  

  #regex string manipulation that extracts the ports from the results of my nmap_scan by matching all digits that have a "/" following it but excludes the scans that take forever

  extract_ports<-na.omit(str_extract(nmap_scan, "(^(?!22|80|135|49152|49153|49154|49155|49156|111|1720|1025|1026|1027|1028|1029))([0-9]+(?=/))"))

  

 exp_dates= as.Date( as.POSIXct(my_data[i,2], format="%Y %m %d %H:%M:%S"))

  

 #condition that ignores websites that don't currently have any ports to connect to

  if(!length(extract_ports)==0){

  

 #debugging checks

 print(my_data[i,1])

 print(extract_ports)

 print(length(extract_ports))

  

 #inner loop that checks the connection between a specific website and its different ports

  for(j in seq_along(extract_ports)){

  

 #debugging check

  cat("Starting J=",as.character(j), "Loop", collapse="\n")

  

 #debugging check

  print(as.integer(extract_ports[j]))

  

 

  

 #trycatch that prevents stopping of my program in case a website and a port don't have a certificate

 tryCatch( {  certs<- download_ssl_cert(my_data[i,1], port = as.integer(extract_ports[j]))} 

      , error = function(e) {})

  

  

 # nmap_sum <- na.omit(nmap_sum)

  

 #print(colMeans(nmap_sum[1,1]))

  

  

 #if a website and port doesn't have a certificate, it moves to the next element(port in this case) to check for a certificate 

 if(exists("certs")){

  #debugging check

  print("Let's' see!")

   

  #grabbing the cert's beginning and end dates

  expires=as.list(certs[[1]])$validity

   

  #formatting the date into a format readable for the user by doing string manipulation

   

  expires = as.Date( as.POSIXct(as.character(expires), format="%b %d %H:%M:%S %Y"))

  print(format(expires[2], "%m/%d/%Y"))

   

  #if the cert's date is less than the date of your choosing, print it to csv file

  #  if(expires[2]<(as.Date(Sys.Date())+90)){

   

  #debugging check

   

  if(expires[2]<"2020-04-01"){

   status ="bad"

  }else {

   status ="good"

  }

  results <- rbind(data.frame("Common Name"=my_data[i,1], "Expiration Date"=format(my_data[i,2], "%m/%d/%Y"), "Website Expiration Date"= format(expires[2], "%m/%d/%Y"), "Port#"= as.integer(extract_ports[j]), "Status"= status))

   

   

   cat(as.character(my_data[i,1]), ",",format(my_data[i,2], "%m/%d/%Y") ,",", format(expires[2], "%m/%d/%Y"), "," , extract_ports[j], ",", status, append = TRUE, collapse="\n")

   

  #writes website, expiration date, and port to a csv file that'll be viewable in Excel

   cat(as.character(my_data[i,1]), ",",format(my_data[i,2], "%m/%d/%Y") ,",", format(expires[2], "%m/%d/%Y"), "," , extract_ports[j], ",", status, file="Book2.csv", append = TRUE, collapse="\n")

   

  #  }

 }

  

 print("Exiting Loop")

 }

  

 # results

 }

 return(results)

}





# p <- test %>% group_by(Status) %>%

#  summarize(count = n()) %>%plot_ly(labels = ~Status, values = ~count, type = 'pie') %>%

#  layout(title = 'United States Personal Expenditures by Categories in 1960',

#     xaxis = list(showgrid = TRUE, zeroline = FALSE, showticklabels = TRUE),

#     yaxis = list(showgrid = TRUE, zeroline = FALSE, showticklabels = FALSE))

# 

# p



#print(mean(nmap_sum$V1))

# duration<-nmap_sum$V1



# print(mean(duration))





#closes connection

stopCluster(cluster)



