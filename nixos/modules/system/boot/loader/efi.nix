{ utils, lib, ... }:

with lib;

{
  options.boot.loader.efi = utils.mkBootLoaderOption {
    enable = mkOption {
      default = false;
      internal = true;
    };

    canTouchEfiVariables = mkOption {
      default = false;
      type = types.bool;
      description = lib.mdDoc "Whether the installation process is allowed to modify EFI boot variables.";
    };

    efiSysMountPoint = mkOption {
      default = "/boot";
      type = types.str;
      description = lib.mdDoc "Where the EFI System Partition is mounted.";
    };
  };
}
