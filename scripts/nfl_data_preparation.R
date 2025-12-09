# INSTALL PACKAGES (delete if already installed)
install.packages(c("tidyverse", "nflfastR", "DBI", "RMySQL"))

# LOAD PACKAGES
library(tidyverse)
library(nflfastR)
library(DBI)
library(RMySQL)

# SETTINGS
seasons <- 2018:2024   # Modify range if needed

# Output directory
output_path <- "Path"

# DOWNLOAD GAME DATA
pbp <- load_pbp(seasons)

# Convert to a simplified game-level table
games <- pbp %>%
  group_by(game_id, season, week, home_team, away_team) %>%
  summarize(
    home_score = max(total_home_score, na.rm = TRUE),
    away_score = max(total_away_score, na.rm = TRUE),
    winner = case_when(
      home_score > away_score ~ home_team,
      away_score > home_score ~ away_team,
      TRUE ~ "TIE"
    ),
    margin = home_score - away_score,
    total_points = home_score + away_score
  ) %>%
  ungroup()

# CREATE TEAMS TABLE
teams <- games %>%
  select(home_team) %>%
  rename(team = home_team) %>%
  distinct() %>%
  arrange(team)

# SAVE CSVs TO PROJECT FOLDER
write.csv(games, file.path(output_path, "games_cleaned.csv"), row.names = FALSE)
write.csv(teams, file.path(output_path, "teams.csv"), row.names = FALSE)
