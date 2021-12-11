use "collections"
use "debug"
use "itertools"
use "files"

actor Main
  let env: Env
  new create(env': Env) =>
    env = env'

    let auth = try
      env.root as AmbientAuth
    else
      env.err.print("env.root must be AmbientAuth")
      return
    end

    let map = parse_input(auth)
    env.out.print("Risk: " + map.calculate_risk().string())

  fun parse_input(auth: AmbientAuth): HeightMap =>
    let heights = Array[Array[USize]]
    let path = FilePath(auth, "input.txt")
    with file = File(path) do
      for line in file.lines() do
        let row = Array[USize]
        for c in (consume line).runes() do
          row.push(String.from_utf32(c).usize(10)?)
        end
        heights.push(row)
      end
    end
    HeightMap(heights)


class HeightMap
  let heights: Array[Array[USize]]

  new create(heights': Array[Array[USize]]) =>
    heights = heights'

  fun calculate_risk(): USize =>
    let lowest_points = find_lowest_points()
    var score: USize = 0
    for height in lowest_points.values() do
      score = score + 1 + height
    end
    score

  fun find_lowest_points(): Array[USize] =>
    let lowest = Array[USize]
    try
      for rowi in Range(0, heights.size()) do
        let row = heights(rowi)?
        for columni in Range(0, row.size()) do
          let height = heights(rowi)?(columni)?
          if _is_lowest(height, rowi, columni) then
            lowest.push(height)
          end
        end
      end
      lowest
    else
      Debug.out("Had a problem finding lowest points.")
      Array[USize]
    end

  fun _is_lowest(height: USize, rowi: USize, columni: USize): Bool =>
    let up = try heights(rowi - 1)?(columni)? else 10 end
    let down = try heights(rowi + 1)?(columni)? else 10 end
    let right = try heights(rowi)?(columni + 1)? else 10 end
    let left = try heights(rowi)?(columni - 1)? else 10 end

    (height < up) and (height < down) and (height < right) and (height < left)
