use "collections"
use "debug"
use "itertools"
use "files"

actor Main
  let env: Env
  new create(env': Env) =>
    env = env'

    let octopi = parse_input(env.root)
    let flashes = octopi.simulate(100)
    env.out.print("Flashes after 100 iterations: " + flashes.string())

  fun parse_input(auth: AmbientAuth): Octopi =>
    var octopi = Array[USize]
    let path = FilePath(auth, "example_input.txt")
    with file = File(path) do
      for line in file.lines() do
        for n in (consume line).runes() do
          let parsed = String.from_utf32(n).usize(10)?
          octopi.push(parsed)
        end
      end
    end
    Octopi(octopi)


class Octopi
  let _width: USize = 10
  let _grid: Matrix

  new create(octopi: Array[USize]) =>
    _grid = Matrix(octopi, _width)

  fun ref simulate(iterations: USize): USize =>
    var flashes: USize = 0
    for i in Range(0, iterations) do
      flashes = flashes + _run_iteration()
    end
    flashes

  fun ref _run_iteration(): USize =>
    var flashes: USize = 0
    // Step 1
    for row in Range(0, _width) do
      for column in Range(0, _width) do
        try
          _grid.increment(row, column, 1)?
        end
      end
    end
    Debug.out(string())
    flashes

  fun string(): String iso^ =>
    var s = "Octopi:\n"
    var count: USize = 1
    for n in _grid.values() do
      s = s + n.string()
      if (count % 10) == 0 then
        s = s + "\n"
      end
      count = count + 1
    end
    s.string()


class Matrix
  let _width: USize
  let _inner: Array[USize]

  new create(vals: Array[USize], width: USize) =>
    _width = width
    _inner = vals

  fun get(row: USize, column: USize): USize? =>
    _inner(_index(row, column))?

  fun ref set(row: USize, column: USize, v: USize): USize? =>
    _inner(_index(row, column))? = v

  fun ref increment(row: USize, column: USize, n: USize)? =>
    let i = _index(row, column)
    let value = _inner(i)?
    _inner(i)? = value + n

  fun _index(row: USize, column: USize): USize =>
    (row * _width) + column

  fun values(): ArrayValues[USize, this->Array[USize]]^ =>
    _inner.values()
