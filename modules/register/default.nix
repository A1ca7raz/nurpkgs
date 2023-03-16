{ ... }: 
{
  nixpkgs.overlays = [ self.overlay ];
  nix.settings = {
    substituters = [ meta.cache ];
    trusted-public-keys = [ meta.pubkey ];
  };
}