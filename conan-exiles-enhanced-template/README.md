# Conan Exiles Enhanced AMP template

Local staging template for Conan Exiles Enhanced on Linux AMP hosts.

## What changed from CubeCoders' current Legacy template

- Uses Steam app `443030` on the `public` branch instead of `conan-exiles-legacy`.
- Lets SteamCMD select the Linux depot (`443032`) on Linux hosts instead of forcing the Windows depot (`443031`).
- Starts the native Linux server binary from depot `443032`: `ConanSandbox/Binaries/Linux/ConanSandboxServer-Linux-Shipping`.
- Uses `cubecoders/ampbase:debian` instead of the Wine container image.
- Keeps server data under `./conan-exiles-enhanced/` so it does not overlap with an existing Legacy instance.

## Install options

Option A, local ADS copy:

```bash
sudo -u amp mkdir -p /home/amp/.ampdata/instances/ADS01/Plugins/ADSModule/GenericTemplates
sudo cp conan-exiles-enhanced-template/conan-exiles-enhanced* /home/amp/.ampdata/instances/ADS01/Plugins/ADSModule/GenericTemplates/
sudo chown amp:amp /home/amp/.ampdata/instances/ADS01/Plugins/ADSModule/GenericTemplates/conan-exiles-enhanced*
```

Adjust `ADS01` if the ADS instance has a different name.

Option B, GitHub template repo:

Create a tiny public GitHub repo containing only the five `conan-exiles-enhanced*` files from this directory at the repo root. Then add that repo in AMP under `Configuration -> Instance Deployment -> Configuration Repositories`, for example:

```text
your-user/your-amp-templates:main
```

After either option, restart ADS or refresh deployment templates, then create a new instance from `Conan Exiles Enhanced`.

## Notes

This template is intentionally Linux-only because the local AMP host is Linux and the Enhanced Linux depot now exists. It does not modify or remove existing Legacy data.
