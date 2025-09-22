{
  hostname,
  inputs,
  ...
}: {
  imports = with inputs; [
    ./${hostname}
    chaotic.nixosModules.default
    disko.nixosModules.disko
  ];
}
