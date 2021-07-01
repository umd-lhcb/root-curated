# root-curated
A curated software root (foundation) for most of our analysis repos, including
a version of ROOT 6 w/ HistFactory patches (from Phoebe) applied.


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


## Automate `nix develop` by installing `direnv`

It can be tiresome to type `nix develop` for every project. `direnv` provides a
solution than enters the shell provided by `nix develop` automatically. You
should install it!

For this guide, it is assumed that `nix` is already installed.

1. Install `direnv` and `nix-direv` with:

    ```shell
    nix-env -f '<nixpkgs>' -iA nix-direnv direnv
    ```

2. Update your shell configuration:

    1. For `bash`:

        ```bash
        eval "$(direnv hook bash)"
        ```

    2. For `zsh`:

        ```bash
        eval "$(direnv hook zsh)"
        ```

3. Configure `direnv` to source `nix-direnv`. In `$HOME/.direnvrc`:

    ```bash
    source $HOME/.nix-profile/share/nix-direnv/direnvrc
    ```

4. Add the following settings to `/etc/nix/nix.conf` (need sudo):

    ```
    keep-outputs = true
    keep-derivations = true
    ```

5. Reboot your computer since `nix` config has changed.

6. For any project that has a `.envrc` in its root, the first time you `cd`
   into that directory, `direnv` will prompt that the `envrc` is blocked.

    Type `direnv allow` to unblock it. Next time you `cd` into that directory,
    you will automatically enter the `nix develop` shell w/o typing anything.


## Remove unused packages

Over time you may have a large collection of unused packages/old builds inside
`/nix`.

To safely remove these, first follow the [`direnv` section](#automate-nix-develop-by-installing-direnv)
so that `direnv` will automatically create flags that prevent your latest
packages from garbage collection, then:

```shell
nix-collect-garbage -d
```


## Upgrade `nix`

On macOS, with sudo:
```shell
sudo -i sh -c 'nix-channel --update && nix-env -iA nixpkgs.nix && launchctl remove org.nixos.nix-daemon && launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist'
```

On Linux, with sudo:
```shell
sudo nix-channel --update; nix-env -iA nixpkgs.nix nixpkgs.cacert; systemctl daemon-reload; systemctl restart nix-daemon
```


## Miscellaneous

### Package update strategy

- For the base `nixpkgs` that contains complier toolchains, etc. Once it is
  stable, we don't update during the whole lifetime of an analysis.
- For ROOT, once we pick a major version, we stick with the major version while
  trying to update to the latest minor version for the lifetime of an analysis.

    For example, if we are using `6.24.00`, then we should update to `6.24.02`,
    but we won't update to `6.26.00`

- We should regularly tag working versions of this repository
- Once a new analysis is started, we should update the base `nixpkgs`.
- Ideally we should build docker images for old analyses so that we can always
  go back even if the whole Nix project shuts down.


### ROOT branching strategy

We have [a fork of ROOT](https://github.com/umd-lhcb/root) in our organization.
This is used to adapt Phoebe's HistFactory patches with newer versions of ROOT.

The branching strategy is:

- `histfactory_patch`: Latest development branch
- `histfactory_patch_vX-YY-ZZ`: Historical ROOT versions that work with
  Phoebe's patch


### Compiling ROOT without `nix` on macOS

0. Remove existing ROOT installation: `rm -rf root_build root_install`
1. `git clone --branch histfactory_patch https://github.com/umd-lhcb/root.git`
2. `mkdir root_build root_install && cd root_build`
3. `cmake -DCMAKE_INSTALL_PREFIX=../root_install/ -Dsqlite=OFF -Dmysql=OFF -Dx11=ON  -Droofit=ON -Dmt=ON -Dminuit2=ON -Dccache=ON -Dlibcxx=ON -Drpath=ON ../root `
4. `cmake --build . -- install -j8`

    Note:  For `-jN`, `N` should equal to your number of CPU cores.
