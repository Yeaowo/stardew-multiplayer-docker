
# it cannot update to v4: https://github.com/jlesage/docker-baseimage-gui/issues/145
FROM jlesage/baseimage-gui:debian-11-v3.5.8

# Set the name of the application.
ENV APP_NAME="StardewValley"

ENV TZ="Asia/Hong_Kong"
ENV TERM="xterm"
ENV XDG_DATA_HOME="/config/xdg/data"
ENV XDG_CONFIG_HOME="/config/xdg/config"
ENV XDG_CACHE_HOME="/config/xdg/cache"
ENV DISPLAY_HEIGHT="900"
ENV DISPLAY_WIDTH="1200"

ENV STARDEW_VERSION="1.6.15"
ENV SMAPI_VERSION="4.1.10"
ENV STARDEW_PATH="/data/stardew"
ENV SMAPI_PATH="/data/smapi"

# 两个smapi内置的mod，布尔值决定是否启用
ENV ENABLE_CONSOLE_COMMANDS_MOD="false"
ENV ENABLE_SAVE_BACKUP_MOD="true"

COPY Stardew_${STARDEW_VERSION}.ignore.tar.gz ${STARDEW_PATH}_${STARDEW_VERSION}.tar.gz
COPY SMAPI-${SMAPI_VERSION}-installer.ignore.zip ${SMAPI_PATH}_${SMAPI_VERSION}.zip
COPY dotnet-runtime-5.0.17-linux-musl-x64.ignore.tar.gz /data/dotnet.tar.gz
COPY libstrangle.ignore.zip /data/libstrangle.zip

RUN <<-EOF_RUN

ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
echo "${TZ}" > /etc/timezone
cat >> ~/.bashrc << 'EOF'
alias ll="ls -alF"
alias la="ls -AF"
PS1='\n$(E=$?;[[ $E -ne 0 ]]&&echo -e "\e[2mExit status: \e[0;91m$E\n\e[m")\[\e[1;34m\]>\[\e[m\] \[\e[36m\]'`id -nu`'\[\e[m\]@\[\e[32m\]'`echo ${SSH_CONNECTION:-'  localhost'}|cut -d' ' -f3`'\[\e[m\]:\[\e[1;33m\]\w\[\e[m\] [\t]\n\[\e[1;31m\]\$\[\e[m\] '
EOF

mv /etc/apt/sources.list /etc/apt/sources.list.bak
cat > /etc/apt/sources.list << 'EOF'
deb http://mirrors.tencent.com/debian bullseye main contrib non-free
deb http://mirrors.tencent.com/debian bullseye-updates main contrib non-free
deb http://mirrors.tencent.com/debian-security bullseye-security main contrib non-free
EOF

apt-get update

EOF_RUN

RUN <<-EOF_RUN
# apt-get install -y wget
apt-get install -y unzip mono-runtime xterm procps

# Install libstrangle: https://github.com/printfuck/stardew-multiplayer-docker/issues/44
# apt-get install -y git
apt-get install -y make gcc-multilib g++-multilib libx11-dev mesa-common-dev libc6-dev-i386

apt-get clean all
rm -rf /var/lib/apt/lists/*
EOF_RUN

# Install libstrangle: https://github.com/printfuck/stardew-multiplayer-docker/issues/44
RUN <<-EOF_RUN
mkdir -p /data/libstrangle
cd /data
# RUN git clone https://gitlab.com/torkel104/libstrangle.git
unzip -qd /data/libstrangle /data/libstrangle.zip
cd /data/libstrangle
# Find the actual libstrangle directory (it might be nested)
if [ -d "libstrangle-master" ]; then
    cd libstrangle-master
elif [ -d "libstrangle" ]; then
    cd libstrangle
fi
# Check if Makefile exists
if [ -f "Makefile" ]; then
    make && make install
    # 验证strangle命令是否安装成功
    if command -v strangle >/dev/null 2>&1; then
        echo "libstrangle installed successfully"
    else
        echo "Warning: strangle command not found after installation"
        ls -la /usr/local/bin/ || echo "No /usr/local/bin directory"
        find /usr -name "strangle" 2>/dev/null || echo "strangle not found in /usr"
    fi
else
    echo "Warning: Makefile not found in libstrangle directory"
    ls -la
fi
EOF_RUN

# Install dotnet
RUN <<-EOF_RUN
tar -zxf /data/dotnet.tar.gz -C /usr/share/dotnet
# rm /data/dotnet.tar.gz
ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
EOF_RUN

RUN <<-EOF_RUN

mkdir -p ${STARDEW_PATH} ${SMAPI_PATH} ${XDG_CONFIG_HOME}

# wget https://eris.cc/Stardew_${STARDEW_VERSION}.tar.gz -O ${STARDEW_PATH}_${STARDEW_VERSION}.tar.gz
echo "Extracting Stardew Valley ${STARDEW_VERSION}..."
tar xf ${STARDEW_PATH}_${STARDEW_VERSION}.tar.gz -C ${STARDEW_PATH}
# rm ${STARDEW_PATH}_${STARDEW_VERSION}.tar.gz

# wget https://github.com/Pathoschild/SMAPI/releases/download/${SMAPI_VERSION}/SMAPI-${SMAPI_VERSION}-installer.zip -O ${SMAPI_PATH}_${SMAPI_VERSION}.zip
unzip -qd ${SMAPI_PATH}/ ${SMAPI_PATH}_${SMAPI_VERSION}.zip
# rm ${SMAPI_PATH}_${SMAPI_VERSION}.zip

/bin/bash -c "SMAPI_NO_TERMINAL=true SMAPI_USE_CURRENT_SHELL=true echo -e \"2\n\n\" | ${SMAPI_PATH}/SMAPI\ ${SMAPI_VERSION}\ installer/internal/linux/SMAPI.Installer --install --game-path ${STARDEW_PATH}/Stardew\ Valley"

EOF_RUN

# Add Mods & Scripts
COPY scripts/ /opt/

RUN <<-EOF_RUN
mv ${STARDEW_PATH}/Stardew\ Valley/Mods ${STARDEW_PATH}/Stardew\ Valley/Mods.bak
ln -s /data/mods ${STARDEW_PATH}/Stardew\ Valley/Mods

echo "Setting permissions..."
chmod +x ${STARDEW_PATH}/Stardew\ Valley/StardewValley
chmod -R 777 ${STARDEW_PATH}/
chown -R 1000:1000 ${STARDEW_PATH}/
chmod +x /opt/*.sh
mkdir -p /config/xdg/cache/openbox/sessions
chmod -R 777 /config
chown -R 1000:1000 /config

# 确保启动脚本有执行权限
chmod +x /opt/start-game.sh
EOF_RUN

# CMD ["/bin/bash", "-l"]

COPY docker-entrypoint.sh /startapp.sh
