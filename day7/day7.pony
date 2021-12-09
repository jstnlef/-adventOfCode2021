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

    let positions = parse_input(auth)

    let fuel = calculate_min_fuel(positions)
    env.out.print("Min fuel: " + fuel.string())

  fun calculate_min_fuel(positions: Array[USize]): USize =>
    var min = USize.max_value()
    var max: USize = 0

    for position in positions.values() do
      if position > max then
        max = position
      end
      if position < min then
        min = position
      end
    end

    Debug.out("Min: " + min.string())
    Debug.out("Max: " + max.string())

    var min_fuel = USize.max_value()
    for i in Range(min, max + 1) do
      let fuel = calc_fuel(i, positions)
      if fuel < min_fuel then
        min_fuel = fuel
      end
    end
    min_fuel

  fun calc_fuel(v: USize, positions: Array[USize]): USize =>
    var fuel: USize = 0
    for pos in positions.values() do
      fuel = fuel + (pos - v).isize().abs()
    end
    Debug.out("Fuel: " + fuel.string())
    fuel

  fun parse_input(auth: AmbientAuth): Array[USize] =>
    let positions = Array[USize]
    let path = FilePath(auth, "input.txt")
    with file = File(path) do
      let read = file.read_string(file.size())
      let split = read.split_by(",")
      for n in (consume split).values() do
        positions.push(n.usize()?)
      end
    end
    positions
