resource "sonarr_download_client_qbittorrent" "qbittorrent" {
  enable         = true
  priority       = 1
  name           = "qbittorrent"
  host           = "qbittorrent.${var.cluster_media_domain}"
  url_base       = "/"
  tv_category     = "sonarr"
  port           = var.ports["qbittorrent"]
  first_and_last = false
}

resource "sonarr_naming" "media_naming_configs" {
  rename_episodes            = true
  replace_illegal_characters = true
  multi_episode_style        = 5 # Check if prefix range
  colon_replacement_format   = 4
  standard_episode_format    = "S{season:00}E{episode:00} - {Episode Title} [{Quality Title} {MediaInfo VideoBitDepth}bit {MediaInfo VideoCodec} {MediaInfo VideoDynamicRangeType} {MediaInfo AudioLanguages} {MediaInfo AudioCodec} {MediaInfo AudioChannels} {Preferred Words} -{Release Group}]{{imdb-{ImdbId}}}"
  daily_episode_format       = "{Air-Date} - {Episode Title} [{Quality Title} {MediaInfo VideoBitDepth}bit {MediaInfo VideoCodec} {MediaInfo VideoDynamicRangeType} {MediaInfo AudioLanguages} {MediaInfo AudioCodec} {MediaInfo AudioChannels} {MediaInfo SubtitleLanguages} {Preferred Words} -{Release Group}]{{imdb-{ImdbId}}}"
  anime_episode_format       = "S{season:00}E{episode:00} - {Episode Title} [{Quality Title} {MediaInfo VideoBitDepth}bit {MediaInfo VideoCodec} {MediaInfo VideoDynamicRangeType} {MediaInfo AudioLanguages} {MediaInfo AudioCodec} {MediaInfo AudioChannels} {Preferred Words} -{Release Group}]{{imdb-{ImdbId}}}"
  series_folder_format       = "{Series TitleYear}"
  season_folder_format       = "Season {season:00}"
  specials_folder_format     = "Season 00"
}

resource "sonarr_media_management" "media_settings_configs" {
  unmonitor_previous_episodes = true
  hardlinks_copy              = true
  create_empty_folders        = false
  delete_empty_folders        = true
  enable_media_info           = true
  import_extra_files          = true
  set_permissions             = false
  skip_free_space_check       = true
  minimum_free_space          = 100
  recycle_bin_days            = 7
  chmod_folder                = "777"
  chown_group                 = ""
  download_propers_repacks    = "doNotPrefer"
  episode_title_required      = "always"
  extra_file_extensions       = "srt,nfo,png"
  file_date                   = "none"
  recycle_bin_path            = ""
  rescan_after_refresh        = "always"
}

resource "sonarr_root_folder" "series" {
  path = "/media/tv"
}

resource "sonarr_root_folder" "anime" {
  path = "/media/anime"
}