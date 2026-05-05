# Conan Exiles Enhanced AMP Template

Community AMP app template for Conan Exiles Enhanced dedicated servers.

## Supported Platforms

- Windows: Steam app `443030`, public branch, depot `443031`.
- Linux: Steam app `443030`, public branch, depot `443032`.

The template intentionally uses the Steam `public` branch. Do not set `UpdateSourceVersion` to `conan-exiles-legacy` unless you want the old UE4 server.

## What It Does

- Adds a distinct `Conan Exiles Enhanced` app in AMP.
- Downloads the current Enhanced dedicated server from Steam app `443030`.
- Uses the native Linux server on Linux hosts instead of Wine.
- Uses the native Windows server on Windows hosts.
- Keeps server files under `./conan-exiles-enhanced/443030/` so it does not overlap with existing Legacy instances.
- Uses the current Steam Store Enhanced header image for the AMP app/instance cover.

## AMP Repository Use

This repository keeps the template under `Conan Exiles/Template/` for project organization. For an AMP configuration repository, publish the contents of this directory at the repository root:

- `manifest.json`
- `conan-exiles-enhanced.kvp`
- `conan-exiles-enhancedconfig.json`
- `conan-exiles-enhancedmetaconfig.json`
- `conan-exiles-enhancedports.json`
- `conan-exiles-enhancedupdates.json`

Then add that repository in AMP:

```text
Configuration -> Instance Deployment -> Configuration Repositories
```

Use the normal AMP repository format:

```text
GitHubUserOrOrg/RepositoryName:branch
```

For example:

```text
YourUser/amp-community-templates:main
```

After adding or updating the repository, refresh deployment templates or restart ADS, then create a new instance from `Conan Exiles Enhanced`.

For a pull request to CubeCoders' upstream `AMPTemplates` repository, keep these same files at the top level of the submitted template repo layout. Do not include local install scripts, absolute AMP paths, or machine-specific instance names.

## Notes For Maintainers

The old Legacy AMP template used Windows server files under Wine on Linux because the `conan-exiles-legacy` branch has no Linux depot content. The Enhanced `public` branch now has both Windows and Linux depots, so Wine is not needed for Linux Enhanced instances.
