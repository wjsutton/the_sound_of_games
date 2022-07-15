library(dplyr)
library(spotifyr)

# Make sure environment variables for:
# - SPOTIFY_CLIENT_ID
# - SPOTIFY_CLIENT_SECRET
# are set with details from: https://developer.spotify.com/dashboard/applications

access_token <- get_spotify_access_token()

vct <- read.csv("vice_city_tracklist.csv",stringsAsFactors = F)
names(vct)[1] <- 'tracklist_id'

for (i in 1:length(vct$track_id)){
  track_df <- get_track(vct$track_id[i])
  features_df <- get_track_audio_features(vct$track_id[i])
  
  entry <- data.frame(vct[i,],stringsAsFactors = F)
  entry$artist_name <- track_df$artists$name[1]
  entry$artist_id <- track_df$artists$id[1]
  entry$track_name <- track_df$name
  entry$track_popularity <- track_df$popularity
  entry$track_explicit <- track_df$explicit
  entry$track_duration <- track_df$duration_ms
  entry$spotify_url <- track_df$external_urls$spotify[1]
  
  entry <- cbind(entry,features_df[,1:11])
  
  if (i == 1){
    df <- entry
  }
  
  if (i > 1){
    df <- rbind(df,entry)
  }
  Sys.sleep(3)
  
}

write.csv(df,'vice_city_playlist_data.csv',row.names = F)