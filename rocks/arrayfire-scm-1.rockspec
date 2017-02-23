package = "arrayfire"
version = "scm-1"
source = {
   url = "git://github.com/pavanky/arrayfire-lua",
   tag = "devel",
   dir = "arrayfire-lua"
}
description = {
   summary = "Lua Bindings for ArrayFire",
   homepage = "http://github.com/arrayfire",
   license = "BSD-3"
}
dependencies = {
   "lua >= 5.1, < 5.4",
}
build = {
   type = "builtin",
   modules = {
      arrayfire = "arrayfire.lua",
      ["arrayfire.lib"]    = "arrayfire/lib.lua",
      ["arrayfire.util"]   = "arrayfire/util.lua",
      ["arrayfire.array"]  = "arrayfire/array.lua",
      ["arrayfire.defines"] = "arrayfire/defines.lua",
      ["arrayfire.device"] = "arrayfire/device.lua",
   },
}
