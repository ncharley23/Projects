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
  message_thread = messages %>% xml_attr("address")
)%>%

#identify the sender
mutate(who_sent_it= case_when(who_sent_it=="1" ~ person, 
                              who_sent_it=="2"~ "Me" ))

#showing you your unsaved numbers
df<-df%>%mutate(who_sent_it= case_when(str_detect(who_sent_it, "Unknown")==TRUE ~ message_thread,
                TRUE~who_sent_it))

#if the number is saved as a contact, it will connect you and the person as a thread of messages
df<-df%>%mutate(message_thread = case_when((str_detect(df$who_sent_it, '^[^+]+$')|is.na(df$who_sent_it))==TRUE& str_detect(person, fixed("("))!=TRUE~ person,
                                                   TRUE~message_thread))

#getting rid of your plus signs to group numbers that may be the same(i.e, +1234567890,1234567890)
df<-df%>%mutate(message_thread = gsub("\\+","",message_thread))


#select only what you need to see
my_messages<-df%>%select(who_sent_it,body, date_time,message_thread)

#mimicking an actual thread of conversation
my_messages<-my_messages%>%arrange(message_thread,date_time)
