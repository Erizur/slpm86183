let
  pkgs = import <nixpkgs> {};

  ghidra_pkg = pkgs.ghidra.withExtensions (
    exts:
    with pkgs.ghidra-extensions; [
      ret-sync
      gnudisassembler
      findcrypt
      ghidra-delinker-extension
    ]
  );

  pythonStuff = (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [
    ninja
    colorama
    termcolor
    capstone
    iterfzf
    pyperclip
    jinja2
    levenshtein
    cryptography
    ipython
  ]));

  pcsx-redux = (pkgs.callPackage ./pcsx-redux/package.nix { inherit pkgs; });
in
  pkgs.mkShell {
    name = "popenv";
    nativeBuildInputs = with pkgs.buildPackages; [ ghidra_pkg pythonStuff pcsx-redux ];
}
