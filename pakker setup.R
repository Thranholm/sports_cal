## Pakker og api info

rm(list = ls())

library(pacman)
p_load(tidyverse, lubridate, httr, httr2, jsonlite, 
       devtools, janitor, stringr, calendar, gmailr)


base_url <- "https://allsportsapi2.p.rapidapi.com/api"

header <- c("X-RapidAPI-Host" = "allsportsapi2.p.rapidapi.com",
            "X-RapidAPI-Key" = secret_decrypt(Sys.getenv("PASS"), "FODBOLD_KEY"))


