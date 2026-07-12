{ pkgs, ... }:
let
  sharedEnv = {
    HOME = "/var/lib/ollama";
    OLLAMA_API_KEY = "xxxxxx";
    OLLAMA_HOST = "0.0.0.0:11434";
    OLLAMA_MODELS = "/var/lib/ollama/models";
    OLLAMA_KEEP_ALIVE = "-1";
  };
in
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    loadModels = [
      # "MrScratchcat22/AesCoder-4B:F16" # For web frontend coding (256K context)
      # "fredrezones55/qwen3.5-opus:9b-tooling" # general tasks (256K context)
      # "gemma4:e4b-it-q4_K_M" # daily tasks (128K context)
      # "glm-ocr:bf16" # ocr
      # "lfm2:24b-a2b" # fastest in these models (32K context)
      # "Maternion/strand-rust-coder:14b" # For Rust lang coding (32K context)
      # "medgemma1.5:4b" # vision
      # "nemotron-cascade-2:30b-a3b-q4_K_M" # reasoning (256K context)
      # "translategemma:12b" # translate
      # "yi-coder:9b" # For general coding
    ];
    user = "ollama";
    group = "ollama";
    environmentVariables = sharedEnv;
    host = "0.0.0.0";
    port = 11434;
    openFirewall = true;
  };

  # systemd.services.ollama-run = {
  #   description = "ollama run";
  #   after = ["ollama.service"];
  #   requires = ["ollama.service"];

  #   environment = sharedEnv;

  #   serviceConfig = {
  #     User = "ollama";
  #     Group = "ollama";
  #     DeviceAllow = [
  #       "char-nvidiactl"
  #       "char-nvidia-caps"
  #       "char-nvidia-frontend"
  #       "char-nvidia-uvm"
  #       "char-drm"
  #       "char-fb"
  #       "char-kfd"
  #       "/dev/dxg"
  #     ];
  #     DevicePolicy = "closed";

  #     LockPersonality = true;
  #     MemoryDenyWriteExecute = true;
  #     NoNewPrivileges = true;
  #     PrivateDevices = false;
  #     PrivateTmp = true;
  #     PrivateUsers = true;
  #     ProcSubset = "all";
  #     ProtectClock = true;
  #     ProtectControlGroups = true;
  #     ProtectHome = true;
  #     ProtectHostname = true;
  #     ProtectKernelLogs = true;
  #     ProtectKernelModules = true;
  #     ProtectKernelTunables = true;
  #     ProtectProc = "invisible";
  #     ProtectSystem = "strict";

  #     ReadWritePaths = [
  #       "/var/lib/ollama"
  #       "/var/lib/ollama/models"
  #     ];
  #     RemoveIPC = true;

  #     RestrictAddressFamilies = [
  #       "AF_INET"
  #       "AF_INET6"
  #       "AF_UNIX"
  #     ];
  #     RestrictNamespaces = true;
  #     RestrictRealtime = true;
  #     RestrictSUIDSGID = true;

  #     SystemCallArchitectures = "native";
  #     SystemCallFilter = [
  #       "@system-service @resources"
  #       "~@privileged"
  #     ];

  #     Type = "exec";
  #     UMask = "0077";
  #     WorkingDirectory = "/tmp";

  #     ExecStartPre = "+${pkgs.writeShellScript "ollama-pull-if-missing" ''
  #       if [ ! -f /var/lib/ollama/models/manifests/registry.ollama.ai/library/gemma4/e4b-it-q4_K_M ]; then
  #         echo "Model not found, pulling gemma4:e4b-it-q4_K_M..."
  #         ${pkgs.lib.getExe pkgs.ollama-cuda} pull gemma4:e4b-it-q4_K_M
  #       else
  #         echo "Model already exists, skipping pull."
  #       fi
  #     ''}";
  #     ExecStart = "${pkgs.lib.getExe pkgs.ollama-cuda} run gemma4:e4b-it-q4_K_M < /dev/null";

  #     Restart = "always";
  #     RestartSec = 5;

  #     StandardOutput = "journal";
  #     StandardError = "journal";
  #   };
  # };
}
