library(tidyverse)
library(splashr)

my_url="https://www.flashscore.com/"

splash_svr=start_splash()
splash('localhost') %>% splash_active() # this takes a moment to get going

stop_splash(splash_svr) # later

##########################

splash('localhost') %>% render_html(my_url,wait=3) -> html
html %>% html_nodes('a') %>% html_text() -> 
