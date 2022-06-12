
library(xmlconvert)
library(xml2)
library(xml)
library(XML)
library(tidyverse)
library(dplyr)
library(rvest)

rows <- read_xml('C:/Users/Owner/Downloads/sms-20190815211620.xml',options="HUGE") %>% 
  xml_nodes('sms')
df <- data.frame(
  person = rows %>% xml_attr("contact_name"),
  date_time = rows %>% xml_attr("readable_date"),
  body = rows %>% xml_attr("body"),
  number = rows %>% xml_attr("address")
)