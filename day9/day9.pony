use "collections"
use "debug"
use "itertools"
use "files"

actor Main
  let env: Env
  new create(env': Env) =>
    env = env'

    let map = parse_input(env.root)
    env.out.print("Lowest Point Risk: " + map.calculate_lowest_point_risk().string())
    env.out.print("Basin Risk: " + map.calculate_basin_risk().string())

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

  fun calculate_lowest_point_risk(): USize =>
    let lowest_points = find_lowest_points()
    var score: USize = 0
    for point in lowest_points.values() do
      score = score + 1 + point.height
    end
    score

  fun calculate_basin_risk(): USize =>
    let lowest_points = find_lowest_points()
    let sizes = Array[USize]
    for point in lowest_points.values() do
      sizes.push(calculate_basin_size(point))
    end
    let sorted = Sort[Array[USize], USize](sizes)
    Iter[USize](sorted.reverse().values()).take(3).fold[USize](1, { (n, x) => n * x })

  fun calculate_basin_size(point: Point): USize =>
    let seen: Set[Point] = Set[Point]
    let points_to_fill: Array[Point] = [point]
    while points_to_fill.size() > 0 do
      let p = try points_to_fill.shift()? else break end
      seen.set(p)

      var new_points = [try up(p)? end; try down(p)? end; try left(p)? end; try right(p)? end]
      for new_point in new_points.values() do
        match new_point
        | let new_p: Point =>
          if (new_p.height != 9) and
            (not seen.contains(new_p)) and
            (not points_to_fill.contains(new_p)) then
            points_to_fill.push(new_p)
          end
        end
      end
    end
    seen.size()

  fun up(point: Point): Point? =>
    _point(point.row - 1, point.column)?

  fun down(point: Point): Point? =>
    _point(point.row + 1, point.column)?

  fun right(point: Point): Point? =>
    _point(point.row, point.column + 1)?

  fun left(point: Point): Point? =>
    _point(point.row, point.column - 1)?

  fun _point(row: USize, column: USize): Point? =>
    let height = heights(row)?(column)?
    Point(height, row, column)

  fun find_lowest_points(): Array[Point] =>
    let lowest = Array[Point]
    try
      for rowi in Range(0, heights.size()) do
        let row = heights(rowi)?
        for columni in Range(0, row.size()) do
          let height = heights(rowi)?(columni)?
          if _is_lowest(height, rowi, columni) then
            lowest.push(Point(height, rowi, columni))
          end
        end
      end
      lowest
    else
      Debug.out("Had a problem finding lowest points.")
      Array[Point]
    end

  fun _is_lowest(height: USize, rowi: USize, columni: USize): Bool =>
    let up_p = try heights(rowi - 1)?(columni)? else 10 end
    let down_p = try heights(rowi + 1)?(columni)? else 10 end
    let right_p = try heights(rowi)?(columni + 1)? else 10 end
    let left_p = try heights(rowi)?(columni - 1)? else 10 end

    (height < up_p) and (height < down_p) and (height < right_p) and (height < left_p)


class val Point
  let height: USize
  let row: USize
  let column: USize

  new val create(height': USize, row':USize, column': USize) =>
    height = height'
    row = row'
    column = column'

  fun hash(): USize =>
    (height.hash() + row.hash() + column.hash()).hash()

  fun eq(other: Point): Bool =>
    (height == other.height) and (row == other.row) and (column == other.column)

  fun ne(other: Point): Bool =>
    not eq(other)

  fun string(): String iso^ =>
    "Point(height: " + height.string() + ", row: " + row.string() + ", column: " + column.string() + ")"
