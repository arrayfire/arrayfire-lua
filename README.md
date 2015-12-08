(Pilfered from [Rust's README](https://github.com/arrayfire/arrayfire-rust), adapting...)

# Arrayfire Lua Bindings

[ArrayFire](https://github.com/arrayfire/arrayfire) is a high performance library for parallel computing with an easy-to-use API. It enables users to write scientific computing code that is portable across CUDA, OpenCL and CPU devices. This project provides Lua bindings for the ArrayFire library. The wrapper is currently compliant with ArrayFire 3.2 API (and lower).  If you find any bugs, please report them [here](https://github.com/arrayfire/arrayfire-lua/issues).

## Documentation

You can find the most recent updated documentation TODO.

## Supported platforms

Currently, only Windows. So far compiles with Lua 5.1.

## Build from Source

You can install ArrayFire using one of the following two ways.

- [Download and install binaries](https://arrayfire.com/download)
- [Build and install from source](https://github.com/arrayfire/arrayfire)

arrayfire depends on Lua, client depends on both (TODO: probably should add -lua suffix...)
Linkage required for appropriate ArrayFire library

TODO: point to Lua 5.1 (not sure on 5.2, 5.3... should do 5.0?) and LuaJIT source. Alternatives such as Ravi and Terra?

Preprocessor stuff:

	For Lua: LUA_BUILD_AS_DLL; Windows-specific: _CRT_SECURE_NO_WARNINGS
	For arrayfire: AFDLL

	Not implemented: WANT_CUDA, WANT_OPENCL to include interface bindings (are there already alternatives?)

Setup:

	Configuring package.path, package.cpath (ArrayFireWrapper/ArrayFireWrapper.cpp doing this, for Windows anyhow)
	LuaJIT FFI looking for some variables (TODO: explain)
	
## Example



### Sample output


## Issues


## Note

This is a work in progress and is not intended for production use.

## Acknowledgements

The ArrayFire library is written by developers at [ArrayFire](http://arrayfire.com) LLC
with (TODO: contributions)?

The developers at ArrayFire LLC have received partial financial support
from several grants and institutions. Those that wish to receive public
acknowledgement are listed below:

### Grants

(Not sure if this was for Rust or ArrayFire... if the latter, add back in)