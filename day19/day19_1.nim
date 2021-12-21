import moves
import sets
import deques

type 
  V3 = array[3, int]

proc abs*(v: V3): int = abs(v[0]) + abs(v[1]) + abs(v[2])

proc inv(flip: V3, perm: V3, v: V3): V3 =
  result[0] = flip[0] * v[perm[0]]
  result[1] = flip[1] * v[perm[1]]
  result[2] = flip[2] * v[perm[2]]
proc inv(tr: (V3, V3), v: V3): V3  = inv(tr[0], tr[1], v)

const views: seq[(V3,V3)] = block:
  var res: seq[(V3,V3)]
  for ps in permutation(3):
    for dir in 0..7:
      var ds = 2*digits(dir, 2)-1
      while ds.len < 3: ds.add -1
      res.add (toArray[3,int](ds), toArray[3,int](ps))
  res

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.split("\n\n").map(s => s.strip.splitLines)

  # m[i] = beacons of scanner i
  var m: seq[seq[V3]] = newSeq[seq[V3]](input.len)
  for i, x in input:
    for l in x[1..^1]:
      let ns = l.split(",").map(parseInt)
      m[i].add toArray[3,int](ns)

  # number of scanner
  let N = m.len
  
  var found = newSeq[bool](N)
  # scanners position 
  var scanners = newSeq[V3](N)
  # transformation of beacons of scanner i, inv(t[i], m[i][j]) + scanners[i] 
  var transforms = newSeq[(V3, V3)](N)

  # initialize state
  found[0] = true
  scanners[0] = [0,0,0]
  transforms[0] = ([1,1,1], [0,1,2])

  var queue: Deque[int]
  queue.addLast 0
  while queue.len > 0:
    let i = queue.popFirst()
    let b1 = m[i].map(x => inv(transforms[i], x) + scanners[i])

    # find scanners that has overlapped beacons with scanner-i
    for j in 0 ..< N:
      if found[j]: continue

      blocK tryTransform:
        for view in views:
          var b2 = newSeq[V3](m[j].len)
          for k in b2.bound:
            b2[k] = inv(view, m[j][k])
          
          for x1 in b1:
            for x2 in b2:
              let scanner = x1-x2 
              
              var cnt = 0
              for x in b2:
                if x + scanner in b1:
                  cnt += 1

              if cnt >= 12:
                if not found[j]: queue.addLast j
                found[j] = true
                transforms[j] = view
                scanners[j] = scanner
                break tryTransform

  # part 1
  var pos: HashSet[V3]
  for i in 0 ..< N:
    for x in m[i]:
      pos.incl (inv(transforms[i], x) + scanners[i])
  echo pos.len

  # part 2
  var ans2 = 0
  for i in 0 ..< N:
    for j in i+1 ..< N:
      ans2 = max(ans2, abs(scanners[i] - scanners[j]))
  echo ans2
    
when isMainModule:
  main("day19_sample_1.txt")
  main("day19_input.txt")  
  