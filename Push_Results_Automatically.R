#!/usr/bin/Rscript
# Sorry this isn't elegant but necessary for the cron tab to work
setwd("~/Projects/Students/Rogers-Rachel/ResponseType_Survey_Redo/")

# Set up authentication via ssh
cred <- git2r::cred_ssh_key("~/.ssh/id_rsa.pub", "~/.ssh/id_rsa")
repo <- git2r::repository()
git2r::config(repo = repo, global = F, "Susan-auto", "srvanderplas@gmail.com")

# Log job start
httr::POST("https://hc-ping.com/0753ce01-e1a2-4e63-a80d-97709492aa0c/start")

# Check repo status
status <- git2r::status()

tmp <- status$unstaged
modified <- names(tmp) == "modified"
modified <- unlist(tmp[modified])

# If db has been modified
if ("*.db" %in% modified | "*.sqlite" %in% modified) {
  
  # Add changed db to commit and commit
  git2r::add(repo = repo, "*.(db|sqlite)")
  git2r::add(repo = repo, path = "push_update.log")
  try(git2r::commit("*.db", message = "Update data"))
  
  # Copy database/codes to one drive
  file.copy("*.(db|sqlite)", file.path("/btrstorage", "OneDrive", "Data", "ResponseType_Survey_Redo"), overwrite = T)
  
  # Copy log files to one drive
  from <- list.files("/var/log/shiny-server", "Firearm-Response", full.names = T, recursive = T)
  to <- file.path("/btrstorage", "OneDrive", "Data", "ResponseType_Survey_Redo", "logs", "shiny-server", basename(from))
  file.copy(from, to, overwrite = F)
  
  
  # Copy log files to one drive
  from <- list.files("logs", "*", full.names = T)
  to <- file.path("/btrstorage", "OneDrive", "Data", "ResponseType_Survey_Redo", "logs", "user-session", basename(from))
  file.copy(from, to, overwrite = T, copy.mode = T, copy.date = T)
  
  # Update
  git2r::pull(repo = repo, credentials = cred)
  git2r::push(repo, credentials = cred)
  
  if (length(git2r::status()$unstaged$conflicted) > 0) {
    # Log merge conflict, signal failure (Susan gets an email)
    httr::POST("https://hc-ping.com/0753ce01-e1a2-4e63-a80d-97709492aa0c/fail", body = "Merge conflict")
  } else {
    # Log success
    httr::POST("https://hc-ping.com/0753ce01-e1a2-4e63-a80d-97709492aa0c", body = "Changes pushed")
  }
} else {
  # Log no changes
  httr::POST("https://hc-ping.com/0753ce01-e1a2-4e63-a80d-97709492aa0c", body = "No changes")
}

git2r::config(repo = repo, global = F, "Susan Vanderplas", "srvanderplas@gmail.com")
