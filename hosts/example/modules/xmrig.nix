{
  hostname,
  pkgs,
  ...
}:
{
  /*
    HugeTLB configuration

    128 x 2 MiB = 256 MiB reserved for HugeTLB.

    This is a safe starting point for a 4 GiB VPS.
    Avoid allocating 1 GiB hugepages on small systems,
    because they permanently reserve memory and can
    easily starve the normal memory allocator.
  */
  boot.kernel.sysctl = {
    "vm.nr_hugepages" = 128;
  };

  services.xmrig = {
    enable = true;
    package = pkgs.xmrig-mo;

    settings = {
      # Save runtime changes to the config file.
      autosave = true;

      # Run in foreground for easier debugging.
      # Change to true if you prefer daemon-style behavior.
      background = false;

      colors = true;

      randomx = {
        # Automatically initialize RandomX memory.
        init = -1;

        # Enable AVX2 when supported by the CPU.
        init-avx2 = true;

        # Let XMRig choose the best mode.
        mode = "auto";

        /*
          Disabled on 4 GiB systems.

          1 GiB hugepages are useful for performance,
          but reserving them on a small VPS usually
          causes more problems than benefits.
        */
        "1gb-pages" = false;

        /*
          These optimizations may be ignored by many VPS
          providers because MSR access is often restricted.
        */
        rdmsr = true;
        wrmsr = true;

        cache_qos = false;
        numavx2 = 0;
      };

      cpu = {
        enabled = true;

        /*
          Enable HugeTLB support.

          XMRig will try to use the reserved 2 MiB pages
          configured through vm.nr_hugepages.
        */
        huge-pages = true;

        hw-aes = null;

        /*
          Lower priority reduces the chance of impacting
          system responsiveness.
        */
        priority = 2;

        memory-pool = true;
        yield = true;

        /*
          Leave some CPU time for the OS.

          Uncomment if desired.
        */
        # max-threads-hint = 75;
      };

      opencl = false;
      cuda = false;

      pools = [
        {
          algo = "rx/0";

          url = "gulf.moneroocean.stream:20128";

          user = "YOUR_WALLET_ADDRESS";

          pass = hostname;

          keepalive = true;
          nicehash = false;
          tls = true;
          daemon = false;
        }
      ];
    };
  };
}
