# root-curated
A curated software root (foundation) for most of our analysis repos, including
a version of ROOT 6 w/ HistFactory patches (from Phoebe) applied.


## Install `nix` on macOS (ARM-based)

1. Go to [the official page](https://nixos.org/download.html#nix-install-macos),
    follow the _Multi-user installation_ guide.

    Or, just paste this to your terminal:

    ```
    sh <(curl -L https://nixos.org/nix/install)
    ```
    To unistall follow [Uninstalling Nix](https://nixos.org/manual/nix/stable/installation/uninstall). After reinstalling, if you have a dead symlink follow [SSL CA cert error on MacOS](https://discourse.nixos.org/t/ssl-ca-cert-error-on-macos/31171).

2. Install `Rosetta 2` by pasting this to your terminal:

    ```shell
    sudo /usr/sbin/softwareupdate --install-rosetta --agree-to-license
    ```

3. Install [`nix-darwin`](https://github.com/LnL7/nix-darwin) by pasting this to your terminal:

    ```shell
    nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
    ./result/bin/darwin-installer
    ```
    When asked, edit the default `configuration.nix` before starting and add the following lines:
    ```shell
    nix.settings.experimental-features = "nix-command flakes";
    nix.settings.sandbox = false;
    nix.settings.system = "x86_64-darwin";
    nix.settings.extra-platforms = "x86_64-darwin aarch64-darwin";
    ```
    You can also edit `environment.systemPackages` (where you can install additional packages) like this:
    ```shell
    environment.systemPackages = with pkgs; [
        gitAndTools.gitFull
        python38
        (lowPrio python39)
    ];
    ```
    The basic workflow for using `Nix` is editing `~/.nixpkgs/darwin-configuration.nix` and then running `darwin-rebuild switch` to activate those changes.

4. Reboot your mac. Check that `nix flake` returns something.

5. Clone this project. In `nix/python-packages/xgboost/default.nix` comment the two lines that refer to `graphviz`. Update `nix/python-packages/scikit-learn/default.nix` to version [`1.1.1`](https://github.com/NixOS/nixpkgs/blob/27668c5709f8e68760f521c0d91943dafeeea939/pkgs/development/python-modules/scikit-learn/default.nix). An example can be found in this section: [Create a new ROOT derivation](#create-a-new-root-derivation).

6. In project root, run:

    ```
    nix develop
    ```

7. Make sure that you always use the local version of `root-curated` when you install an additional package. I.e. `flake.nix` of `lhcb-ntuples-gen` should look like this:
    ```shell
    inputs = {
        root-curated.url = "~/umd-lhcb/root-curated";
        nixpkgs.follows = "root-curated/nixpkgs";
        flake-utils.follows = "root-curated/flake-utils";

        MuonBDTPid.url = "github:umd-lhcb/MuonBDTPid";
        hammer-reweight.url = "github:umd-lhcb/hammer-reweight";
        misid-unfold.url = "~/umd-lhcb/misid-unfold";
        vertex-resolution.url = "~/umd-lhcb/vertex-resolution";

        flake-compat = {
            url = "github:edolstra/flake-compat";
            flake = false;
        };
    };
    ```

8. Notice that we also use a local version of `misid-unfold` and `vertex-resolution`. Some packages, like these two, are missing a library in `Makefile`. Make sure that in their `Makefile` you have:
    ```shell
    LINKFLAGS       :=      $(shell root-config --libs) -lc++fs
    ```
    More information about using `<filesystem>` and `libc++fs` can be found in this link: [libc++ 8.0 documentation](https://releases.llvm.org/8.0.0/projects/libcxx/docs/UsingLibcxx.html).

9. If you have issues witn `docker` you can try `colima` to run `docker` containers on macOS. This is how you can install it with `Homebrew` together with some useful commands:
    ```shell
    brew install docker docker-compose docker-machine colima
    ```
    ```shell
    colima delete
    colima start --arch x86_64
    colima stop
    ```
    <u>Note</u>: On our server, `glacier`, after you install `docker` and `colima` using the `server-user-config` package, you can start colima with the command:
    ```shell
    colima start --arch aarch64
    ```

10. If needed, you can locally install `ROOT 6.28/06` from source which can be obtained from the corresponding public [Git repository](https://root.cern/releases/release-62806/#git).


## Install `nix` on macOS

1. Go to [the official page](https://nixos.org/download.html),
    follow the _Multi-user installation_ guide.

    Or, just paste this to your terminal:

    ```
    sh <(curl -L https://nixos.org/nix/install) --daemon
    ```

2. Edit `/etc/nix/nix.conf` with sudo permission and add the following lines:

    ```shell
    experimental-features = nix-command flakes
    #sandbox = false  # uncomment if you are on macOS!
    ```

3. Reboot your mac. Check that `nix flake` returns something.
4. Clone this project. In project root, run:

    ```
    nix develop
    ```

### Useful links for macOS

- [Possible problems when updateing macOS and a potential fix](https://github.com/NixOS/nix/issues/4531)


## Install `nix` on Linux

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

0. Add an user-wide overlay so that your `nix-direnv` knows to use the correct
   version of `nix`:

    Add the following content to `$HOME/.config/nixpkgs/overlays/base.nix`. If
    the directory doesn't exist, create it.
    ```nix
    final: prev:

    {
      nix-direnv = prev.nix-direnv.override { enableFlakes = true; };
    }
    ```

1. Install `direnv` and `nix-direv` with:

    ```shell
    nix-env -iA nixpkgs.nix-direnv nixpkgs.direnv
    ```

2. Update your shell configuration:

    1. For `bash`, edit `$HOME/.bashrc`:

        ```bash
        eval "$(direnv hook bash)"
        ```

    2. For `zsh`, edit `$HOME/.zshrc`:

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


## Create a new ROOT derivation

1. Pick a base derivation to work on:
    1. If `ROOT version > 6.24`, start from [the official derivation](https://github.com/NixOS/nixpkgs/tree/master/pkgs/applications/science/misc/root).

        **Note**: It is recommended to format the official derivation with
        `nixpkgs-fmt` so that the `diff` between the existing and
        official derivation is more meaningful.

    2. Otherwise, start with an existing derivation, for example [`nix/root_6_12`](./nix/root_6_12).

2. Assume both the derivation and all patches, including the HistFactory one, work.
   Therefore, only the ROOT version and its `sha256sum` need to be updated.

    Copy and rename the base derivation folder, for example:

    ```
    root_6_12 -> root_6_18
    ```

    Denote the new folder as `root_new`

3. Locate the following code in `root_new/default.nix`:

    ```nix
      pname = "root";
      version = "X.YY.ZZ";

      src = fetchurl {
        url = "https://root.cern.ch/download/root_v${version}.source.tar.gz";
        sha256 = "0507e1095e279ccc7240f651d25966024325179fa85a1259b694b56723ad7c1c";
      };
    ```

    1. Update the version, i.e. `6.18.04`.

    2. Download the source code locally. The URL is:

        ```
        https://root.cern.ch/download/root_v${version}.source.tar.gz
        ```

        Don't forget to replace `${version}` with the actual version!

    3. Find the `sha256sum` of the source with:

        ```shell
        sha256sum <path_to_root_src>
        ```

        Then update the `sha256` attribute.

4. Create a new entry in [`nix/overlay.nix`](./nix/overlay.nix), following
   existing examples.

5. Locate the following code in [`flake.nix`](./flake.nix):

    ```nix
        packages = flake-utils.lib.flattenTree {
          dev-shell = devShell.inputDerivation;
          root = pkgs.root;
          root_6_12_06 = pkgs.root_6_12_06;
          root_5_34_38 = pkgs.root_5_34_38;
          clang-format-all = pkgs.clang-format-all;
        };
    ```

    Append the new ROOT entry here as well.

6. Test if the new ROOT compiles:

    ```shell
    nix build ".#<new_root_pkg_name_defined_in_flake>"
    ```

    If everything works, a symbolic link `result` will be created in project
    root, pointing to the build result.

    You can test this root with:
    ```
    ./result/bin/root
    ```

    **Note**: You should delete this symbolic link afterwards so that the build
    will get garbage-collected in the future.


## Update `flake` inputs

If you want to update all inputs:
```shell
nix flake update
```

If you only want to update specific ones (say `stuff`):
```shell
nix flake lock --update-input stuff
```


## Upgrade `nix`

Take a look at [the official instruction](https://nixos.org/manual/nix/stable/installation/upgrading.html)


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
