{ writeShellScriptBin, util-linux, procps, coreutils, systemdMinimal, ... }:
writeShellScriptBin "nixos-tweaker" ''
  #!/usr/bin/env bash

  # Automatic detection of the primary device
  device=$(${util-linux}/bin/lsblk -o NAME,TYPE -nr | awk '$2 == "disk" {print $1; exit}')

  # Check if a valid device was found
  if [ -z "$device" ]; then
      ${coreutils}/bin/echo "No valid device found."
      exit 1
  fi

  ${coreutils}/bin/echo "Detected device: $device"

  # Determine if the device is an SSD or HDD
  if [[ $(${coreutils}/bin/cat "/sys/block/$device/queue/rotational") -eq 1 ]]; then
      device_type="HDD"

      # Set the I/O scheduler to "deadline" for HDDs
      ${coreutils}/bin/echo -e "\e[97mSetting I/O scheduler to 'deadline' for $device\e[0m"
      ${coreutils}/bin/echo "deadline" | sudo tee "/sys/block/$device/queue/scheduler"

      # Set block read-ahead buffer for HDDs
      ${coreutils}/bin/echo -e "\e[97mSetting block read-ahead buffer to 2048 for $device\e[0m"
      sudo blockdev --setra 2048 "/dev/$device"
  else
      device_type="SSD"

      # Set the I/O scheduler to "none" for SSDs
      ${coreutils}/bin/echo -e "\e[97mSetting I/O scheduler to 'none' for $device\e[0m"
      ${coreutils}/bin/echo "none" | sudo tee "/sys/block/$device/queue/scheduler"

      # Enable TRIM (discard) for SSDs
      ${coreutils}/bin/echo -e "\e[97mEnabling TRIM for $device\e[0m"
      sudo ${util-linux}/bin/fstrim -v /
  fi

  # Get the total RAM
  total_ram=$(${procps}/bin/free -m | awk '/^Mem:/{print $2}')
  ${coreutils}/bin/echo -e "\e[93mDetected RAM: $total_ram MB\e[0m"

  # Set vm.dirty_ratio and vm.dirty_background_ratio based on RAM amount
  if [ "$total_ram" -gt 64000 ]; then
      swappiness=5
  elif [ "$total_ram" -gt 32000 ]; then
      swappiness=10
  elif [ "$total_ram" -gt 16000 ]; then
      swappiness=20
  elif [ "$total_ram" -gt 8000 ]; then
      swappiness=40
  else
      swappiness=60
  fi

  ${coreutils}/bin/echo -e "\e[93mSetting swappiness to $swappiness\e[0m"
  sudo ${procps}/bin/sysctl -w vm.swappiness=$swappiness

  # Reload systemd services to apply swappiness changes
  ${coreutils}/bin/echo -e "\e[93mReloading systemd services for swappiness changes\e[0m"
  sudo ${systemdMinimal}/bin/systemctl daemon-reload

  ${coreutils}/bin/echo "Configuration completed for $device (Device Type: $device_type)."

''
