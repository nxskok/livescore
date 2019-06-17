library(tidyverse)
library(rvest)
library(curl)

library(splashr)

###################################################################################
# functions
###################################################################################

options(width=132)

one_row=function(v) {
  tibble(stat=v[2], mins=v[3], lg=v[5], team1=v[6],
         pos1=v[7], team2=v[10], pos2=v[11], ht=v[14], 
         ft=v[15], et=v[16], pens=v[17], scores=str_c(v[14:17], collapse=":"))
}

get_now=function(url) {
  splash('localhost') %>% render_html(my_url,wait=3, timeout = 60) -> html
  html %>% html_nodes("tr") -> rows
  rows %>% html_attr("class") %>% enframe() -> classes
  rows %>% map(~html_nodes(.,"td")) %>% map(~html_text(.)) -> table_data
  classes %>% as_tibble() %>% 
    separate(value, into=c("country", "id", "abb", "key", "league"), sep="#", convert=T) %>% 
    mutate(level=id) %>% 
    mutate(what=str_c(country, ": ", league, " (", level, ")")) %>% 
    select(what) -> whats
  table_data %>% map_df(~one_row(.)) -> scores
  scores %>% bind_cols(whats) %>% filter(!is.na(what)) %>% 
    select(what, stat, mins, team1, pos1, team2, pos2, ft, scores)
}

get_table <- function(url) {
  splash('localhost') %>% render_html(url,wait=3, timeout = 60) -> html # this is where safely/possibly goes
  html %>% html_table(fill=T,header=T) %>% .[[5]] -> stuff
  n=ncol(stuff)
  names(stuff)=1:n
  stuff %>% as.tibble() %>% 
    select(2,3,5,6,7,10,11,14:17) -> stuff2
  names(stuff2)=c("stat","mins","lg","team1","pos1","team2","pos2","ht","ft","et","pens")
  stuff2
}

safely_get_table=safely(get_table)
safely_get_now=safely(get_now)

my_url="http://old.xscores.com/soccer/livescores/"

killall_splash()
splash_svr=start_splash() # seems not to need sudo
Sys.sleep(10)
splash('localhost') %>% splash_active() # this takes a moment to get going. check it again.


interval=3 # minutes to wait after getting results
interval_error=0.5 # minutes to wait after getting error

while(1) {
  tt=Sys.time()
  tt2=as.character(tt)
  fname=str_c(tt,".rds")
  stuff=safely_get_now(my_url)
  if (is.null(stuff$error)) {
    print(c("OK", tt2))
    saveRDS(stuff$result,fname)
    Sys.sleep(interval*60)
  } else {
    print(c(stuff$error), tt2)
    Sys.sleep(interval_error*60)
  }
}


