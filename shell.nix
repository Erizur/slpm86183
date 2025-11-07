{ pkgs ? import <nixpkgs> {} }:

let
  crossPkgs = import <nixpkgs> { crossSystem = { config = "mips-linux-gnu"; }; };
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
in
pkgs.mkShell {
    name = "popenv";
    nativeBuildInputs = with pkgs; [ ghidra_pkg gnumake pcsx-redux crossPkgs.buildPackages.binutilsNoLibc ];
}
