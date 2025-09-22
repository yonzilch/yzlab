{pkgs, ...}: {
  environment.etc."qb/qBittorrent/config/qBittorrent.conf" = {
    mode = "0755";
    text = ''
      [Application]
      FileLogger\Age=7
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
      Session\AddTrackersEnabled=false
      Session\AdditionalTrackers=
      Session\AlternativeGlobalDLSpeedLimit=1024
      Session\AlternativeGlobalUPSpeedLimit=1024
      Session\DHTEnabled=false
      Session\DefaultSavePath=/hdd/torrent/downloads
      Session\ExcludedFileNames=
      Session\FinishedTorrentExportDirectory=/hdd/torrent/downloads/.Saved
      Session\GlobalMaxInactiveSeedingMinutes=15000
      Session\GlobalMaxRatio=10
      Session\IncludeOverheadInLimits=true
      Session\LSDEnabled=false
      Session\MaxActiveCheckingTorrents=1
      Session\MaxActiveDownloads=5
      Session\MaxActiveTorrents=10
      Session\MaxActiveUploads=5
      Session\MaxConnections=800
      Session\MaxConnectionsPerTorrent=200
      Session\MaxUploads=30
      Session\MaxUploadsPerTorrent=10
      Session\PeXEnabled=false
      Session\Port=46881
      Session\QueueingSystemEnabled=false
      Session\SSL\Enabled=true
      Session\SSL\Port=46882
      Session\ShareLimitAction=Stop
      Session\TempPath=
      Session\TorrentExportDirectory=
      Session\TorrentStopCondition=MetadataReceived
      Session\UseAlternativeGlobalSpeedLimit=false
      Session\uTPRateLimited=true

      [Core]
      AutoDeleteAddedTorrentFile=Never

      [LegalNotice]
      Accepted=true

      [Meta]
      MigrationVersion=8

      [Network]
      Cookies=
      PortForwardingEnabled=false
      Proxy\HostnameLookupEnabled=false
      Proxy\Profiles\BitTorrent=true
      Proxy\Profiles\Misc=true
      Proxy\Profiles\RSS=true

      [Preferences]
      Connection\PortRangeMin=46881
      Connection\UPnP=false
      Downloads\SavePath=/hdd/torrent/downloads
      Downloads\TempPath=/hdd/torrent/downloads/temp
      General\Locale=zh_CN
      MailNotification\req_auth=true
      WebUI\Address=*
      WebUI\AlternativeUIEnabled=true
      WebUI\AuthSubnetWhitelist=@Invalid()
      WebUI\AuthSubnetWhitelistEnabled=false
      WebUI\HostHeaderValidation=true
      WebUI\LocalHostAuth=true
      WebUI\Password_PBKDF2=""
      WebUI\ReverseProxySupportEnabled=true
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

  networking.firewall = {
    allowedTCPPorts = [46882];
    allowedUDPPorts = [46882];
  };

  services.qb = {
    dataDir = "/etc/qb";
    enable = true;
    openFirewall_webui = false;
    openFirewall_torrenting_port = true;
    webui_port = 28080;
    torrenting_port = 46881;
    user = "root";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/qb/downloads 0755 root root - -"
  ];
}
