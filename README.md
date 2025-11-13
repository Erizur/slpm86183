# pop'n music CS - PSX decompilation
<div>
  <img src="https://github.com/user-attachments/assets/8844b7e6-2632-4e54-ab60-2323adf980bc" width="24%" alt="Mimi dancing" align="right">
  <div>
    This is a decompilation project for the PSX port of BEMANI's 1998 rhythm arcade game, <b>pop'n music.</b>
    It is currently on its early stages. Feel free to contribute if you want!
  </div>
  <h3>Decompilation Progress</h3>
  <table>
    <thead>
      <tr>
        <th>File name</th>
        <th>Progress</th>
        <th>Description</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><code>SLPM_861.83</code></td>
        <td><img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/Erizur/slpm86183/gh-report/results/progress-slpm861.json" alt="progress"></td>
        <td>Full game executable</td>
      </tr>
    </tbody>
  </table>
</div>
<br><br><br><br><br><br><br><br><br><br><br><br>

***

## Build instructions (Linux/Windows)
You will need to install the following dependencies from your package manager:
- git
- cmake
- build-essential
- binutils-mips-linux-gnu
- cpp-mips-linux-gnu
- python3
- python3-venv

On a Debian-based distribution (Ubuntu or WSL with Debian/Ubuntu), you can run these commands to install them:
```
sudo apt update
sudo apt install git cmake build-essential binutils-mips-linux-gnu cpp-mips-linux-gnu python3 python3-venv
```

#### Nix extras
On a system with Nix installed, there is a development shell you can activate on this repository. It includes a Ghidra setup and PCSX-Redux. You can run this command to start:
```
nix-shell
```
Note that due to nixpkgs' binary cache storage limit, cross-platform binaries are not cached, meaning you will have to build the MIPS GCC toolchain on your system. This task can usually around 30 minutes, depending on your system's specs.
### Cloning
Clone this repository to the directory of your choice. Make sure to clone it recursively!
```
git clone --recursive https://github.com/Erizur/slpm86183.git && cd slpm86183
```

### Building mkpsxiso
Now that you have the repository and all of the submodules, go to the `tools/mkpsxiso` directory and run the following commands:
```
cmake -S . -B build
cmake --build build
```
You should now have a build folder with the `mkpsxiso` and `dumpsxiso` binaries. We will need them for the next step.

### ROM Extraction
You will need to provide your own dump of the retail game's ROM. (sha1: `891cfb144375d3f71b1067f74400ac07e1fa5355`)\
You should obtain a .BIN, place it on the parent directory and rename it into `popn.bin`. Once that's done, open a terminal and run `make teariso`.\
If you did everything correctly, there should now be an iso folder, and a binary called `SLPM_861.83` on the main directory. **DO NOT OVERWRITE/DELETE THIS FILE**, as it is the original binary to be used as reference for other programs in the decompilation.

 ### Python environment setup
 To setup the Python shell with all the requirements for the project, you will need a virtual environment (.venv) with pip.\
 You can set up an environment by running the following commands on the main directory:
 ```bash
python3 -m venv .venv                      # Creates `.venv` folder with environment.
source .venv/bin/activate                  # Activates environment (must be run in every new terminal session).
python3 -m pip install -r requirements.txt # Installs project requirements from `requirements.txt`.
```

#### NixOS users
Because NixOS can not run dynamically-linked executables, and the requirements' heavy reliance on external dependencies, you will have to use tools like [nix-ld](https://github.com/nix-community/nix-ld) as a workaround.
As an alternative, if you are using flakes, you can create the virtual environment using tools like [fix-python](https://github.com/GuillaumeDesforges/fix-python/) instead, but you will need different arguments to set it up:
 ```bash
# These commands assume you are on a development shell with Python3 included. The shell.nix from the repository does not include Python.
python3 -m venv .venv --copies                   # Creates `.venv` folder with environment, and copies over the python binaries.
nix shell github:GuillaumeDesforges/fix-python   # Starts a shell with the fix-python commands.
fix-python --venv .venv                          # Patches the python binaries.
source .venv/bin/activate                        # Activates environment (must be run in every new terminal session).
python3 -m pip install -r requirements.txt       # Installs project requirements from `requirements.txt`.
fix-python --venv .venv                          # Patches the newly downloaded binaries.
exit                                             # Exits the fix-python shell.
```
### Code compilation
<sup>(Mostly taken from the [silent-hill-decomp](https://github.com/Vatuu/silent-hill-decomp) project :P)</sup>\
On the parent directory in a terminal, run `make setup` to extract the needed code from the binary.
If it finished successfully, run `make` to build.
Once the build has finished, a folder named `build` will be produced. The output results and binaries will be inside.

Additional `make` commands:
* `build`: Builds the executable.
* `check`: Builds the executable. After compilation, it compares its checksum with the original file.
* `clean-build`: Regenerates the project configuration and builds the executable.
* `clean-check`: Regenerates the project configuration and builds the executable. After compilation, it compares its checksum with the original file.
* `objdiff-config`: Generates project configuration for [objdiff](https://github.com/encounter/objdiff).
* `compilation-test`: Run progress and matching build processes for avoiding compilation errors.

NOTE: `clean-build/clean-check/compilation-test` is obligatory if the decompilation configuration files inside the `config` folder or the `Makefile` have been modified.




