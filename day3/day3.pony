use "collections"
use "itertools"
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

    env.out.print("O2 Generator rating: " + diagnostic.o2_generator_rating.string())
    env.out.print("CO2 Scrubber rating: " + diagnostic.co2_scrubber_rating.string())
    env.out.print("Life Support Rating: " + diagnostic.life_support_rating().string())

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


primitive BitUtils
  fun tag extract_bit(reading: USize, bit: USize): USize => (reading >> (bit - 1)) and 1

  fun tag most_common(readings: Array[USize], bit: USize): USize =>
    var count: ISize = 0
    for v in readings.values() do
      let extracted = BitUtils.extract_bit(v, bit)
      if extracted == 1 then
        count = count + 1
      else
        count = count - 1
      end
    end

    if count < 0 then
      0
    else
      1
    end

  fun tag least_common(readings: Array[USize], bit: USize): USize =>
    if BitUtils.most_common(readings, bit) == 1 then 0 else 1 end


class Diagnostic
  let bit_length: USize
  let readings: Array[USize]
  let gamma_rate: USize
  let epsilon_rate: USize
  let o2_generator_rating : USize
  let co2_scrubber_rating : USize

  new create(bit_length': USize, readings': Array[USize]) =>
    bit_length = bit_length'
    readings = readings'
    gamma_rate = _gamma_rate(bit_length, readings)
    epsilon_rate = _epsilon_rate(bit_length, gamma_rate)
    o2_generator_rating = _o2_generator_rating(readings, bit_length)
    co2_scrubber_rating = _co2_scrubber_rating(readings, bit_length)

  fun power_consumption(): USize =>
    gamma_rate * epsilon_rate

  fun life_support_rating(): USize =>
    o2_generator_rating * co2_scrubber_rating

  fun tag _o2_generator_rating(readings': Array[USize], bit: USize): USize =>
    _find_rating(readings', bit, {(r, b) => BitUtils.most_common(r, b)})

  fun tag _co2_scrubber_rating(readings': Array[USize], bit: USize): USize =>
    _find_rating(readings', bit, {(r, b) => BitUtils.least_common(r, b)})

  fun tag _find_rating(
    readings': Array[USize],
    bit: USize,
    find_common: {(Array[USize], USize): USize}
  ): USize =>
    if (readings'.size() == 1) then
      return try readings'(0)? else 0 end
    end

    let common = find_common(readings', bit)
    let filtered = Iter[USize](readings'.values())
      .filter({(reading) => BitUtils.extract_bit(reading, bit) == common})
      .collect(Array[USize](readings'.size()))

    _find_rating(filtered, bit - 1, find_common)

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
