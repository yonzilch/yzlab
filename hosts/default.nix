{
  hostname,
  inputs,
  ...
}: {
  imports = with inputs; [
    ./${hostname}
    disko.nixosModules.disko
  ];
}
