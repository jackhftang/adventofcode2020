import sequtils, tables, sets, strformat, strutils
export sequtils, tables, sets, strformat, strutils

proc abort*(xs: varargs[string, `$`]) =
  raise newException(ValueError, xs.join(" "))