import std/[uri, tables, strutils, options]
export pairs

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

proc fill*[T](s: string, v: var Option[T]) =
  var e: T
  s.fill(e)
  v = some(e)

proc fill*[T](values: Values, obj: var T) =
  for key, value in values:
    when T is ref object:
      for k, v in obj[].fieldPairs:
        if k == key:
          var v2: type(v)
          value.fill(v2)
          v = v2
    else:
      for k, v in obj.fieldPairs:
        if k == key:
          var v2: type(v)
          value.fill(v2)
          v = v2

proc toValue[T](v: T): string =
  $T

proc toValue[T](v: Option[T]): string =
  if isSome v:
    return $v.get()
  else: return ""

proc toValues*[T](obj: T): Values =
  for key, value in obj.fieldPairs:
    result[key] = value.toValue

proc fromValues*[T](values: Values, x: typedesc[T]): T =
  when x is ref object:
    new(result)
  values.fill(result)
