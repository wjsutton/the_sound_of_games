library(dplyr)
library(spotifyr)

# Make sure environment variables for:
# - SPOTIFY_CLIENT_ID
# - SPOTIFY_CLIENT_SECRET
# are set with details from: https://developer.spotify.com/dashboard/applications
# Sys.setenv(SPOTIFY_CLIENT_ID = "", SPOTIFY_CLIENT_SECRET = "")

access_token <- get_spotify_access_token()

# Playlists
jd_unlimited <- '3h6KVYQxsAodohUghZDJDO'
jd_2021 <- '7FJTvsstftJVH5cFoM9N7v'
jd_2020 <- '5vhPL2ebJrWBhMo947QM7i'
jd_2019 <- '1VMWZRj1wQ7KjT5LXD7uYw'
jd_2018 <- '45gNptXte7zrUqQT8e3n3F'
jd_2017 <- '0Jx8rsyuUb0Gl0gssVqPw0'
jd_2016 <- '2f51x6ZuIMP4X3wf1v9Yda'
jd_2015 <- '14Xgl3uj4AZBpapviL4cwE'

get_track_artists <- function(df){
  track_artists <- c()
  
  for (i in 1:nrow(df)){
    len <- length(df$track.artists[[i]]$name)
    
    if(len == 1){
      track_artist <- df$track.artists[[i]]$name[1]
    }
    if(len == 2){
      track_artist <- paste0(df$track.artists[[i]]$name[1],' & ',df$track.artists[[i]]$name[2])
    }
    if(len == 3){
      track_artist <- paste0(df$track.artists[[i]]$name[1],', ',df$track.artists[[i]]$name[2],' & ',df$track.artists[[i]]$name[3])
    }
    
    if(len > 3){
      track_artist <- 'Various Artists'
    }
    
    track_artists <- c(track_artists,track_artist)
    
  }
  return(track_artists)
  
}

cols_to_keep <- c('track.id','track.name','track.explicit','track.duration_ms','track.popularity','track.album.name','track.album.release_date','track.album.release_date_precision','track.external_urls.spotify')
game_order <- c('Unlimited','2021','2020','2019','2018','2017','2016','2015')
game_order <- paste0('Just Dance ',game_order)
game_playlists <- c(jd_unlimited,jd_2021,jd_2020,jd_2019,jd_2018,jd_2017,jd_2016,jd_2015)

for(game in 1:length(game_playlists)){
  tracks <- get_playlist_tracks(game_playlists[game])
  tracks$track.artist <- get_track_artists(tracks)
  tracks <- tracks[,c(cols_to_keep,'track.artist')]
  tracks$game <- game_order[game]
  
  if(game == 1){
    df <- tracks
  }
  
  if(game > 1){
    df <- rbind(df,tracks)
  }
  Sys.sleep(3)
  
}


for (t in 1:nrow(df)){
  features_df <- get_track_audio_features(df$track.id[t])
  features_df <- features_df[,1:11]
  
  if (t == 1){
    feat_df <- features_df
  }
  
  if (t > 1){
    feat_df <- rbind(feat_df,features_df)
  }
  
  Sys.sleep(3)
  
}

output_df <- cbind(df,feat_df)

write.csv(output_df,'just_dance_playlist_data.csv',row.names = F)






