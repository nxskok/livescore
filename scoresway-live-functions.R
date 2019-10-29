get_game_info=function(my_url) {
  html <- read_html(my_url)
  html %>% html_nodes("h3") %>% 
    html_text() %>% 
    str_replace_all(.,"\n", "") %>% 
    str_trim() -> teams_score
  html %>% html_nodes("span.game-minute") %>% html_text() -> x
  minutes=ifelse(length(x)>0, x, "XX")
  v <- c(teams_score, minutes)
  names(v)=c("home", "score", "away", "mins")
  v
}

get_today=function(today_url="https://int.soccerway.com/") {
  read_html(today_url) %>% 
    html_nodes("a") %>% 
    html_attr("href") %>% as_tibble() %>% 
    filter(str_detect(value, "r[0-9]+/$")) %>% 
    mutate(match_txt=str_extract(value, "/r([0-9]+)/$")) %>% 
    mutate(id=parse_number(match_txt)) %>% 
    select(-match_txt) 
}


get_comps_now=function(matches, comp_urls) {
  matches %>% distinct(comp) %>% 
    left_join(comp_urls, by=c("comp"="id")) %>% 
    drop_na()
}


get_all_comp_games=function(matches, comp_lookup, comp_wanted) {
  comp_lookup %>% filter(comp==comp_wanted) %>% 
    pull(value) -> url0
  url <- str_c(base, url0) # base is actually in global environment
  print(str_c("getting games from ", url0))
  read_html(url) %>% html_nodes("a") %>% 
    html_attr("href") %>% as_tibble() %>% 
    filter(str_detect(value, "^/matches")) %>% 
    filter(str_detect(value, "/$")) %>% 
    mutate(x=str_extract(value, "/[0-9]+/$")) %>% 
    mutate(match_id=parse_number(x)) %>% 
    select(-x) %>% 
    distinct(value, match_id) -> match_lookup
  matches %>% left_join(match_lookup, by=c("match"="match_id")) %>% drop_na() %>% 
    mutate(full_url=str_c(base, value)) %>% 
    mutate(info=map(full_url, ~get_game_info(.))) %>% 
    select(-value, -full_url) %>% 
    mutate(t1=map_chr(info, "home"),
           t2=map_chr(info, "away"),
           score=map_chr(info, "score"),
           mins=map_chr(info, "mins"))
}


