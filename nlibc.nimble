# Package

version       = "0.1.0"
author        = "emekoi"
description   = "a bare minimum \"libc\" for nim"
license       = "MIT"
srcDir        = "src"
bin           = @["nlibc"]
skipDirs      = @["tests"]

# Dependencies

requires "nim >= 0.18.0"
