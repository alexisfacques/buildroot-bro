# Bro IDS for Buildroot

Configurations, patches and .mk files for compiling [Bro IDS](https://www.bro.org/) in [Buildroot](https://buildroot.org/)

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Installing

Recursively copy the [`/package`](./package) folder to your **Buildroot** directory.

```
cp -rf ./package/* ${BUILDROOT_DIR}/package
```

### Troubleshooting

If used with other project-specific packages, please patch the  [`./package/Config.in`](./package/Config.in) file accordingly.

## Known issues

- Host installation may not be configured appropriately. Host package installation (required for building `bifcl` and `binpac` executanles) requires the following to be installed locally on the machine :
  - `libpcap`
  - `openssl`
  - `bind`

  Initially had some trouble to add these as `HOST_BRO_DEPENDENCIES`.

## Contributors

- **Alexis Facques** - *Initial work* - [/alexisfacques](https://github.com/alexisfacques)

## External references
- [Adding project-specific packages](https://buildroot.org/downloads/manual/manual.html#customize-packages)
- [cmake-package example](https://github.com/maximeh/buildroot/blob/master/docs/manual/adding-packages-cmake.txt)
