### Send mail


try(
  gm_auth(token = gm_token_read(
    path = "setup_tok/gm_token.rds",
    key = "FODBOLD_KEY"
  ))
)


attach_multiple <- function(mime, attachment, ...) {
  mime %>% 
    gmailr::gm_attach_file(attachment, ...)
}


attachments <- map_chr(update_ics$summary, ~paste0("ics_files/", 
                                                   str_remove_all(
                                                     str_replace(.x, "-", "_"),
                                                     " "), ".ics"))

test_email <- gm_mime() %>% 
  gm_to(secret_decrypt("EoBIB9DK5t2Xwy4X8qAFNp8LiUyzoRavNp8", "FODBOLD_KEY")) %>%
  # gm_to(secret_decrypt("59FM83CiJC9ZZbrJqw3YufDeX7I8e5wNEk2mw-uHxQsgRjZebtg", "FODBOLD_KEY")) %>% 
  gm_subject("Sport næste måned") %>% 
  gm_text_body("Se vedhæftet", update_ics$summary) 
# %>% 
#   reduce(.init = ., .x = attachments, .f = attach_multiple)

gm_send_message(test_email)

