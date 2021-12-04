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
    env.out.print("Gamma rate: " + diagnostic.gamma_rate.string())
    env.out.print("Epsilon rate: " + diagnostic.epsilon_rate.string())
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
  let readings: Array[USize]
  let gamma_rate: USize
  let epsilon_rate: USize

  new create(bit_length': USize, readings': Array[USize]) =>
    bit_length = bit_length'
    readings = readings'
    gamma_rate = _gamma_rate(bit_length, readings)
    epsilon_rate = _epsilon_rate(bit_length, gamma_rate)

  fun power_consumption(): USize =>
    gamma_rate * epsilon_rate

  fun tag _gamma_rate(bit_length': USize, readings': Array[USize]): USize =>
    var rate: USize = 0
    var num_ones: USize = 0
    for i in Range(0, bit_length') do
      for v in readings'.values() do
        let extracted = (v >> i) and 1
        num_ones = num_ones + extracted
      end

      if num_ones > (readings'.size() / 2) then
        rate = rate + (1 << i)
      end
      num_ones = 0
    end
    rate

  fun tag _epsilon_rate(bit_length': USize, gamma_rate': USize): USize =>
    (1 << bit_length') - gamma_rate' - 1
