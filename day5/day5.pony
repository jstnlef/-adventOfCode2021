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

    let floor = parse_input(auth)
    var count = floor.count_dangerous_areas(false)
    env.out.print("Number of dangerous areas no diagonals: " + count.string())

    count = floor.count_dangerous_areas(true)
    env.out.print("Number of dangerous areas with diagonals: " + count.string())


  fun parse_input(auth: AmbientAuth): OceanFloor =>
    let lines = Array[VentLine]
    let path = FilePath(auth, "input.txt")
    with file = File(path) do
      for line in file.lines() do
        let split = line.split_by(" -> ")
        let from = Pos.from_string(split(0)?)?
        let to = Pos.from_string(split(1)?)?
        Debug.out("From: " + from.string() + " " + "To: " + to.string())
        let vent_line = VentLine(from, to)
        lines.push(vent_line)
      end
    end
    OceanFloor(lines)


class OceanFloor
  var floor: Map[Pos, USize]
  let lines: Array[VentLine]
  var max_x: USize = 0
  var max_y: USize = 0

  new create(lines': Array[VentLine]) =>
    lines = lines'

    for line in lines.values() do
      if line.max_x() > max_x then
        max_x = line.max_x()
      end
      if line.max_y() > max_y then
        max_y = line.max_y()
      end
    end

    Debug.out("max x: " + max_x.string() + " " + "max y: " + max_y.string())
    floor = Map[Pos, USize]

  fun ref count_dangerous_areas(diag: Bool): USize =>
    floor = Map[Pos, USize]
    _map_vents(diag)
    // Debug.out("Mapped:\n" + string())

    var count: USize = 0
    for pos in floor.values() do
      if pos > 1 then
        count = count + 1
      end
    end
    count

  fun ref _map_vents(diag: Bool) =>
    for line in lines.values() do
      _map_vent(line, diag)
    end

  fun ref _map_vent(line: VentLine, diag: Bool) =>
    for pos in line.positions(diag).values() do
      let updated = try
        floor(pos)? + 1
      else
        1
      end
      floor.update(pos, updated)
    end

  fun string(): String iso^ =>
    var s = recover iso String.create() end
    for i in Range(0, max_x + 1) do
      for j in Range(0, max_y + 1) do
        let v: USize = try
          floor(Pos(j, i))?
        else
          0
        end
        s = s + v.string() + " "
      end
       s = s + "\n"
    end
    s


class val VentLine
  let from: Pos
  let to: Pos

  new val create(from': Pos, to': Pos) =>
    from = from'
    to = to'

  fun positions(diag: Bool): Array[Pos] =>
    var positions' = Array[Pos]

    if is_vertical() then
      for i in Range(min_y(), max_y() + 1) do
        positions'.push(Pos(from.x, i))
      end
    elseif is_horizontal() then
      for i in Range(min_x(), max_x() + 1) do
        positions'.push(Pos(i, from.y))
      end
    else
      if diag then
        positions'.push(from)
        var start = from
        for i in Range(min_x(), max_x()) do
          let new_pos = match direction()
          | NE => Pos(start.x + 1, start.y - 1)
          | NW => Pos(start.x - 1, start.y - 1)
          | SE => Pos(start.x + 1, start.y + 1)
          | SW => Pos(start.x - 1, start.y + 1)
          end
          positions'.push(new_pos)
          start = new_pos
        end
      end
    end

    positions'

  fun direction(): Direction =>
    if (from.x < to.x) and (from.y > to.y) then
      NE
    elseif (from.x > to.x) and (from.y > to.y) then
      NW
    elseif (from.x < to.x) and (from.y < to.y) then
      SE
    else
      SW
    end

  fun is_vertical(): Bool =>
    from.x == to.x

  fun is_horizontal(): Bool =>
    from.y == to.y

  fun max_x(): USize =>
    if from.x > to.x then from.x else to.x end

  fun max_y(): USize =>
    if from.y > to.y then from.y else to.y end

  fun min_x(): USize =>
    if from.x < to.x then from.x else to.x end

  fun min_y(): USize =>
    if from.y < to.y then from.y else to.y end

  fun string(): String iso^ =>
    "VentLine(From: " + from.string() + " To: " + to.string() + ")"


class val Pos
  let x: USize
  let y: USize

  new val create(x': USize, y': USize) =>
    x = x'
    y = y'

  new val from_string(s: String)? =>
    let split = s.split(",")
    x = split(0)?.usize()?
    y = split(1)?.usize()?

  fun string(): String iso^ =>
    "(" + x.string() + ", " + y.string() + ")"

  fun hash(): USize =>
    (x.hash() + y.hash()).hash()

  fun eq(other: Pos): Bool =>
    (x == other.x) and (y == other.y)

  fun ne(other: Pos): Bool =>
    not eq(other)


primitive NW
primitive NE
primitive SW
primitive SE
type Direction is (NW | NE | SW | SE)
