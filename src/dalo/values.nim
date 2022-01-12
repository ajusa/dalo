import std/[uri, tables, strutils]

type Values* = OrderedTable[string, string] # Holds values from submitting form
const SEP* = "\28" # AWK uses this, non printing char
proc initValues*(qs: string): Values =
  for (name, value) in qs.decodeQuery:
    var val = value.replace(SEP) # Ensure SEP doesn't appear in the string
    if name in result:
      result[name] &= SEP & val
    else:
      result[name] = val

proc fill(s: string, v: var int) =
  v = parseInt(s)

proc fill(s: string, v: var string) =
  v = s

proc fill(s: string, v: var float) =
  v = parseFloat(s)

proc fromValues[T](values: Values, obj: var T) =
  for key, value in values:
    for k, v in obj.fieldPairs:
      if k == key:
        var v2: type(v)
        value.fill(v2)
        v = v2

when isMainModule:
  import print
  type Person = object
    name: string
    age: int
  var test = initValues("name=asdf&age=5")
  var p: Person
  test.fromValues(p)
  echo p

