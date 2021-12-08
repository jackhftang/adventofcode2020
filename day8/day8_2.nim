import ../common

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines.map(s => s.split(" | ").map(ss => ss.strip.split(" ")))

  #[
     0
    1 2
     3
    4 5
     6
  ]#
  let data = @[
    @[1, 1, 1, 0, 1, 1, 1],
    @[0, 0, 1, 0, 0, 1, 0],
    @[1, 0, 1, 1, 1, 0, 1],
    @[1, 0, 1, 1, 0, 1, 1],
    @[0, 1, 1, 1, 0, 1, 0],
    @[1, 1, 0, 1, 0, 1, 1],
    @[1, 1, 0, 1, 1, 1, 1],
    @[1, 0, 1, 0, 0, 1, 0],
    @[1, 1, 1, 1, 1, 1, 1],
    @[1, 1, 1, 1, 0, 1, 1],
  ]

  var ans = 0
  for xs in input:
    # build graph
    var g = newSeqWith(14, newSeq[int]())
    for i in 0..6:
      g[i] = arange(7,14)
    forSum x in xs[1], xs[0]:
      let y = x.map(c => c.ord - 'a'.ord + 7).toHashSet
      let n = x.len
      # largest common configuration
      let cs = data.filter(g => g.sum == n).transpose.map(lis => lis.prod)
      for i, v in cs:
        if v == 1:
          g[i] = intersection(g[i].toHashSet, y).toseq
    
    # matching 
    let (nMatch, match) = bipartite(g)
    assert nMatch == 7, "no match"

    # reverse to digits
    var ds: seq[int]
    for x in xs[1]:
      let ns = x.map(c => match[c.ord - 'a'.ord + 7])
      var arr = zeros(int, 7)
      for n in ns: arr[n] = 1
      ds.add data.find(arr)
    ans += ds.reversed.fromDigits(10)
   
  echo ans

when isMainModule:
  main("day8_sample2.txt")
  main("day8_input.txt")  
