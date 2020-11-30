import ../common

proc digits(x: int): seq[int] =
  if x == 0: return @[0]
  var t = x
  while t > 0:
    result.add (t mod 10)
    t = t div 10

proc adj(ns: seq[int]): bool =
  for i in 0 ..< ns.len-1:
    if ns[i] == ns[i+1]: return true
  return false

proc incr(ns: seq[int]): bool = 
  for i in 1 ..< ns.len:
    if ns[i] > ns[i-1]:
      return false
  return true

proc main() =
  var cnt = 0
  for x in 168630 .. 718098:
    let xs = digits(x)
    if not adj(xs): continue
    if not incr(xs): continue
    cnt += 1
  echo cnt

when isMainModule:
  main()