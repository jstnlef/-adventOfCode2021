use "collections"
use "debug"
use "files"
use "../common"

actor Main
  new create(env: Env) =>
    let auth = try
      env.root as AmbientAuth
    else
      env.err.print("env.root must be AmbientAuth")
      return
    end

    let depths = parse_input(auth)

    let single_deltas = part1_single_delta(depths)
    env.out.print("Part 1 Depth increased: " + single_deltas.string())

    let sliding_deltas = part2_sliding_delta(depths)
    env.out.print("Part 2 Depth increased: " + sliding_deltas.string())


  fun parse_input(auth: AmbientAuth): Array[USize] =>
    let input = Array[USize]
    let path = FilePath(auth, "input.txt")
    with file = File(path) do
      let lines = file.lines()
      for line in file.lines() do
        input.push((consume line).usize()?)
      end
    end
    input

  fun part1_single_delta(depths: Array[USize]): USize =>
    var count: USize = 0
    var last: USize = 10000
    for depth in depths.values() do
      if depth > last then
        count = count + 1
      end
      last = depth
    end
    count

  fun part2_sliding_delta(depths: Array[USize]): USize =>
    var count: USize = 0
    try
      var last: USize = 1000000
      for i in Range(0, depths.size()) do
        let x = depths(i)?
        let y = depths(i+1)?
        let z = depths(i+2)?
        let sum = x + y + z
        if sum > last then
          count = count + 1
        end
        last = sum
      end
    end
    count
