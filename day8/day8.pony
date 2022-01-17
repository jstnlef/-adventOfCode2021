use "collections"
use "debug"
use "itertools"
use "files"

actor Main
  let env: Env
  new create(env': Env) =>
    env = env'

    let patterns = parse_input(env.root)
    let unique_count = count_unique_digits(patterns)
    env.out.print("Unique digits: " + unique_count.string())

    let sum_of_deduced = sum_up_deduced_digits(patterns)
    env.out.print("Sum of deduced: " + sum_of_deduced.string())

  fun count_unique_digits(patterns: Array[Pattern]): USize =>
    var count: USize = 0
    for pattern in patterns.values() do
      count = count + pattern.count_unique_output()
    end
    count

  fun sum_up_deduced_digits(patterns: Array[Pattern]): USize =>
    var count: USize = 0
    for pattern in patterns.values() do
      count = count + pattern.deduce_output_digits()
    end
    count

  fun parse_input(auth: AmbientAuth): Array[Pattern] =>
    let patterns = Array[Pattern]
    let path = FilePath(auth, "example_input.txt")
    with file = File(path) do
      for line in file.lines() do
        let split = (consume line).split_by(" | ")
        let input = split(0)?.split_by(" ")
        let output = split(1)?.split_by(" ")
        patterns.push(Pattern(consume input, consume output))
      end
    end
    patterns


class Pattern
  let input: Array[String]
  let output: Array[String]

  new create(input': Array[String], output': Array[String]) =>
    input = input'
    output = output'

  fun count_unique_output(): USize =>
    var count: USize = 0
    for digit in output.values() do
      if _is_unique(digit) then
        Debug.out(digit.string() + " unique!")
        count = count + 1
      end
    end

    count

  fun deduce_output_digits(): USize =>
    0

  fun _is_unique(digit: String): Bool =>
    match digit.size()
    | 2 | 4 | 3 | 7 => true
    else
      false
    end

  fun string(): String iso^ =>
    "Pattern(input " + ", ".join(input.values()) + " output: " + ", ".join(output.values()) + ")"
