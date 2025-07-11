
docker build -t stardew-multiplayer:debian-11-v3.5.8 ./docker

docker run -itd --name stardew `
  -p 5902:5900 -p 5801:5800 -p 24642:24642/udp `
  --ipc=host `
  -e VNC_PASSWORD=prprpr `
  -v .\\valley_saves:/config/xdg/config/StardewValley/Saves `
  -v .\\docker\\mods\\:/data/mods/ `
  stardew-multiplayer:debian-11-v3.5.8
