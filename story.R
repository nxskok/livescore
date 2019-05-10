# this runs in background, gathering new scores every so often
library(rvest)
library(tidyverse)

score_table=function(html) {
  html %>% html_nodes('body > div > div.content') %>% html_nodes('div')  -> dd
  dd %>% html_attr('class') -> classes
  dd %>% html_text() -> texts
  tibble(class=classes,text=texts) %>% 
    mutate(title=ifelse(class=="left",text,NA)) %>% fill(title) %>% 
    separate(title, into=c("country", "league"), sep="-") %>% 
    filter(str_detect(class,"row-gray")) -> d4
  m=str_split(d4$text,"  ",simplify=T)
  d4 %>% mutate(mins=m[,2],t1=m[,3],score=m[,4],t2=m[,5]) %>% 
    filter(str_length(mins)<=10) %>% 
    select(-(class:text))
}

update_scores=function(my_url) {
  html_new=read_html(my_url)
  d_new=score_table(html_new)
  d_new %>% mutate(timestamp=Sys.time(),key=str_c(t1," - ",t2))
}

my_url="http://www.livescores.com/"

while (TRUE) { # runs forever until stopped
  xx=update_scores(my_url)
  if (file.exists("d.rds")) {
    d=readRDS("d.rds")
    d=bind_rows(d,xx)
  }  else {
    d=xx
  }
  saveRDS(d,"d.rds")
  Sys.sleep(2*60) # 2 minutes
}