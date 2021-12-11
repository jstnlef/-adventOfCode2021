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

    var score = check_syntax_score(lines)
    env.out.print("Syntax score: " + score.string())

    score = check_autocomplete_score(lines)
    env.out.print("Autocomplete score: " + score.string())

  fun check_autocomplete_score(lines: Array[String]): USize =>
    let scores = Array[USize]
    for line in lines.values() do
      if not is_corrupted(line) then
        scores.push(autocomplete_score(line))
      end
    end
    let sorted = Sort[Array[USize], USize](scores)
    try sorted((sorted.size()/2))? else 0 end

  fun is_corrupted(line: String): Bool =>
    find_corrupted_char(line) != 0

  fun autocomplete_score(line: String): USize =>
    let s = Array[U32](line.size())
    for c in line.runes() do
      if is_starting_char(c) then
        s.unshift(c)
      else
        try
          let most_recent_begin = s(0)?
          if is_end_char(most_recent_begin, c) then
            s.shift()?
          end
        end
      end
    end

    var score: USize = 0
    for c in s.values() do
      score = (score * 5) + get_autocomplete_score_for_char(c)
    end
    score

  fun get_autocomplete_score_for_char(c: U32): USize =>
    match c
    | 40 => 1
    | 91 => 2
    | 123 => 3
    | 60 => 4
    else
      0
    end

  fun check_syntax_score(lines: Array[String]): USize =>
    var score: USize = 0
    for line in lines.values() do
      let line_score = syntax_score(line)
      score = score + line_score
    end
    score

  fun syntax_score(line: String): USize =>
    calc_syntax_score_for_char(find_corrupted_char(line))

  fun find_corrupted_char(line: String): U32 =>
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
    corrupted

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

  fun calc_syntax_score_for_char(c: U32): USize =>
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
