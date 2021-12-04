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

    let diagnostic = parse_input(auth)
    env.out.print("Bit length: " + diagnostic.bit_length.string())
    env.out.print("Gamma rate: " + diagnostic.gamma_rate().string())
    env.out.print("Epsilon rate: " + diagnostic.epsilon_rate().string())
    env.out.print("Power Comsumption: " + diagnostic.power_consumption().string())

  fun parse_input(auth: AmbientAuth): Diagnostic =>
    let lines = Array[USize](1000)
    var bit_length: USize = 0
    let path = FilePath(auth, "input.txt")
    with file = File(path) do
      for line in file.lines() do
        bit_length = line.size()
        lines.push((consume line).usize(2)?)
      end
    end
    Diagnostic(bit_length, lines)


class Diagnostic
  let bit_length: USize
  let vals: Array[USize]

  new create(bit_length': USize, vals': Array[USize]) =>
    bit_length = bit_length'
    vals = vals'

  fun power_consumption(): USize =>
    gamma_rate() * epsilon_rate()

  fun gamma_rate(): USize =>
    var rate: USize = 0
    var num_ones: USize = 0
    for i in Range(0, bit_length) do
      for v in vals.values() do
        let extracted = (v >> i) and 1
        num_ones = num_ones + extracted
      end

      if num_ones > (vals.size() / 2) then
        rate = rate + (1 << i)
      end
      num_ones = 0
    end
    rate

  fun epsilon_rate(): USize =>
    (1 << bit_length) - gamma_rate() - 1
