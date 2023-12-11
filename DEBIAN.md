# Debian specific system configuration

## Bootloader

I try to keep Debian as default as possible, having said that grub has been
replaced with systemd-boot because I've run into issues with grub where
loading the initial ramdisk has caused an out of memory error, rending the
whole system unbootable.. which is not ideal.

To address this:
"apt install systemd-boot"
`bootctl install` (you may get an error writing EFI vars if you don't have
secureboot enabled, this is fine)
`kernel-install add \`uname -r\` /boot/vmlinuz-\`uname -r\`` this adds your
current linux kernel as an entry to boot from.
Reboot, check it works and then `apt-get purge grub-common` (also removes config)

