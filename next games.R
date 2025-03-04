## Next games

get_next_matches <- function(team_id, sport = "football", 
                             base_url = "https://allsportsapi2.p.rapidapi.com/api", header){
  
  if(sport == "football") sport <- NULL
  
  t <- request(base_url) %>% 
    req_url_path_append(sport, "team", team_id, "matches", "next", "0") %>% 
    req_headers(!!!header) %>% 
    req_perform()
  
  t2 <- t %>% 
    resp_body_string() %>% 
    fromJSON() %>% 
    pluck("events") %>% 
    as_tibble() %>% 
    unnest(everything(), names_sep = "_")
  
  t2$sport <- t2$tournament_category$sport$name
  
  t2 %>% 
    select(sport, tournament_name, homeTeam_name, awayTeam_name, changes_changeTimestamp, startTimestamp) %>% 
    mutate(across(c(startTimestamp, changes_changeTimestamp), ~as_datetime(.x, tz = "CET")))
  
}



team_ids <- c(1281, 44, 34, 4860, 2673, 2556)

kalender <- tibble(cal = rep(list(NULL), length(team_ids)))

for(i in seq_along(team_ids)){
  
  kalender$cal[[i]] <- get_next_matches(team_ids[i], header = header)
  Sys.sleep(1)
  
}

rugby_id <- 4230

kalender <- rbind(kalender, nest(get_next_matches(rugby_id, sport = "rugby", header = header),
                                 .key = "cal"))

next_month <- kalender$cal %>%
  map(~filter(.x, startTimestamp < today() + 31)) %>% 
  bind_rows() %>% 
  mutate(end_time = startTimestamp + hours(2)) %>% 
  mutate(summary = paste(homeTeam_name, awayTeam_name, sep = " - "))


outdated_files <- map(list.files("ics_files", full.names = T), ic_read) %>% 
  set_names(list.files("ics_files", full.names = T)) %>% 
  as_tibble_col() %>% 
  mutate(fil = names(value)) %>% 
  mutate(outdated = map_int(value, ~nrow(filter(.x, DTSTART < now(tzone = "CET"))))) %>% 
  filter(outdated == 1) %>% 
  pull(fil)

## Delete files
unlink(outdated_files)

exist_ics <- map(paste0("ics_files/", list.files("ics_files")), ic_read) %>% 
  bind_rows() %>% 
  select(-any_of("UID")) %>% 
  rename_with(str_to_lower)

cat(paste0(exist_ics$summary, exist_ics$dtstart, collapse = ", "))

new_ics <- next_month %>%
  rename(dtstart = startTimestamp,
         dtend = end_time) %>%
  select(dtstart, dtend, summary) %>%
  mutate(class = "PRIVATE")

cat(paste0(new_ics$summary, new_ics$dtstart, collapse = ", "))


## TODO::: måske driller tidszonerne
if (nrow(exist_ics) > 0) {
  update_ics <- setdiff(new_ics, exist_ics)
}  else {
  update_ics <- new_ics
}

cat("\n\n\n", paste0(update_ics$summary, update_ics$dtstart, collapse = ", "))

# if (nrow(update_ics) > 1) {
#   for (i in 1:nrow(update_ics)){
# 
#     ic_event(start_time = update_ics$dtstart[i],
#              end_time = update_ics$dtend[i],
#              summary = update_ics$summary[i],
#              more_properties = TRUE,
#              event_properties = c("CLASS" = "PRIVATE")) %>%
#       ic_write(paste0("ics_files/", str_remove_all(
#         str_replace(update_ics$summary[i], "-", "_"),
#         " "), ".ics"))
# 
#   }
# }

