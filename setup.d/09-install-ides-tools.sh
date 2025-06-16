#!/bin/bash

set -euo pipefail
set -x

ATOM_VERSION="1.60.0"
NVIM_VERSION="v0.11.0"
SUBLIME_VERSION="4192"
ECLIPSE_CPP_VERSION="2025-03"
ECLIPSE_INSTALLER_VERSION="2025-06"
VSCODE_CPPT_VERSION="1.24.5"
VSCODE_VIM_VERSION="1.29.0"
VSCODE_CLANGD_VERSION="0.1.33"
VSCODE_INTELLIJ_VERSION="1.7.3"
CACHE="/tmp/cache"
mkdir -p "$CACHE"

apt update
apt install -y \
    firefox git ddd valgrind konsole \
    geany geany-plugin-automark geany-plugin-lineoperations geany-plugin-overview \
    emacs gedit joe kate kdevelop nano vim vim-gtk3 \
    cmake make gcc g++ clang \
    python3 python3-pip python3-matplotlib python3-numpy \
    ruby openjdk-17-jdk \
    codeblocks unzip zip lsof strace htop tree \
    manpages-dev aspell aspell-en aspell-es dict dictd dict-wn \
    libwxgtk3.0-gtk3-0v5

wget -O "$CACHE/vscode.deb" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
dpkg -i "$CACHE/vscode.deb" || apt -f install -y

wget -O "$CACHE/cpptools.vsix" "https://github.com/microsoft/vscode-cpptools/releases/download/v${VSCODE_CPPT_VERSION}/cpptools-linux-x64.vsix"
wget -O "$CACHE/vim.vsix" "https://github.com/VSCodeVim/Vim/releases/download/v${VSCODE_VIM_VERSION}/vim-${VSCODE_VIM_VERSION}.vsix"
wget -O "$CACHE/intellij.vsix" "https://github.com/kasecato/vscode-intellij-idea-keybindings/releases/download/v${VSCODE_INTELLIJ_VERSION}/intellij-idea-keybindings-${VSCODE_INTELLIJ_VERSION}.vsix"
wget -O "$CACHE/clangd.vsix" "https://github.com/clangd/vscode-clangd/releases/download/${VSCODE_CLANGD_VERSION}/vscode-clangd-${VSCODE_CLANGD_VERSION}.vsix"
wget -O "$CACHE/java.vsix" "https://github.com/redhat-developer/vscode-java/releases/download/v1.42.0/vscode-java-1.42.0-561.vsix"

for ext in "$CACHE"/*.vsix; do
    sudo -u icpcbo code --install-extension "$ext"
done

wget -O "$CACHE/atom.deb" "https://github.com/atom/atom/releases/download/v${ATOM_VERSION}/atom-amd64.deb"
dpkg -i "$CACHE/atom.deb" || apt -f install -y
sed -i 's/^Exec=.*/& --no-sandbox/' /usr/share/applications/atom.desktop

wget -O "$CACHE/sublime.deb" "https://download.sublimetext.com/sublime-text_build-${SUBLIME_VERSION}_amd64.deb"
dpkg -i "$CACHE/sublime.deb" || apt -f install -y

wget -O "$CACHE/nvim.tar.gz" "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
tar xzf "$CACHE/nvim.tar.gz" -C /opt
echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> /etc/profile.d/nvim.sh

ECLIPSE_CPP_NAME="eclipse-cpp-${ECLIPSE_CPP_VERSION}-R-linux-gtk-x86_64"
wget -O "$CACHE/eclipse-cpp.tar.gz" "https://mirror.dkm.cz/eclipse/technology/epp/downloads/release/${ECLIPSE_CPP_VERSION}/R/${ECLIPSE_CPP_NAME}.tar.gz"
tar -zxf "$CACHE/eclipse-cpp.tar.gz" -C /opt
cp /opt/eclipse/plugins/org.eclipse.epp.package.cpp_*/eclipse*.png /usr/share/pixmaps/eclipse-cpp.png

cat <<EOF > /usr/share/applications/eclipse_cpp.desktop
[Desktop Entry]
Name=Eclipse C/C++
Exec=/opt/eclipse/eclipse
Type=Application
Icon=eclipse-cpp
Categories=Development;IDE;
Terminal=false
EOF

sed -i '/^-vmargs/a -Dorg.eclipse.oomph.setup.donate=false' /opt/eclipse/eclipse.ini

wget -O "$CACHE/eclipse-installer.tar.gz" "https://www.eclipse.org/downloads/download.php?file=/oomph/epp/${ECLIPSE_INSTALLER_VERSION}/R/eclipse-inst-jre-linux64.tar.gz"
tar -zxf "$CACHE/eclipse-installer.tar.gz" -C /opt
mv /opt/eclipse-installer /opt/eclipse-installer-java
cp /opt/eclipse-installer-java/icon.xpm /usr/share/pixmaps/eclipse-installer.png

cat <<EOF > /usr/share/applications/eclipse_installer.desktop
[Desktop Entry]
Name=Eclipse Installer (Java)
Exec=/opt/eclipse-installer-java/eclipse-inst
Type=Application
Icon=eclipse-installer
Categories=Development;IDE;
Terminal=false
EOF
