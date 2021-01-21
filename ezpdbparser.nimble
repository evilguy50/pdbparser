# Package

version       = "0.1.0"
author        = "CodeHz"
description   = "PdbParser for ElementZero"
license       = "LGPL-3.0"
srcDir        = "."
installExt    = @["nim", "h", "dll"]
bin           = @["ezpdbparser"]
backend       = "cpp"
# Dependencies

requires "nim >= 1.4.2"
requires "winim"
requires "ezsqlite3"
requires "cppinterop"

from os import `/`
from strutils import strip

task prepare, "Prepare dlls":
  cpFile(gorge("nimble path ezsqlite3").strip / "sqlite3.dll", "sqlite3.dll")

before build:
  prepareTask()