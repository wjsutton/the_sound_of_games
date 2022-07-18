### IMDB extract
library(dplyr)
library(stringr)

# function that will fetch and extract imdb datasets from IMDB
# More details here: https://www.imdb.com/interfaces/
imdbTSVfiles <- function(fileName){
  url <- paste0("https://datasets.imdbws.com/",fileName,".tsv.gz")
  tmp <- tempfile()
  download.file(url, tmp)
  
  assign(fileName,
         readr::read_tsv(
           file = gzfile(tmp),
           col_names = TRUE,
           quote = "",
           na = "\\N"),
         envir = .GlobalEnv)
}

# extract imdb datasets
imdbTSVfiles("title.basics")
imdbTSVfiles("title.principals")
imdbTSVfiles("title.ratings")
imdbTSVfiles("name.basics")

# Find video games
video_game_df <- filter(title.basics,titleType == "videoGame")

# join datasets to find cast, names and game ratings
video_game_df <- inner_join(video_game_df,title.principals, by = "tconst")
video_game_df <- left_join(video_game_df,title.ratings, by = "tconst")
video_game_df <- inner_join(video_game_df,name.basics, by = "nconst")

# filter for actors (i.e. voice actors)
voice_actors <- video_game_df$primaryProfession %>% str_subset(pattern = "actor|actress")
video_game_df <- filter(video_game_df,primaryProfession %in% voice_actors)

# write data locally
write.csv(video_game_df,"video_game_voice_actors.csv",row.names = F)

