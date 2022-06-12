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
  who_sent_it = messages %>% xml_attr("type"),
  who_is_being_spoken_to = messages %>% xml_attr("address")
)%>%

#identify the sender
mutate(who_sent_it= case_when(who_sent_it=="1" ~ person, 
                              who_sent_it=="2"~ "Me" ))

#case did not work with other cases but still identifying send
df<-df%>%mutate(who_sent_it= case_when(str_detect(who_sent_it, "Unknown")==TRUE ~ who_is_being_spoken_to,
                TRUE~who_sent_it))

df<-df%>%mutate(who_is_being_spoken_to = gsub("\\+","",who_is_being_spoken_to))


#select only what you need to see
my_messages<-df%>%select(who_sent_it,body, date_time,who_is_being_spoken_to)

#mimicking an actual thread of conversation
my_messages<-my_messages%>%arrange(who_is_being_spoken_to,date_time)
