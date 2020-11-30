import ../common

proc digits(x: int): seq[int] =
  if x == 0: return @[0]
  var t = x
  while t > 0:
    result.add (t mod 10)
    t = t div 10

proc adj(ns: seq[int]): bool =
  var m: seq[(int,int)]
  var i = 0
  var j = 0
  while i < ns.len:
    j = i+1
    while j < ns.len and ns[j] == ns[i]:
      j += 1
    let l = j-i
    if l > 1:
      m.add (ns[i], l)
    i = j

  if m.len == 0: return false

  return m.any(proc(x: (int,int)): bool = x[1] == 2)

  # m.sort(proc(a,b: (int,int)): int =
  #   return b[0] - a[0]
  # )
  # return m[0][1] == 2

  # var m2 = m
  # m2.sort(proc(a,b: (int,int)): int =
  #   let t = b[1] - a[1]
  #   if t != 0: return t
  #   return a[0] - b[0]
  # )
  # echo m
  # echo m2

  # return m2[0] != m[0]

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
  # echo adj(digits(112233))
  # echo adj(digits(123444))
  # echo adj(digits(111122))