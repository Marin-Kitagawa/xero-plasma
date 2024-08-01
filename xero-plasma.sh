#!/usr/bin/env bash

##################################################################################################################
# Author : DarkXero
# Website : https://xerolinux.xyz
# To be used in Arch-Chroot (After installing Base packages via ArchInstall)
##################################################################################################################

# Check if dialog is installed, if not, install it
if ! command -v dialog &> /dev/null; then
  echo "dialog is not installed. Installing dialog..."
  pacman -S --noconfirm dialog
fi

# Function to install packages
install_packages() {
  packages=$1
  pacman -S --needed --noconfirm $packages
}

# Function to selectively install packages
selective_install() {
  packages=$1
  pacman -S --needed $packages
}

# Main menu using dialog
main_menu() {
  CHOICE=$(dialog --stdout --title ">> XeroLinux Plasma Install <<" --menu "\nChoose how to install Plasma:" 15 60 4 \
    1 "Minimal  : Minimal install (Older PCs)." \
    2 "Complete : Full Plasma install (All Packages)." \
    3 "Curated  : Xero's Curated set of Plasma packages." \
    4 "Selective: Individual package selection (Advanced).")

  case "$CHOICE" in
    1)
      install_packages "plasma-meta konsole kate dolphin ark plasma-workspace egl-wayland flatpak-kcm breeze-grub spectacle dolphin-plugins falkon nano"
      systemctl enable sddm.service
      ;;
    2)
      install_packages "nano kf6 qt6 plasma-meta kde-applications-meta kdeconnect packagekit-qt6 kde-cli-tools kdeplasma-addons plasma-activities polkit-kde-agent flatpak-kcm bluedevil glib2 ibus kaccounts-integration kscreen libaccounts-qt plasma-nm plasma-pa scim extra-cmake-modules kaccounts-integration kdoctools libibus wayland-protocols plasma-applet-window-buttons plasma-workspace appmenu-gtk-module kwayland-integration plasma5-integration xdg-desktop-portal-gtk"
      systemctl enable sddm.service
      ;;
    3)
      install_packages "appmenu-gtk-module ark audiotube bluedevil breeze breeze-grub breeze-gtk colord-kde dolphin dolphin-plugins drkonqi elisa emoji-font extra-cmake-modules falkon ffmpegthumbs flatpak-kcm gcc-libs glib2 glibc gpsd gwenview ibus icu intltool jq kaccounts-integration kamera kate kauth kbookmarks kcalc kcharselect kcmutils kcodecs kcolorchooser kcompletion kconfig kconfigwidgets kcoreaddons kcrash kcron kdbusaddons kde-applications-meta kde-cli-tools kde-gtk-config kdebugsettings kdeclarative kdeconnect kdegraphics-thumbnailers kdenetwork-filesharing kdeplasma-addons kdf kdialog kdoctools keditbookmarks keysmith kf6 kfind kget kglobalaccel kgpg kguiaddons khelpcenter ki18n kiconthemes kimagemapeditor kinfocenter kio kio-admin kio-extras kio-gdrive kio-zeroconf kirigami kirigami-addons kitemmodels kitemviews kjobwidgets kmenuedit knewstuff knotifications knotifyconfig kolourpaint konsole kpackage kpipewire krecorder krunner kscreen kservice ksshaskpass ksvg ksystemlog kwayland-integration kweather kwidgetsaddons kwindowsystem kxmlgui libaccounts-qt libcanberra libibus libksysguard libplasma libx11 libxcb libxcursor libxi libxkbcommon libxkbfile markdownpart nano networkmanager-qt ocean-sound-theme okular oxygen oxygen-sounds p7zip packagekit packagekit-qt6 pim-data-exporter pim-sieve-editor plasma-activities plasma-activities-stats plasma-applet-window-buttons plasma-browser-integration plasma-desktop plasma-integration plasma-meta plasma-nm plasma-pa plasma-pass plasma-systemmonitor plasma-wayland-protocols plasma-workspace plasma-workspace-wallpapers plasma5-integration plasma5support plasmatube polkit-kde-agent powerdevil qqc2-breeze-style qt5-x11extras qt6 qt6-3d qt6-5compat qt6-base qt6-charts qt6-connectivity qt6-declarative qt6-graphs qt6-grpc qt6-httpserver qt6-imageformats qt6-languageserver qt6-location qt6-lottie qt6-multimedia qt6-networkauth qt6-positioning qt6-quick3d qt6-quick3dphysics qt6-quickeffectmaker qt6-quicktimeline qt6-remoteobjects qt6-scxml qt6-sensors qt6-serialbus qt6-serialport qt6-shadertools qt6-speech qt6-svg qt6-tools qt6-translations qt6-virtualkeyboard qt6-wayland qt6-webchannel qt6-webengine qt6-websockets qt6-webview quota-tools scim sddm-kcm sdl2 solid sonnet spectacle svgpart systemsettings ttf-joypixels unrar unzip wayland wayland-protocols xcb-util-keysyms xdg-desktop-portal-gtk xdg-desktop-portal-kde xdg-user-dirs xf86-input-libinput xmlstarlet yakuake zip"
      systemctl enable sddm.service
      ;;
    4)
      selective_install "nano kf6 qt6 plasma-meta kde-applications-meta kdeconnect packagekit-qt6 kde-cli-tools kdeplasma-addons plasma-activities polkit-kde-agent flatpak-kcm bluedevil glib2 ibus kaccounts-integration kscreen libaccounts-qt plasma-nm plasma-pa scim extra-cmake-modules kaccounts-integration kdoctools libibus wayland-protocols plasma-applet-window-buttons plasma-workspace appmenu-gtk-module kwayland-integration plasma5-integration xdg-desktop-portal-gtk kde-pim-meta kde-system-meta kde-gtk-config"
      systemctl enable sddm.service
      ;;
    *)
      if [ "$CHOICE" == "" ]; then
        clear
        exit 0
      else
        dialog --msgbox "Invalid option. Please select 1, 2, 3, or 4." 10 40
        main_menu
      fi
      ;;
  esac
}

# Display main menu
main_menu

echo "Installing PipeWire packages..."
install_packages "gstreamer gst-libav gst-plugins-bad gst-plugins-base gst-plugins-ugly gst-plugins-good libdvdcss alsa-utils alsa-firmware pavucontrol lib32-pipewire-jack libpipewire pipewire-v4l2 pipewire-x11-bell pipewire-zeroconf realtime-privileges sof-firmware ffmpeg ffmpegthumbs ffnvcodec-headers"

echo "Installing Bluetooth packages..."
install_packages "bluez bluez-utils bluez-plugins bluez-hid2hci bluez-cups bluez-libs bluez-tools"
systemctl enable bluetooth.service

echo "Adding support for OS-Prober"
install_packages "os-prober"
sed -i 's/#\s*GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' '/etc/default/grub'
os-prober
grub-mkconfig -o /boot/grub/grub.cfg

echo "Installing other useful applications..."
install_packages "linux-headers pacman-contrib meld timeshift elisa mpv gnome-disk-utility btop gum inxi"

if dialog --stdout --title "Add XeroLinux Repo & Install Toolkit" --yesno "\nWould you like to add the XeroLinux repository and install Paru & the Xero-Toolkit?\n\nIt is recommended as it will make things like driver and package configuration easier." 12 50; then
  echo "Adding XeroLinux Repository..."
  echo -e '\n[xerolinux]\nSigLevel = Optional TrustAll\nServer = https://repos.xerolinux.xyz/$repo/$arch' | tee -a /etc/pacman.conf
  sed -i '/^\s*#\s*\[multilib\]/,/^$/ s/^#//' /etc/pacman.conf
  echo "Installing Paru/Toolkit..."
  pacman -Syy --noconfirm xlapit-cli
fi

dialog --title "Installation Complete" --msgbox "\nInstallation Complete. Done, now exit and reboot.\n\nFor further customization, if you opted to install our Toolkit, please find it in AppMenu under System or by typing xero-cli in terminal." 12 50

# Exit chroot and reboot
clear
echo "Type exit to exit chroot environment and reboot system..."
sleep 3
