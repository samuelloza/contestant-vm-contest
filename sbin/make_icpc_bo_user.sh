#!/bin/sh

logger -p local0.info "make_icpc_bo_user: Create a new icpcbo user"

# Create icpcbo account
useradd -m icpcbo

# Setup desktop background
sudo -Hu icpcbo dbus-run-session gsettings set org.gnome.desktop.background picture-options 'centered'
sudo -Hu icpcbo dbus-run-session gsettings set org.gnome.desktop.background picture-uri 'file:///opt/icpcbo/misc/icpcbo-wallpaper.png'
sudo -Hu icpcbo dbus-run-session gsettings set org.gnome.desktop.background picture-uri-dark 'file:///opt/icpcbo/misc/icpcbo-wallpaper.png'
sudo -Hu icpcbo dbus-run-session gsettings set org.gnome.desktop.background primary-color '#000000'
sudo -Hu icpcbo dbus-run-session gsettings set org.gnome.desktop.background secondary-color '#000000'

sudo -Hu icpcbo dbus-run-session gsettings set org.gnome.shell enabled-extensions "['add-username-ext', 'stealmyfocus-ext']"
sudo -Hu icpcbo dbus-run-session gsettings set org.gnome.shell disable-user-extensions false
# Favorites (apps in sidebar): Removed yelp (help function),
# added terminal from UI, and queried resulting setting.
sudo -Hu icpcbo dbus-run-session gsettings set org.gnome.shell favorite-apps "['firefox_firefox.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop']"
sudo -Hu icpcbo dbus-run-session gsettings set org.gnome.desktop.session idle-delay 900
sudo -Hu icpcbo dbus-run-session gsettings set org.gnome.desktop.screensaver lock-delay 30

if [ -f /opt/icpcbo/config/screenlock ]; then
	sudo -Hu icpcbo dbus-run-session gsettings set org.gnome.desktop.screensaver lock-enabled true
else
	sudo -Hu icpcbo dbus-run-session gsettings set org.gnome.desktop.screensaver lock-enabled false
fi

# Keyboard layout stuff
mkdir /home/icpcbo/Desktop
cp /usr/share/applications/gnome-keyboard-panel.desktop /home/icpcbo/Desktop
cp /opt/icpcbo/misc/cms.desktop /home/icpcbo/Desktop
chmod +x /home/icpcbo/Desktop/gnome-keyboard-panel.desktop
chmod +x /home/icpcbo/Desktop/cms.desktop
chown icpcbo:icpcbo -R /home/icpcbo/Desktop
sudo -Hu icpcbo dbus-run-session gio set /home/icpcbo/Desktop/gnome-keyboard-panel.desktop metadata::trusted true
sudo -Hu icpcbo dbus-run-session gio set /home/icpcbo/Desktop/cms.desktop metadata::trusted true
sudo -Hu icpcbo dbus-run-session gsettings set org.gnome.shell.extensions.ding start-corner top-left

# set default fullname and shell
chfn -f "icpcbo Contestant" icpcbo
chsh -s /bin/bash icpcbo

# Update path
echo 'PATH=/opt/icpcbo/bin:$PATH' >> ~icpcbo/.bashrc
echo "alias icpcboconf='sudo /opt/icpcbo/bin/icpcboconf.sh'" >> ~icpcbo/.bashrc
echo "alias icpcboexec='sudo /opt/icpcbo/bin/icpcboexec.sh'" >> ~icpcbo/.bashrc
echo "alias icpcbobackup='sudo /opt/icpcbo/bin/icpcbobackup.sh'" >> ~icpcbo/.bashrc
echo 'TZ=$(cat /opt/icpcbo/config/timezone)' >> ~icpcbo/.profile
echo 'export TZ' >> ~icpcbo/.profile

# Mark Gnome's initial setup as complete
sudo -Hu icpcbo bash -c 'mkdir -p ~/.config'
sudo -Hu icpcbo bash -c 'echo yes > ~/.config/gnome-initial-setup-done'

sudo -Hu icpcbo bash -c 'mkdir -p ~icpcbo/.local/share/gnome-shell/extensions'
cp -a /opt/icpcbo/misc/add-username-ext ~icpcbo/.local/share/gnome-shell/extensions/
cp -a /opt/icpcbo/misc/stealmyfocus-ext ~icpcbo/.local/share/gnome-shell/extensions/
chown -R icpcbo:icpcbo ~icpcbo/.local/share/gnome-shell/extensions/add-username-ext
chown -R icpcbo:icpcbo ~icpcbo/.local/share/gnome-shell/extensions/stealmyfocus-ext

# Copy VSCode extensions
mkdir -p ~icpcbo/.vscode/extensions
tar jxf /opt/icpcbo/misc/vscode-extensions.tar.bz2 -C ~icpcbo/.vscode/extensions
chown -R icpcbo:icpcbo ~icpcbo/.vscode

# Add extra VSCode extension dir to bookmarks
mkdir -p ~icpcbo/.config/gtk-3.0
echo "file:///opt/icpcbo/misc/extra-vsc-exts" >> ~icpcbo/.config/gtk-3.0/bookmarks
chown -R icpcbo:icpcbo ~icpcbo/.config/gtk-3.0

# icpcbo startup
cp /opt/icpcbo/misc/icpcbostart.desktop /usr/share/gnome/autostart/

# Setup default Mozilla Firefox configuration
cp -a /opt/icpcbo/misc/mozilla ~icpcbo/.mozilla
chown -R icpcbo:icpcbo ~icpcbo/.mozilla

mkdir -p /home/icpcbo/.config/Code/User
cat >/home/icpcbo/.config/Code/User/settings.json <<'EOM'
{
    "C_Cpp.default.cppStandard": "gnu++17"
}
EOM
chown -R icpcbo:icpcbo /home/icpcbo/.config

logger -p local0.info "make_icpc_bo_user: icpcbo user created"
