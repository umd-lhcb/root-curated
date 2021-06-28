# root-curated
A curated version of ROOT 6 w/ HistFactory patches. We pin the software basis
for our analyses at this repo.


## Install `nix` on macOS

1. Go to [this project](https://github.com/numtide/nix-unstable-installer),
   copy the `sh <(curl ... )` line to your terminal and execute it.

2. Edit `/etc/nix/nix.conf` with sudo permission and add the following lines:

    ```
    experimental-features = nix-command flakes
    sandbox = false
    ```

3. Reboot your mac. Check that `nix flake` returns something.
4. Clone this project. In project root, run:

    ```
    nix develop
    ```

### Useful links for macOS

- [Possible problems when updateing macOS and a potential fix](https://github.com/NixOS/nix/issues/4531)


## Install `nix` on linux

1. Go to [this project](https://github.com/numtide/nix-unstable-installer),
   copy the `sh <(curl ... )` line to your terminal and execute it.

2. Edit `/etc/nix/nix.conf` with sudo permission and add the following lines:

    ```
    experimental-features = nix-command flakes
    ```

3. Reboot your computer. Check that `nix flake` returns something.
4. Clone this project. In project root, run:

    ```
    nix develop
    ```


## Compiling `root` without `nix` on macOS

1. `git clone --branch histfactory_patch https://github.com/umd-lhcb/root.git`
2. `mkdir root_build root_install && cd root_build`
3. `cmake -DCMAKE_INSTALL_PREFIX=../root_install/ -Dsqlite=OFF -Dmysql=OFF -Dx11=ON  -Droofit=ON -Dmt=ON -Dminuit2=ON -Dccache=ON -Dlibcxx=ON -Drpath=ON ../root `
4. `cmake --build . -- install -j8`

    Note: `jN` depends on number of CPU core you have; 'N' should be your
    number of CPU cores.
