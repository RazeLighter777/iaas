resource "radarr_download_client_qbittorrent" "qbittorrent" {
  enable         = true
  priority       = 1
  name           = "qbittorrent"
  host           = "qbittorrent.${var.cluster_media_domain}"
  url_base       = "/"
  movie_category = "radarr"
  port           = var.ports["qbittorrent"]
  first_and_last = false
}

resource "radarr_naming" "media_naming_configs" {
  #include_quality            = false
  rename_movies              = true
  replace_illegal_characters = true
  #replace_spaces             = false
  colon_replacement_format = "dash"
  standard_movie_format    = "{Movie OriginalTitle} ({Release Year}) [{Quality Title} {MediaInfo VideoBitDepth}bit {MediaInfo VideoCodec} {MediaInfo VideoDynamicRangeType} {MediaInfo AudioLanguages} {MediaInfo AudioCodec} {MediaInfo AudioChannels} -{Release Group}]{imdb-{ImdbId}}{tmdb-{TmdbId}}{edition-{Edition Tags}}"
  movie_folder_format      = "{Movie Title} ({Release Year})"
}

resource "radarr_media_management" "media_settings_configs" {
  auto_unmonitor_previously_downloaded_movies = false
  recycle_bin                                 = ""
  recycle_bin_cleanup_days                    = 7
  download_propers_and_repacks                = "doNotPrefer"
  create_empty_movie_folders                  = false
  delete_empty_folders                        = true
  file_date                                   = "none"
  rescan_after_refresh                        = "always"
  auto_rename_folders                         = false
  paths_default_static                        = false
  set_permissions_linux                       = false
  chmod_folder                                = 777
  chown_group                                 = ""
  skip_free_space_check_when_importing        = true
  minimum_free_space_when_importing           = 100
  copy_using_hardlinks                        = true
  import_extra_files                          = true
  extra_file_extensions                       = "srt,nfo,png"
  enable_media_info                           = true
}

resource "radarr_root_folder" "root_folder" {
  path = "/media/movies"
}

resource "radarr_notification_discord" "media_discord" {
  on_grab                          = false
  on_download                      = true
  on_upgrade                       = true
  on_rename                        = false
  on_movie_added                   = false
  on_movie_delete                  = false
  on_movie_file_delete             = false
  on_movie_file_delete_for_upgrade = true
  on_health_issue                  = true
  on_application_update            = false

  include_health_warnings = false
  name                    = "Media Discord

  web_hook_url  = var.discord_media_webhook
  username      = "Radarr"
  avatar        = "https://static-00.iconduck.com/assets.00/radarr-icon-922x1024-esiz37v4.png"
  grab_fields   = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  import_fields = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
}
