import moves
import sets
import deques

type
  V3 = object
    x,y,z: int
proc `-`*(a,b: V3): V3 = V3(x: a.x-b.x, y: a.y-b.y, z: a.z-b.z)
proc `+`*(a,b: V3): V3 = V3(x: a.x+b.x, y: a.y+b.y, z: a.z+b.z)
proc `==`*(a,b: V3): bool = a.x == b.x and a.y == b.y and a.z == b.z
proc toSeq*(v: V3): seq[int] = @[v.x, v.y, v.z]
proc abs*(v: V3): int = abs(v.x) + abs(v.y) + abs(v.z)

proc inv(flip: seq[int], perm: seq[int], v: V3): V3 =
  let ys = v.toSeq
  result.x = flip[0] * ys[perm[0]]
  result.y = flip[1] * ys[perm[1]]
  result.z = flip[2] * ys[perm[2]]
proc inv(tr: (seq[int], seq[int]), v: V3): V3  = inv(tr[0], tr[1], v)

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.split("\n\n").map(s => s.strip.splitLines)

  # m[i] = beacons of scanner i
  var m: seq[seq[V3]] = newSeq[seq[V3]](input.len)
  for i, x in input:
    for l in x[1..^1]:
      let ns = l.split(",").map(parseInt)
      m[i].add V3(x:ns[0], y:ns[1], z:ns[2])
  # echo m

  # number of scanner
  let N = m.len
  
  var found = newSeq[bool](N)
  # scanners position 
  var scanners = newSeq[V3](N)
  # transformation of beacons of scanner i, inv(t[i], m[i][j]) + scanners[i] 
  var transforms = newSeq[(seq[int], seq[int])](N)

  # initialize state
  found[0] = true
  scanners[0] = V3(x:0,y:0,z:0)
  transforms[0] = (@[1,1,1], @[0,1,2])

  var queue: Deque[int]
  queue.addLast 0
  while queue.len > 0:
    let i = queue.popFirst()
    let b1 = m[i].map(x => inv(transforms[i], x) + scanners[i])
    let s1 = b1.toHashSet() 

    # find scanners that has overlapped beacons with scanner-i
    for j in 0 ..< N:
      if found[j]: continue

      blocK tryTransform:
        for ps in permutation(3):
          for dir in 0..7:
            var ds = 2*digits(dir, 2)-1
            while ds.len < 3: ds.add -1

            let b2 = m[j].map(x => inv(ds, ps, x))

            forProd x1, x2 in b1, b2:
              let cand = x1-x2 
              
              var cnt = 0
              for x in b2:
                if x + cand in s1:
                  cnt += 1

              if cnt >= 12:
                if not found[j]: queue.addLast j
                found[j] = true
                transforms[j] = (ds, ps) 
                scanners[j] = cand
                break tryTransform

  var pos: HashSet[V3]
  for i in 0 ..< N:
    for x in m[i]:
      pos.incl (inv(transforms[i], x) + scanners[i])
  echo pos.len

  var ans2 = 0
  for i in 0 ..< N:
    for j in i+1 ..< N:
      ans2 = max(ans2, abs(scanners[i] - scanners[j]))
  echo ans2
    
when isMainModule:
  main("day19_sample_1.txt")
  main("day19_input.txt")  
  