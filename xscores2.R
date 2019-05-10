library(tidyverse)
library(rvest)
library(curl)

library(splashr)

###################################################################################
# functions
###################################################################################

options(width=132)

get_table <- function(url) {
  splash('localhost') %>% render_html(url,wait=3) -> html # this is where safely/possibly goes
  html %>% html_table(fill=T,header=T) %>% .[[5]] -> stuff
  n=ncol(stuff)
  names(stuff)=1:n
  stuff %>% as.tibble() %>% 
    select(2,3,5,6,7,10,11,14:17) -> stuff2
  names(stuff2)=c("stat","mins","lg","team1","pos1","team2","pos2","ht","ft","et","pens")
  stuff2
}

safely_get_table=safely(get_table)

my_url="http://old.xscores.com/soccer/livescores/"

killall_splash()
splash_svr=start_splash() # seems not to need sudo
Sys.sleep(10)
splash('localhost') %>% splash_active() # this takes a moment to get going. check it again.


interval=2 # minutes

while(1) {
  tt=Sys.time()
  print(tt)
  fname=str_c(tt,".rds")
  stuff=safely_get_table(my_url)
  if (is.null(stuff$error)) {
    saveRDS(stuff$result,fname)
  }
  Sys.sleep(interval*60)
}


