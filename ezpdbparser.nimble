# Package

version       = "0.1.0"
author        = "CodeHz"
description   = "PdbParser for ElementZero"
license       = "LGPL-3.0"
srcDir        = "src"
installExt    = @["nim", "h"]
bin           = @["ezpdbparser"]


# Dependencies

requires "nim >= 1.4.2"
requires "winim"
requires "ezsqlite3"
requires "cppinterop"