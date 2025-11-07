{ pkgs, lib, ... }:

let
  version = "718f0912";
  pname = "pcsx-redux";
  name = "${pname}-${version}";

  unzipped = pkgs.fetchzip {
    url = "https://distrib.app/storage/assets/4c3/617/79a/458f96a78c123779d67fc552f766068bb87f56a9a45da844b2def61/PCSX-Redux-718f0912-linux-x86_64.zip";
    hash = "sha256-Pemjsdrnn/2+TtUBLkkrDqsceR7FlYam1QbxXll7jlo=";
  };

  src = "${unzipped}/PCSX-Redux-HEAD-x86_64.AppImage";

  appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };
in
pkgs.appimageTools.wrapType2 rec {
  inherit pname name version src;

  extraInstallCommands = ''
    if [ -e "${appimageContents}/usr/share/applications/${pname}.desktop" ]; then
      install -D -m 644 "${appimageContents}/usr/share/applications/${pname}.desktop" "$out/share/applications/${pname}.desktop"
    elif [ -e "${appimageContents}/${pname}.desktop" ]; then
      install -D -m 644 "${appimageContents}/${pname}.desktop" "$out/share/applications/${pname}.desktop"
    fi

    if [ -e "${appimageContents}/usr/share/icons/hicolor/256x256/apps/${pname}.png" ]; then
      install -D -m 644 "${appimageContents}/usr/share/icons/hicolor/256x256/apps/${pname}.png" "$out/share/icons/hicolor/256x256/apps/${pname}.png"
    elif [ -e "${appimageContents}/${pname}.png" ]; then
      install -D -m 644 "${appimageContents}/${pname}.png" "$out/share/icons/hicolor/256x256/apps/${pname}.png"
    fi

    if [ -e "$out/share/applications/${pname}.desktop" ]; then
      if grep -q '^Exec=' "$out/share/applications/${pname}.desktop"; then
        sed -i "s|^Exec=.*|Exec=${pname} %U|" "$out/share/applications/${pname}.desktop"
      else
        echo "Exec=${pname} %U" >> "$out/share/applications/${pname}.desktop"
      fi
    fi
  '';

  extraPkgs = pkgs: with pkgs; [
    xorg.libX11
    xorg.libxcb
    capstone
    freetype
    glfw
    ffmpeg
    curl
    libuv
    zlib
    stdenv.cc.cc.lib
    fontconfig
    harfbuzz
    fribidi
    gmp
    libgpg-error
    libdrm
    e2fsprogs
  ];

  meta = {
    description = "Nix wrapper for the PCSX-Redux emulator";
    homepage = "https://github.com/grumpycoders/pcsx-redux";
    downloadPage = "https://github.com/grumpycoders/pcsx-redux/releases";
    mainProgram = "pcsx-redux";
    license = lib.licenses.gpl2;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ erizur ];
    platforms = [ "x86_64-linux" ];
  };
}
