import moves



proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var es: Enumerator[string]
  var input = rawInput.splitLines.map(s => s.split("-").map(s => es.encode(s)))

  var smalls: seq[int]
  for s in es:
    if s[0].isLowerAscii:
      smalls.add es.encode(s)

  var adj = zeros(int, es.len, 0)
  for xs in input:
    adj[xs[0]].add xs[1]
    adj[xs[1]].add xs[0]

  let dest = es.encode("end")
  var dp: Table[(int, seq[int]), int]
  proc solve(n: int, visited: seq[int]): int =
    if n == dest:
      return 1
    
    let key = (n, visited)
    # echo key
    if key in dp: 
      return dp[key]

    var v = visited
    if n in smalls:
      let i = smalls.find(n)
      if v[i] > 0: return 0
      else: v[i] += 1

    for nei in adj[n]:
      result += solve(nei, v)
      
    dp[key] = result

  echo solve(es.encode("start"), zeros(int, smalls.len))  

when isMainModule:
  main("day12_sample_1.txt")
  main("day12_sample_2.txt")
  main("day12_sample_3.txt")
  main("day12_input.txt")  
  