proc symhash*(symbol: string): int64 =
  const fnv_prime = 1099511628211
  result = cast[int64](14695981039346656037u64)
  for ch in symbol:
    result = result *% fnv_prime
    result = result xor int64(ch)

when isMainModule:
  import parseopt
  import options
  import winim/mean
  import ezpdbparserpkg/dia2
  import ezsqlite3

  CoInitializeEx(nil, 0)

  proc parsePrint(target: string) =
    echo target
    var source = createDataSource()
    var session = source.loadSession(target)
    var global = session.global
    for symbol in global.findChildren(SymTagPublicSymbol):
      echo "symbol(", symhash(symbol.name), "): ", symbol.virtualAddress.toHex, "=", symbol.name

  proc create_full_table() {.
    importdb: "CREATE TABLE IF NOT EXISTS symbols_full (symbol INTEGER PRIMARY KEY, name TEXT, address INTEGER) WITHOUT ROWID".}
  proc insert_full_symbol(symbol: int64, name: string, address: int) {.
    importdb: "REPLACE INTO symbols_full VALUES ($symbol, $name, $address)".}
  proc create_hash_table() {.
    importdb: "CREATE TABLE IF NOT EXISTS symbols_hash (symbol INTEGER PRIMARY KEY, address INTEGER) WITHOUT ROWID".}
  proc insert_hash_symbol(symbol: int64, address: int) {.
    importdb: "REPLACE INTO symbols_hash VALUES ($symbol, $address)".}

  proc parseSave(target: string, db: string, full: bool) =
    var source = createDataSource()
    var session = source.loadSession(target)
    var global = session.global
    var db = newDatabase(db)
    db[].create_hash_table()
    if full:
      db[].create_full_table()
    var tran = db.initTransaction()
    for symbol in global.findChildren(SymTagPublicSymbol):
      let hash = symhash(symbol.name)
      db[].insert_hash_symbol(hash, symbol.virtualAddress)
      if full:
        db[].insert_full_symbol(hash, symbol.name, symbol.virtualAddress)
    tran.commit()

  proc writeHelp() =
    echo "pdb parser"
    echo "usage:"
    echo "pdbparser <bedrock_server.pdb> [--database:sqlite3db]"

  var p = initOptParser()

  var filename = none string
  var database = none string
  var full = false

  for kind, key, val in p.getopt():
    case kind:
#    of cmdEnd: assert(false)
    of cmdArgument:
      if filename.isNone():
        filename = some key
      else:
        quit "too many arguments"
    of cmdShortOption, cmdLongOption:
      case key:
      of "h", "help":
        writeHelp()
        quit 0
      of "full":
        full = true
      of "database":
        if val == "":
          quit "need database filename"
        database = some val
      else:
        echo "invalid option: ", key
        quit 1

  if filename.isNone():
    writeHelp()
    quit 0

  if database.isNone():
    parsePrint(filename.unsafeGet())
    quit 0

  parseSave(filename.unsafeGet(), database.unsafeGet(), full)
