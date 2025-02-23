## Pakker og api informationer

rm(list = ls())

library(pacman)
p_load(tidyverse, lubridate, httr, httr2, jsonlite, 
       devtools, janitor, stringr)


base_url <- "https://allsportsapi2.p.rapidapi.com/api"

header <- c("X-RapidAPI-Host" = "allsportsapi2.p.rapidapi.com",
            "X-RapidAPI-Key" = secret_decrypt(Sys.getenv("PASS"), "FODBOLD_KEY"))


## Find hold

find_team_id <- function(team_name, sport = "football",
                         base_url = "https://allsportsapi2.p.rapidapi.com/api", header){
  
  if(sport == "football") sport <- NULL
  
  team <- request(base_url) %>% 
    req_url_path_append(sport, "search", team_name) %>% 
    req_headers(!!!header) %>% 
    req_perform() %>% 
    resp_body_json()
    
  team %>% 
    # .$result %>% 
    as_tibble_col() %>% 
    unnest_longer(value) %>%
    unnest_wider(value) %>% 
    unnest_wider(entity, names_repair = "unique", names_sep = "_") %>% 
    filter(type == "team" & entity_gender == "M") %>% 
    filter(entity_userCount == max(entity_userCount)) %>% 
    select(entity_id, entity_name)
}


hold <- c("Brøndby", "Liverpool", "Royale%20Union", "Dortmund", "Mainz")

for(i in hold){
  
  out <- find_team_id(i, header = header)
  Sys.sleep(1)
  print(out)
  
}

find_team_id("Scotland", sport = "rugby", header = header)








  