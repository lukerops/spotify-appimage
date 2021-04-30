#/bin/sh

set -x

mkdir -p spotify/AppDir
cd spotify

# download spotify
wget https://repository-origin.spotify.com/pool/non-free/s/spotify-client/spotify-client_1.1.56.595.g2d2da0de_amd64.deb

# extract files
ar x spotify-client_1.1.56.595.g2d2da0de_amd64.deb
tar -xf data.tar.gz -C ./AppDir

cd AppDir
SPOTIFY_VERSION=$(./usr/bin/spotify --version | sed -e 's|,||g' | cut -d ' ' -f3)

mv ./usr/share/spotify/spotify.desktop .
rm -rf ./usr/share/doc

mkdir -p ./usr/lib \
	./usr/share/icons/hicolor/64x64/apps \
	./usr/share/icons/hicolor/32x32/apps \
	./usr/share/icons/hicolor/256x256/apps \
	./usr/share/icons/hicolor/24x24/apps \
	./usr/share/icons/hicolor/128x128/apps \
	./usr/share/icons/hicolor/48x48/apps

# apply patches
mv ./usr/share/spotify/icons/spotify-linux-64.png  ./usr/share/icons/hicolor/64x64/apps/spotify.png
mv ./usr/share/spotify/icons/spotify-linux-32.png  ./usr/share/icons/hicolor/32x32/apps/spotify.png
mv ./usr/share/spotify/icons/spotify-linux-256.png ./usr/share/icons/hicolor/256x256/apps/spotify.png
mv ./usr/share/spotify/icons/spotify-linux-24.png  ./usr/share/icons/hicolor/24x24/apps/spotify.png
mv ./usr/share/spotify/icons/spotify-linux-128.png ./usr/share/icons/hicolor/128x128/apps/spotify.png
mv ./usr/share/spotify/icons/spotify-linux-48.png  ./usr/share/icons/hicolor/48x48/apps/spotify.png
cp ./usr/share/icons/hicolor/256x256/apps/spotify.png .

sed -i -e "s|Exec=spotify|Exec=AppRun|g" -e "s|Icon=spotify-client|Icon=spotify|g" spotify.desktop
sed -i -e "s|StartupWMClass=spotify|StartupWMClass=spotify\nX-AppImage-Version=$SPOTIFY_VERSION|g" spotify.desktop

cd ..
cp ../AppRun ./AppDir

wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage AppDir -n -u "gh-releases-zsync|lucasscvvieira|spotify-appimage|stable|Spotify*.AppImage.zsync" "Spotify-$SPOTIFY_VERSION-x86_64.AppImage"
chmod +x Spotify*.AppImage

mkdir dist
mv Spotify*.AppImage* ./dist
