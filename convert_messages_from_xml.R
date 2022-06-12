library(xml2)
library(dplyr)
library(rvest)

#once you've downloaded your file to your computer, replace my file path below with YOUR file path
messages <- read_xml('C:/Users/Owner/Downloads/sms-20190815211620.xml',options="HUGE") %>% 
  html_elements('sms')

#the rest will take care of itself
#grabbing your sms info from the XML file
df <- data.frame(
  person = messages %>% xml_attr("contact_name"),
  date_time = messages %>% xml_attr("readable_date"),
  body = messages %>% xml_attr("body"),
  number = messages %>% xml_attr("address")
)