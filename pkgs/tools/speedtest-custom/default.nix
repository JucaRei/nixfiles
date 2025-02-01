{ createScript
, speedtest-cli
, iputils
, coreutils
, gnugrep
}:

createScript "speedtest-custom" ./speedtest-custom.sh {
  dependencies = [
    speedtest-cli
    iputils
    coreutils
    gnugrep
  ];

  meta.description = "shell utility to test ping and upload/download speeds";
}
