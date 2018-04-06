# buildroot-bro

Patches for compiling Bro IDS with Buildroot. Package includes options to enable Broccoli and Python Broccoli bindings installation.

### Installing

Easy import using `BR2_EXTERNAL`. From your buildroot directory:

```
make BR2_EXTERNAL=path/to/buildroot_bro menuconfig
```

## Acknowledgments

* [krkhan/openwrt-bro](https://github.com/krkhan/openwrt-bro)
