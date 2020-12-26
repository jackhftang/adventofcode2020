import ../common

const inputFilename = "day21_input.txt"
# const inputFilename = "day21_sample1.txt"
# const inputFilename = "day21_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc parse(s: string): (seq[string], seq[string]) =
  let ix = s.find('(')
  let aa = s[0..<ix].strip.split(' ')
  let bb = s[ix+"(contains ".len..^2].split(", ")
  return (aa,bb)

proc main2() =
  let input = readFile(inputFilePath).strip.split("\n").map(parse)
  let alla = input.map(x => x[0].toHashSet).foldl(a+b)
  let allb = input.map(x => x[1].toHashSet).foldl(a+b)
  
  # all possible
  var bs: Table[string, HashSet[string]]
  for b in allb:
    bs[b] = alla

  # intersection
  for (aa,bb) in input:
    let sa = aa.toHashSet
    for b in bb:
      bs[b] = bs[b] * sa

  # encode
  var encoder: StringEncoder
  var graph = newSeqWith(alla.len + allb.len, newSeq[int]())
  for a, bb in bs:
    let n = encoder.encode(a)
    for b in bb:
      let m = encoder.encode(b)
      graph[m].add n
      graph[n].add m

  # solve bipartite matching
  let (cnt, match) = bipartite(graph)
  assert cnt == allb.len

  # decode
  var matches: seq[(string, string)]
  for b in allb:
    let n = encoder.encode(b)
    let m = match[n]
    matches.add (b, encoder.decode(m))
  let ma = matches.map(x => x[1]).toHashSet

  # part 1
  var ans = 0
  for (aa, _) in input:
    for a in aa:
      if a notin ma:
        ans.inc
  echo ans

  # part 2
  echo matches.sorted((a,b) => cmp(a[0],b[0])).map(x => x[1]).join(",")

when isMainModule:
  main2()