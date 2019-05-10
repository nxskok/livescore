library(rvest)
library(tidyverse)

my_url="http://www.livescores.com/"

# initial (once only)

d_new=score_table(read_html(my_url))

# update

while (1) {
  d_old=d_new
  d_new=update_scores(d_old,my_url)
  print(Sys.time())
  print(compare_scores(d_old,d_new))
  Sys.sleep(60*5)
}

#  15:55


###################################################################################
# functions
###################################################################################


update_scores=function(d_old,my_url) {
  html_new=read_html(my_url)
  d_new=score_table(html_new)
  d_new
}

compare_scores=function(d1,d2) {
  right_join(d1,d2,by=c("t1"="t1")) %>% 
    filter(score.x != score.y | (mins.x != "FT" & mins.y == "FT")) %>% 
    select(comp=title.x,mins=mins.y,t1,t2=t2.x,old=score.x,new=score.y)
}

score_table=function(html) {
  html %>% html_nodes('body > div > div.content') %>% html_nodes('div')  -> dd
  dd %>% html_attr('class') -> classes
  dd %>% html_text() -> texts
  tibble(class=classes,text=texts) %>% 
    mutate(title=ifelse(class=="left",text,NA)) %>% fill(title) %>% 
    filter(str_detect(class,"row-gray")) -> d4
  m=str_split(d4$text,"  ",simplify=T)
  d4 %>% mutate(mins=m[,2],t1=m[,3],score=m[,4],t2=m[,5]) %>% 
    filter(str_length(mins)<=10) %>% 
    select(-(class:text))
}
