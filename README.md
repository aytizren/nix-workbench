This is a nix flake for [GNOME Workbench](https://github.com/workbenchdev/Workbench). Credits to both the developers of Workbench and those involved at NixOS/nixpkgs#208866


# Usage
This nix flake exposes two packages. The first is, well, workbench and can be accessed with either `packages.x86_64-linux.default` or `packages.x86_64-linux.workbench`. The second is `gtk-css-lsp`, which is a dependency of workbench that is not available in nixpkgs. The code for that derivation belongs to a contributor to the Nix User Repository.

To run either package, you can run

```shell
nix run github:aytizren/nix-workbench#<package>
```
where `<package>` is one of `gtk-css-lsp`,`workbench`, or `default`(which is an alias for workbench).


Either one can be integrated into your home-manager or NixOS setup using an approach similar to the following:
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    workbench = {
      url = "github:aytizren/nix-workbench";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  

  outputs = {nixpkgs, workbench, ...}: {
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      packages = [
        # Two relevant lines:
        workbench.packages.x86_64-linux.workbench
        workbench.packages.x86_64-linux.gtk-css-lsp
      ];
    }
  };
}
```

## Cache usage
This flake also has a cachix-hosted cache.

On NixOS, if you want to add it system-wide, add the following lines to your configuration:

```nix
nix.settings = {
  substituters = ["https://nix-workbench.cachix.org"];
  trusted-public-keys = ["nix-workbench.cachix.org-1:UlsphKxYbmI4lCXnJAuNDHzH9L92Rr7syeGQUq0Mm2o="];
};
```

If you want to use it in any way locally(user-specific `nix.conf` or even the CLI), you have one of two options, depending on your setup.


<details>
<summary>If your user is a member of `trusted-users`</summary>
In this case, you can use this with no further complication. If you want to save this cache, simply add it to your user-specific `nix.conf`.

Home manager example:
```nix
nix.settings = {
  extra-substituters = ["https://nix-workbench.cachix.org"];
  extra-trusted-public-keys = ["nix-workbench.cachix.org-1:UlsphKxYbmI4lCXnJAuNDHzH9L92Rr7syeGQUq0Mm2o="];
};
```

If you want to use it for one-time invocations, you can simply use
```shell
nix --accept-flake-config run github:aytizren/nix-workbench#<package> 
```

Side note: Blindly using `--accept-flake-config` is not good practice. See NixOS/nix#9649
</details>
<details>
<summary>If your user is not a member of `trusted-users`</summary>
In this case, you will have to add the cache to the system-wide, global `nix.conf`. [Relevant excerpt from the Nix manual](https://nix.dev/manual/nix/2.28/command-ref/conf-file#conf-trusted-substituters):
> `trusted-substituters`
> 
> A list of Nix store URLs, separated by whitespace. These are not used by default, but users of the Nix daemon can enable them by specifying substituters.
> 
> Unprivileged users (those set in only allowed-users but not trusted-users) can pass as substituters only those URLs listed in trusted-substituters.


You will have to do the following in your `nix.conf`:
```nix
nix.settings = {
  trusted-substituters = ["https://nix-workbench.cachix.org"];
  trusted-public-keys = ["nix-workbench.cachix.org-1:UlsphKxYbmI4lCXnJAuNDHzH9L92Rr7syeGQUq0Mm2o="];
};
```
</details>

# This has not been rigorously tested
This flake has not be tested with workflows involving any programming language, nor even CSS for that matter. I personally only use it for quick iteration with blueprint, and have not got around to testing other workflows.

# TODO:
Test this
