#/bin/sh

set -x

mkdir -p spotify/AppDir
cd spotify
WORKDIR=$(pwd)

# download spotify
wget -q https://repository-origin.spotify.com/pool/non-free/s/spotify-client/spotify-client_1.1.56.595.g2d2da0de_amd64.deb

# extract files
ar x spotify-client_1.1.56.595.g2d2da0de_amd64.deb
tar -xf data.tar.gz -C ./AppDir

cd $WORKDIR/AppDir
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

# fix missing libcurl_gnutls.so
sudo apt install -y libcurl3-gnutls

cd ./usr/lib

#libbrotli1
cp /usr/lib/x86_64-linux-gnu/libbrotlicommon.so.1.0.7 .
ln -s libbrotlicommon.so.1.0.7 libbrotlicommon.so.1
cp /usr/lib/x86_64-linux-gnu/libbrotlidec.so.1.0.7 .
ln -s libbrotlidec.so.1.0.7 libbrotlidec.so.1
cp /usr/lib/x86_64-linux-gnu/libbrotlienc.so.1.0.7 .
ln -s libbrotlienc.so.1.0.7 libbrotlienc.so.1

#libgmp10
cp /usr/lib/x86_64-linux-gnu/libgmp.so.10.4.0 .
ln -s libgmp.so.10.4.0 libgmp.so.10

#libhogweed5
cp /usr/lib/x86_64-linux-gnu/libhogweed.so.5.0 .
ln -s libhogweed.so.5.0 libhogweed.so.5

#libidn2-0
cp /usr/lib/x86_64-linux-gnu/libidn2.so.0.3.6 .
ln -s libidn2.so.0.3.6 libidn2.so.0

#libnettle7
cp /usr/lib/x86_64-linux-gnu/libnettle.so.7.0 .
ln -s libnettle.so.7.0 libnettle.so.7

#libffi7
cp /usr/lib/x86_64-linux-gnu/libffi.so.7.1.0 .
ln -s libffi.so.7.1.0 libffi.so.7

#libp11-kit0
cp /usr/lib/x86_64-linux-gnu/libp11-kit.so.0.3.0 .
ln -s libp11-kit.so.0.3.0 libp11-kit.so.0

#libtasn1-6
cp /usr/lib/x86_64-linux-gnu/libtasn1.so.6.6.0 .
ln -s libtasn1.so.6.6.0 libtasn1.so.6

#libunistring2
cp /usr/lib/x86_64-linux-gnu/libunistring.so.2.1.0 .
ln -s libunistring.so.2.1.0 libunistring.so.2

#libgnutls30
cp /usr/lib/x86_64-linux-gnu/libgnutls.so.30.27.0 .
ln -s libgnutls.so.30.27.0 libgnutls.so.30

#libnghttp2-14
cp /usr/lib/x86_64-linux-gnu/libnghttp2.so.14.19.0 .
ln -s libnghttp2.so.14.19.0 libnghttp2.so.14

#libpsl5
cp /usr/lib/x86_64-linux-gnu/libpsl.so.5.3.2 .
ln -s libpsl.so.5.3.2 libpsl.so.5

#librtmp
cp /usr/lib/x86_64-linux-gnu/librtmp.so.1 .

#zlib1g
cp /lib/x86_64-linux-gnu/libz.so.1.2.11 .
ln -s libz.so.1.2.11 libz.so.1

cp /usr/lib/x86_64-linux-gnu/libcurl-gnutls.so.4.6.0 .
ln -s libcurl-gnutls.so.4.6.0 libcurl-gnutls.so.4
ln -s libcurl-gnutls.so.4 libcurl-gnutls.so.3

cd $WORKDIR
cp ../AppRun ./AppDir

wget -q https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage AppDir -n -u "gh-releases-zsync|lucasscvvieira|spotify-appimage|stable|Spotify*.AppImage.zsync" "Spotify-$SPOTIFY_VERSION-x86_64.AppImage"
chmod +x Spotify*.AppImage

mkdir dist
mv Spotify*.AppImage* ./dist

