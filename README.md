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
