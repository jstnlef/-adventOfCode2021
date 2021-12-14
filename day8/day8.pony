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

  let patterns = parse_input(auth)
  let unique_count = count_unique_digits(patterns)
  env.out.print("Unique digits: " + unique_count.string())

  fun count_unique_digits(patterns: Array[Pattern]): USize =>
    var count: USize = 0
    for pattern in patterns.values() do
      count = count + pattern.count_unique_output()
    end
    count

  fun parse_input(auth: AmbientAuth): Array[Pattern] =>
    let patterns = Array[Pattern]
    let path = FilePath(auth, "input.txt")
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

  fun _is_unique(digit: String): Bool =>
    match digit.size()
    | 2 | 4 | 3 | 7 => true
    else
      false
    end

  fun string(): String iso^ =>
    "Pattern(input " + ", ".join(input.values()) + " output: " + ", ".join(output.values()) + ")"
