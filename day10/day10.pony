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

    let lines = parse_input(auth)

    let score = process_nav_subsystem(lines)
    env.out.print("Score: " + score.string())

  fun process_nav_subsystem(lines: Array[String]): USize =>
    var score: USize = 0
    for line in lines.values() do
      let line_score = process_line(line)
      Debug.out("Line Score: " + line_score.string())
      score = score + line_score
    end
    score

  fun process_line(line: String): USize =>
    let s = Array[U32](line.size())
    var corrupted: U32 = 0
    for c in line.runes() do
      if is_starting_char(c) then
        s.unshift(c)
      else
        try
          let most_recent_begin = s(0)?
          if is_end_char(most_recent_begin, c) then
            s.shift()?
          else
            corrupted = c
            break
          end
        end
      end
    end
    calc_score(corrupted)

  fun is_starting_char(c: U32): Bool =>
    (c == 40) or (c == 91) or (c == 123) or (c == 60)

  fun is_end_char(first: U32, last: U32): Bool =>
    match first
    | 40 => last == 41
    | 91 => last == 93
    | 123 => last == 125
    | 60 => last == 62
    else
      false
    end

  fun calc_score(c: U32): USize =>
    match c
    | 41 => 3
    | 93 => 57
    | 125 => 1197
    | 62 => 25137
    else
      0
    end

  fun parse_input(auth: AmbientAuth): Array[String] =>
    let lines = Array[String]
    let path = FilePath(auth, "input.txt")
    with file = File(path) do
      for line in file.lines() do
        lines.push(consume line)
      end
    end
    lines
