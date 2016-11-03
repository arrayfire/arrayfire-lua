package = "arrayfire"
version = "3.4-0"
source = {
   url = "git://github.com/arrayfire/arrayfire-lua",
   tag = "master",
   dir = "."
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
      ["arrayfire.device"] = "arrayfire/device.lua",
   },
}
