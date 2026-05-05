# AMPGameServer

Community AMP/CubeCoders server templates and helper scripts.

This repository currently contains a Conan Exiles Enhanced template for AMP. It adds a separate `Conan Exiles Enhanced` application so users can create new Enhanced instances without replacing existing Conan Exiles Legacy instances.

## Included Templates

- `Conan Exiles/Template/` - AMP app template for Conan Exiles Enhanced dedicated servers.

## Quick Install To A Local AMP Server

On the Linux machine that hosts AMP, clone or download this repository, then run:

```bash
git clone <this-repository-url> AMPGameServer
cd AMPGameServer
bash scripts/install-conan-exiles-enhanced-amp.sh
```

If you are already inside the repository, just run:

```bash
bash scripts/install-conan-exiles-enhanced-amp.sh
```

The installer:

- finds the local AMP ADS deployment template cache;
- copies only the Conan Exiles Enhanced template files;
- backs up any previous local `conan-exiles-enhanced*` files before replacing them;
- validates the template JSON and Windows/Linux launch paths;
- commits the local AMP template-cache change when that cache is a git repository;
- restarts ADS so `Conan Exiles Enhanced` appears in the Create Instance dropdown.

The script does not delete existing AMP instances, datastores, saves, or Conan Exiles Legacy configuration.

If AMP is installed somewhere unusual, pass the location explicitly:

```bash
bash scripts/install-conan-exiles-enhanced-amp.sh --instances-root /home/amp/.ampdata/instances
```

or:

```bash
bash scripts/install-conan-exiles-enhanced-amp.sh --template-cache /path/to/ADS01/Plugins/ADSModule/DeploymentTemplates/CubeCoders-AMPTemplates-main
```

## Sharing Through AMP Configuration Repositories

AMP can also consume templates from a GitHub configuration repository. For that workflow, publish the contents of `Conan Exiles/Template/` at the root of a repository and add it in AMP under:

```text
Configuration -> Instance Deployment -> Configuration Repositories
```

Use AMP's repository format:

```text
GitHubUserOrOrg/RepositoryName:branch
```

After adding the repository, refresh deployment templates or restart ADS. `Conan Exiles Enhanced` should then appear in the Create Instance application dropdown.

This repository's folder layout is meant for humans and helper scripts. AMP's configuration repository loader expects template files at the repository root, so use the installer above for this repository directly, or publish `Conan Exiles/Template/` as its own root-level AMP template repository.
