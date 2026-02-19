{ lib, ... }:
{
  disko.devices = {
    disk.main = {
      device =
        let
          envDevice = builtins.getEnv "DISK_DEVICE";
        in
        if envDevice == "" then "/dev/sda" else envDevice;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
