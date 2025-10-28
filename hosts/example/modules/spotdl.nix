_: {
  environment.etc."spotdl/.spotdl/config.json" = {
    mode = "0777";
    text = ''
      {
          "client_id": "xxxxxx", # see https://developer.spotify.com/documentation/web-api/concepts/apps
          "client_secret": "xxxxxx",
          "auth_token": null,
          "user_auth": false,
          "headless": true,
          "cache_path": "/etc/spotdl/.spotdl",
          "no_cache": false,
          "max_retries": 3,
          "use_cache_file": false,
          "audio_providers": [
              "bandcamp",
              "piped",
              "soundcloud",
              "youtube",
              "youtube-music"
          ],
          "lyrics_providers": [
              "musixmatch",
              "genius",
              "azlyrics",
              "synced"
          ],
          "genius_token": "xxxxxx", # see https://docs.genius.com/#/getting-started-h1
          "playlist_numbering": false,
          "playlist_retain_track_cover": false,
          "scan_for_songs": false,
          "m3u": null,
          "output": "{title} - {artists}.{output-ext}",
          "overwrite": "skip",
          "search_query": null,
          "ffmpeg": "ffmpeg",
          "bitrate": "128k",
          "ffmpeg_args": null,
          "format": "mp3",
          "save_file": null,
          "filter_results": true,
          "album_type": null,
          "threads": 4,
          "cookie_file": null,
          "restrict": null,
          "print_errors": false,
          "sponsor_block": false,
          "preload": false,
          "archive": null,
          "load_config": true,
          "log_level": "INFO",
          "simple_tui": false,
          "fetch_albums": false,
          "id3_separator": "/",
          "ytm_data": false,
          "add_unavailable": false,
          "generate_lrc": false,
          "force_update_metadata": false,
          "only_verified_results": false,
          "sync_without_deleting": false,
          "max_filename_length": null,
          "yt_dlp_args": null,
          "detect_formats": null,
          "save_errors": null,
          "ignore_albums": null,
          "proxy": null,
          "skip_explicit": false,
          "log_format": null,
          "redownload": false,
          "skip_album_art": false,
          "create_skip_file": false,
          "respect_skip_file": false,
          "sync_remove_lrc": false,
          "web_use_output_dir": false,
          "port": 8800,
          "host": "localhost",
          "keep_alive": false,
          "enable_tls": false,
          "key_file": null,
          "cert_file": null,
          "ca_file": null,
          "allowed_origins": null,
          "keep_sessions": false,
          "force_update_gui": true,
          "web_gui_repo": null,
          "web_gui_location": null
      }
    '';
  };

  services.spotdl = {
    dataDir = "/etc/spotdl";
    enable = true;
    openFirewall = false;
    user = "root";
  };

  systemd.tmpfiles.rules = [
    "d /etc/spotdl/.spotdl 0777 root root - -"
  ];
}
