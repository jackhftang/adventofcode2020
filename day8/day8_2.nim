import moves

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
    var g = newSeqWith(7, arange(7))
    for x in xs[0]:
      let y = x.map(c => c.ord - 'a'.ord).toHashSet
      let xlen = x.len
      # largest common segment
      let cs = data.filter(g => g.sum == xlen).fold((a,b) => a*b)
      for i, v in cs:
        if v == 1:
          g[i] = intersection(g[i].toHashSet, y).toseq
          
    # matching 
    let match = bipartite(g)
    assert match.len == 7, "no match"

    # reverse to digits
    var rev = match.toTable.inversedUnique
    var ds: seq[int]
    for x in xs[1]:
      let ns = x.map(c => rev[c.ord - 'a'.ord])
      var arr = zeros(int, 7)
      for n in ns: arr[n] = 1
      ds.add data.find(arr)
    ans += ds.reversed.fromDigits(10)
   
  echo ans

when isMainModule:
  main("day8_sample2.txt")
  main("day8_input.txt")  
