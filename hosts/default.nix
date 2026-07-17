{
  hostname,
  inputs,
  ...
}:
{
  imports = with inputs; [
    ./${hostname}
    disko.nixosModules.disko
    hermes-agent.nixosModules.default
  ];
}
