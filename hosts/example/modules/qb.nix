{pkgs, ...}: {
  environment.etc."qb/qBittorrent/config/qBittorrent.conf" = {
    mode = "0755";
    text = ''
      [Application]
      FileLogger\Age=14
      FileLogger\AgeType=0
      FileLogger\Backup=true
      FileLogger\DeleteOld=true
      FileLogger\Enabled=true
      FileLogger\MaxSizeBytes=66560
      FileLogger\Path=/etc/qb/qBittorrent/data/logs
      MemoryWorkingSetLimit=1024

      [AutoRun]
      enabled=false
      program=

      [BitTorrent]
      Session\AddExtensionToIncompleteFiles=true
      Session\AddTorrentStopped=false
      Session\AddTrackersEnabled=true
      Session\DefaultSavePath=/var/lib/qb/downloads
      Session\ExcludedFileNames=
      Session\FinishedTorrentExportDirectory=
      Session\GlobalMaxInactiveSeedingMinutes=6000
      Session\GlobalMaxRatio=3
      Session\MaxActiveCheckingTorrents=1
      Session\MaxActiveDownloads=5
      Session\MaxActiveTorrents=10
      Session\MaxActiveUploads=5
      Session\MaxConnections=800
      Session\MaxUploadsPerTorrent=10
      Session\Port=56881
      Session\QueueingSystemEnabled=false
      Session\SSL\Port=56882
      Session\ShareLimitAction=Stop
      Session\TempPath=
      Session\TorrentExportDirectory=
      Session\TorrentStopCondition=MetadataReceived
      Session\UseAlternativeGlobalSpeedLimit=false
      Session\uTPRateLimited=false

      [Core]
      AutoDeleteAddedTorrentFile=Never

      [LegalNotice]
      Accepted=true

      [Meta]
      MigrationVersion=8

      [Network]
      PortForwardingEnabled=true
      Proxy\HostnameLookupEnabled=true
      Proxy\Profiles\BitTorrent=true
      Proxy\Profiles\Misc=true
      Proxy\Profiles\RSS=true

      [Preferences]
      Connection\PortRangeMin=56881
      Connection\UPnP=true
      Downloads\SavePath=/var/lib/qb/downloads
      Downloads\TempPath=
      General\Locale=zh_CN
      MailNotification\req_auth=true
      WebUI\Address=*
      WebUI\AlternativeUIEnabled=true
      WebUI\AuthSubnetWhitelist=@Invalid()
      WebUI\AuthSubnetWhitelistEnabled=false
      WebUI\Password_PBKDF2=""
      WebUI\RootFolder=${pkgs.vuetorrent}/share/vuetorrent
      WebUI\ServerDomains=*
      WebUI\SessionTimeout=360000
      WebUI\TrustedReverseProxiesList=127.0.0.1/8
      WebUI\Username=yzlab

      [RSS]
      AutoDownloader\DownloadRepacks=true
      AutoDownloader\SmartEpisodeFilter=s(\\d+)e(\\d+), (\\d+)x(\\d+), "(\\d{4}[.\\-]\\d{1,2}[.\\-]\\d{1,2})", "(\\d{1,2}[.\\-]\\d{1,2}[.\\-]\\d{4})"
    '';
  };

  services.qb = {
    dataDir = "/etc/qb";
    enable = true;
    openFirewall_webui = false;
    openFirewall_torrenting_port = true;
    webui_port = 18080;
    torrenting_port = 56881;
    # user = "root";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/qb/downloads 0755 root root - -"
  ];
}
