{
  lib,
  config,
  ...
}:
with lib; let
  name = "name";
  namespace = "namespace";

  cfg = config.${namespace}.${name};
in {
  options.${namespace}.${name} = {
    enable = mkEnableOption (mdDoc name);
  };

  config = mkIf cfg.enable {
    # ...
  };
}
