### Send mail

library(pacman)

p_load(gmailr)

gm_auth_configure(path = Sys.getenv("GMAILR_OAUTH"))


attach_multiple <- function(mime, attachment, ...) {
  mime %>% 
    gmailr::gm_attach_file(attachment, ...)
}


attachments <- map_chr(update_ics$summary, ~paste0("ics_files/", 
                                                   str_remove_all(
                                                     str_replace(.x, "-", "_"),
                                                     " "), ".ics"))

test_email <- gm_mime() %>% 
  gm_to(secret_decrypt(Sys.getenv("DST_MAIL"), "FODBOLD_KEY")) %>%
  gm_subject("Sport næste måned") %>% 
  gm_text_body("Se vedhæftet") %>% 
  reduce(.init = ., .x = attachments, .f = attach_multiple)

gm_send_message(test_email)

