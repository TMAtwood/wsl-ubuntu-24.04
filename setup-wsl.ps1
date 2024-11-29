Write-Host "Creating directory."
New-Item -ItemType Directory -Force -Path c:/temp/tmatwood-ubuntu-24.04
Write-Host "Unregister old distro."
wsl --unregister tmatwood-ubuntu-24.04
Write-Host "Remove old image if present."
docker rm localhost/tmatwood/ubuntu-24.04
docker run -it -d --name tmatwood-ubuntu-24.04 localhost/tmatwood/ubuntu-24.04:latest
docker export --output=c:/temp/tmatwood-ubuntu-24.04/tmatwood-ubuntu-24.04.tar tmatwood-ubuntu-24.04
docker stop tmatwood-ubuntu-24.04
wsl.exe --import tmatwood-ubuntu-24.04 "c:/temp/tmatwood-ubuntu-24.04/" "c:/temp/tmatwood-ubuntu-24.04/tmatwood-ubuntu-24.04.tar" --version 2
wsl --set-default tmatwood-ubuntu-24.04
#Copy-Item .wslgconfig "$env:USERPROFILE\.wslgconfig"
wsl sudo cp /etc/wsl.conf /etc/wsl.conf.bak
wsl sudo cp /etc/resolv.conf.override /etc/resolv.conf
wsl sudo systemctl restart systemd-resolved.service
wsl sudo systemctl unmask systemd-binfmt.service
wsl sudo systemctl restart systemd-binfmt
wsl sudo systemctl mask systemd-binfmt.service
Copy-Item .wslgconfig "$env:USERPROFILE\.wslgconfig"
wsl --shutdown
