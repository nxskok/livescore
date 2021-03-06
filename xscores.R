library(tidyverse)
library(rvest)
library(curl)

library(splashr)

###################################################################################
# functions
###################################################################################

options(width=132)

get_table <- function(url) {
  splash('localhost') %>% render_html(url,wait=3) -> html
  html %>% html_table(fill=T,header=T) %>% .[[5]] -> stuff
  n=ncol(stuff)
  names(stuff)=1:n
  stuff %>% as.tibble() %>% 
    select(2,3,5,6,7,10,11,14:17) -> stuff2
  names(stuff2)=c("stat","mins","lg","team1","pos1","team2","pos2","ht","ft","et","pens")
  stuff2
}

compare=function(stuff_old, stuff_new) {
  stuff_old %>% mutate(key=str_c(team1, " - ", team2)) -> stuff_old
  stuff_new %>% mutate(key=str_c(team1, " - ", team2)) -> stuff_new
  
  stuff_old %>% left_join(stuff_new, by="key") %>% 
    mutate(score_x=str_c(ht.x,ft.x,et.x,pens.x,sep=":"),
           score_y=str_c(ht.y,ft.y,et.y,pens.y,sep=":"),
           is_goal=(score_y != score_x),
           pos1.y=ifelse(is.na(pos1.y),0,as.numeric(pos1.y)),
           pos2.y=ifelse(is.na(pos2.y),0,as.numeric(pos2.y))) %>%
    separate(ft.y,into=c("s1","s2"),sep="-", remove=F, extra="merge", fill="right") %>% 
    mutate(surprise=(pos2.y-pos1.y)*(as.integer(s1)-as.integer(s2)-0.5)) %>% 
    filter(score_x != score_y | stat.x != stat.y) %>% 
    select(stat.y:pos2.y,ft.y, ft.x, is_goal, score_y, surprise)  
}


my_url="http://old.xscores.com/soccer/livescores/"

killall_splash()
splash_svr=start_splash() # seems not to need sudo
Sys.sleep(10)
splash('localhost') %>% splash_active() # this takes a moment to get going. check it again.


stuff_new=get_table(my_url)
interval=5 # minutes

while(1) {
  stuff_old=stuff_new
  print(Sys.time())
  stuff_new=get_table(my_url)
  print(compare(stuff_old,stuff_new), n=Inf) # like compare_scores in livescore.R
  Sys.sleep(interval*60)
}


