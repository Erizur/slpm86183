{ pkgs ? import <nixpkgs> {} }:

let
  cross = import <nixpkgs> { crossSystem = { config = "mips-linux-gnu"; }; };
  pcsx-redux = (pkgs.callPackage ./pcsx-redux/package.nix { inherit pkgs; });
  ghidra_pkg = pkgs.ghidra.withExtensions (
    exts:
    with pkgs.ghidra-extensions; [
      ret-sync
      gnudisassembler
      findcrypt
      ghidra-delinker-extension
    ]
  );

  endPkgs = cross.buildPackages;
in
pkgs.mkShell {
    name = "popenv";
    nativeBuildInputs = with pkgs; [ ghidra_pkg gnumake xxd pcsx-redux endPkgs.binutilsNoLibc];
    shellHook = ''
      mkdir -p .bin
      ln -sf $(which mips-linux-gnu-as) .bin/mipsel-linux-gnu-as
      ln -sf $(which mips-linux-gnu-ld) .bin/mipsel-linux-gnu-ld
      ln -sf $(which mips-linux-gnu-objdump) .bin/mipsel-linux-gnu-objdump
      export PATH="$PWD/.bin:$PATH"

      echo "mipsel-linux-gnu symlinks now available"
    '';
}
