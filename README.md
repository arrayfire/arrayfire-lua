# Arrayfire Lua Bindings

[ArrayFire](https://github.com/arrayfire/arrayfire) is a high performance library for parallel computing with an easy-to-use API. It enables users to write scientific computing code that is portable across CUDA, OpenCL and CPU devices. This project provides Lua bindings for the ArrayFire library.

The wrapper is currently compliant with ArrayFire 3.2 API (and higher). If you find any bugs, please report them [here](https://github.com/arrayfire/arrayfire-lua/issues).

## Example

```lua
local AF = require("af_lib")

AF.main(function()
      local x = AF.randu(5, "f32")
      AF.print("x", x)
      AF.print("min of x", AF.min(x))
      AF.print("max of x", AF.max(x))
end)
```

```
$ lua examples/lua/helloworld/intro.lua
ArrayFire v3.2.1 (CUDA, 64-bit Linux, build f263db0)
Platform: CUDA Toolkit 7.5, Driver: 358.16
[0] GeForce GTX 690, 2047 MB, CUDA Compute 3.0
-1- GeForce GTX 690, 2048 MB, CUDA Compute 3.0

x
[5 1 1 1]
0.7402
0.9210
0.0390
0.9690
0.9251

min of x
[1 1 1 1]
0.0390
max of x
[1 1 1 1]
0.9690

```

## Documentation

TODO

## Supported platforms

Currently, tested only Windows with [Lua 5.1](http://www.lua.org/ftp/lua-5.1.5.tar.gz).

- Progress being made on Linux and OSX with Lua 5.2 and 5.3

## Installing the dependencies

### Get ArrayFire libraries

You can install ArrayFire using one of the following two ways.

- [Download and install binaries](https://arrayfire.com/download)
- [Build and install from source](https://github.com/arrayfire/arrayfire)

**Post Installation Instructions**

- Please read [the wiki page](https://github.com/arrayfire/arrayfire-lua/wiki) for setting up the proper environment variables.

### Get Lua libraries and header files

If you do not have the pre-installed library, use the source in `arrayfire-lua/lua` folder for building the libraries.

The following pre-processors need to be set when building lua.

    - LUA_BUILD_AS_DLL
    - CRT_SECURE_NO_WARNINGS

## Building the arrayfire module

### Windows

Use the visual studio project file present in `src/Lua/arrayfire` to build the library.

### Linux / OSX

Use the `cmake` file in `src/Lua/arrayfire` to build the library.

- Ensure `ArrayFire_DIR` points to `/path/to/arrayfire/share/ArrayFire/cmake`

## Setting up the environment

### Linux / OSX

    $ export LUA_PATH="/path/to/arrayfire-lua/lib/?.lua;;"
    $ export LUA_CPATH="/path/to/arrayfire-lua/src/Lua/arrayfire/build/?.so;;"
    $ lua helloworld/helloworld.lua

## Issues

This is a work in progress and is not intended for production use.

## Acknowledgements

This project began with significant contributions from [Steven Johnson](https://github.com/ggcrunchy). It is currently being maintained by `@arrayfire/lua-devel` team.
