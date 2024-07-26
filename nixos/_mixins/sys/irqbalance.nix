{ config, ... }: {
  services = {
    irqbalance = {
      enable = !config.boot.isContainer;
    };
  };
}
