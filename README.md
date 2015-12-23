# Arrayfire Lua Bindings

[ArrayFire](https://github.com/arrayfire/arrayfire) is a high performance library for parallel computing with an easy-to-use API. It enables users to write scientific computing code that is portable across CUDA, OpenCL and CPU devices. This project provides Lua bindings for the ArrayFire library.

The wrapper is currently compliant with ArrayFire 3.2 API (and higher). If you find any bugs, please report them [here](https://github.com/arrayfire/arrayfire-lua/issues).

## Example

```lua
local AF = require("arrayfire")

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

## Getting Started

### Requirements

- `cmake`
- `Visual Studio` on Windows, `clang` / `gcc` on Linux / OSX.

### Get ArrayFire libraries

You can install ArrayFire using one of the following two ways.

- [Download and install binaries](https://arrayfire.com/download)
- [Build and install from source](https://github.com/arrayfire/arrayfire)

**Post Installation Instructions**

- Please read [the wiki page](https://github.com/arrayfire/arrayfire-lua/wiki) for setting up the proper environment variables.

### Building the Lua module

**Windows**

1. Launch `cmake-gui`. Set source and build directories.
2. Press configure.
3. Select `generator` as `Visual Studio 12 2013 Win64`.
   - You can choose a different generator as long as it is Win64.
4. Set `CMAKE_INSTALL_PREFIX` to a location of choice.
5. Press generate. The generated visual studio solution file will be present in the build directory.
6. Open the VS solution file and build the `INSTALL` project.

**Linux / OSX**

1. Make sure the environment variable `ArrayFire_DIR` is set to `/path/to/arrayfire/share/ArrayFire/cmake`.
2. Create a build directory and `cd` into it.
3. Run `cmake /path/to/arrayfire-lua/ -DCMAKE_INSTALL_PREFIX=package`.
4. Run `make`

### Setting up Lua paths

**Windows**

    > SET LUA_PATH=C:\path\to\install\location\arrayfire\?.lua;;
    > SET LUA_CPATH=C:\path\to\install\location\?.dll;;
    > lua.exe helloworld/helloworld.lua

**Linux**

    $ export LUA_PATH="/path/to/install/location/arrayfire/?.lua;;"
    $ export LUA_CPATH="/path/to/install/location/?.so;;"
    $ lua helloworld/helloworld.lua


You should now be good to go!

## Issues

This is a work in progress and is not intended for production use.

## Acknowledgements

This project began with significant contributions from [Steven Johnson](https://github.com/ggcrunchy). It is currently being maintained by `@arrayfire/lua-devel` team.
