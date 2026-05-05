# AMPGameServer

Community AMP/CubeCoders server templates and helper scripts.

This repository currently contains a Conan Exiles Enhanced template for AMP. It adds a separate `Conan Exiles Enhancen (Elounia)` application so users can tell it apart from CubeCoders' official Conan Exiles Enhanced template and create new Enhanced instances without replacing existing Conan Exiles Legacy instances.

## Included Templates

- `Conan Exiles/Template/` - AMP app template for Conan Exiles Enhanced dedicated servers, customized as `Conan Exiles Enhancen (Elounia)`.

## Quick Install To A Local AMP Server

On the Linux machine that hosts AMP, clone or download this repository, then run:

```bash
git clone <this-repository-url> AMPGameServer
cd AMPGameServer
bash "Conan Exiles/scripts/linux-install-conan-exiles-enhanced-amp.sh"
```

If you are already inside the repository, just run:

```bash
bash "Conan Exiles/scripts/linux-install-conan-exiles-enhanced-amp.sh"
```

The installer:

- finds the local AMP ADS deployment template cache;
- copies only the Conan Exiles Enhancen (Elounia) template files;
- backs up any previous local `conan-exiles-enhanced*` files before replacing them;
- validates the template JSON and Windows/Linux launch paths;
- commits the local AMP template-cache change when that cache is a git repository;
- restarts ADS so `Conan Exiles Enhancen (Elounia)` appears in the Create Instance dropdown.

The script does not delete existing AMP instances, datastores, saves, or Conan Exiles Legacy configuration.

If AMP is installed somewhere unusual, pass the location explicitly:

```bash
bash "Conan Exiles/scripts/linux-install-conan-exiles-enhanced-amp.sh" --instances-root /home/amp/.ampdata/instances
```

or:

```bash
bash "Conan Exiles/scripts/linux-install-conan-exiles-enhanced-amp.sh" --template-cache /path/to/ADS01/Plugins/ADSModule/DeploymentTemplates/CubeCoders-AMPTemplates-main
```

## Elounia Port Defaults

This template intentionally avoids the classic Conan defaults so it can live beside other Conan templates or instances:

```text
30002 TCP/UDP  Game and mod download port
30003 UDP      Steam query port
30004 UDP      Conan pinger port
30005 TCP      RCON port, optional to expose externally
```

For a home router, forward at least `30002` TCP/UDP, `30003` UDP, and `30004` UDP to the AMP host. Only forward `30005` TCP if you deliberately want RCON reachable from outside your LAN.

If the server is running locally but cannot be reached from outside, the likely causes are router/NAT forwarding, host firewall rules, or forwarding to the wrong LAN IP. A local listener on `30002/30003` does not prove the router is forwarding those ports from the internet.

## Sharing Through AMP Configuration Repositories

AMP can also consume templates from a GitHub configuration repository. For that workflow, publish the contents of `Conan Exiles/Template/` at the root of a repository and add it in AMP under:

```text
Configuration -> Instance Deployment -> Configuration Repositories
```

Use AMP's repository format:

```text
GitHubUserOrOrg/RepositoryName:branch
```

After adding the repository, refresh deployment templates or restart ADS. `Conan Exiles Enhancen (Elounia)` should then appear in the Create Instance application dropdown.

This repository's folder layout is meant for humans and helper scripts. AMP's configuration repository loader expects template files at the repository root, so use the installer above for this repository directly, or publish `Conan Exiles/Template/` as its own root-level AMP template repository.
