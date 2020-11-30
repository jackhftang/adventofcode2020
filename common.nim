import sequtils, tables, sets, strformat, strutils, math, options
export sequtils, tables, sets, strformat, strutils, math, options

proc abort*(xs: varargs[string, `$`]) =
  # shorter raise exception
  raise newException(ValueError, xs.join(" "))

proc bsearchMax*[T: SomeInteger](lo, up: T, test: proc(t: T): bool): T =
  # find maximun value v in [lo, up] such that test(v) hold
  # test(lo) is assumed to be true
  var a = lo
  var b = up
  while a + 1 < b:
    let mid = (a+b) div 2
    if test(mid): a = mid
    else: b = mid
  result = a

proc bsearchMin*[T: SomeInteger](lo, up: T, test: proc(t: T): bool): T =
  # find minimum value v in [lo, up] such that test(v) hold
  # test(up) is assumed to be true
  var a = lo
  var b = up
  while a + 1 < b:
    let mid = (a+b) div 2
    if test(mid): b = mid
    else: a = mid
  result = b