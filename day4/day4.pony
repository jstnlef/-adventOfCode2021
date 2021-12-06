use "collections"
use "debug"
use "itertools"
use "files"

actor Main is SimResultReceiver
  let _env: Env
  new create(env: Env) =>
    _env = env

    let auth = try
      env.root as AmbientAuth
    else
      env.err.print("env.root must be AmbientAuth")
      return
    end

    let sim = parse_input(auth)
    sim.simulate_until_win()

  be receive_sim_results(results: SimResults) =>
    _env.out.print(results.string())

  fun parse_input(auth: AmbientAuth): BingoSim =>
    let numbers_to_draw: Array[USize] iso = recover iso Array[USize] end
    let boards: Array[Array[USize] val] iso = recover iso Array[Array[USize] val](1000) end
    var buffer: String ref = String.create()
    var line_number: USize = 0

    let path = FilePath(auth, "input.txt")
    with file = File(path) do
      for line in file.lines() do
        if line_number == 0 then
          let split = line.split(",")
          for s in (consume split).values() do
            numbers_to_draw.push(s.usize()?)
          end
        elseif line_number > 1 then
          if line == "" then
            let split = buffer.split(" ")
            let board = recover iso Array[USize] end
            for s in (consume split).values() do
              try
                board.push(s.usize()?)
              end
            end
            boards.push(consume board)
            buffer = String.create()
          else
            buffer = buffer + consume line + " "
          end
        end
        line_number = line_number + 1
      end
    end
    BingoSim(this, consume numbers_to_draw, consume boards)


actor BingoSim is ResultReceiver
  let caller: SimResultReceiver
  let numbers_to_draw: Array[USize] val
  let boards: Array[Board] val
  let results: Array[SimulationResult]

  new create(
    caller': SimResultReceiver,
    numbers_to_draw': Array[USize] val,
    boards': Array[Array[USize] val] val
  ) =>
    caller = caller'
    numbers_to_draw = numbers_to_draw'

    Debug.out("Numbers to draw: " + ",".join(numbers_to_draw.values()))

    var b: Array[Board] iso = recover Array[Board] end
    for board in boards'.values() do
      Debug.out("Boards: " + " ".join(board.values()))
      b.push(Board(this, numbers_to_draw, board))
    end

    boards = consume b
    results = Array[SimulationResult]

  be simulate_until_win() =>
    for board in boards.values() do
      board.simulate_until_win()
    end

  be receive_result(result: SimulationResult) =>
    results.push(result)
    if results.size() < boards.size() then
      return
    end

    var min_to_win: USize = USize.max_value()
    var min_result = SimulationResult(0, 0)
    for r in results.values() do
      if r.numbers_to_win < min_to_win then
        min_to_win = r.numbers_to_win
        min_result = r
      end
    end

    var max_to_win: USize = USize.min_value()
    var max_result = SimulationResult(0, 0)
    for r in results.values() do
      if r.numbers_to_win > max_to_win then
        max_to_win = r.numbers_to_win
        max_result = r
      end
    end

    caller.receive_sim_results(SimResults(min_result, max_result))


actor Board
  let board_width: USize = 5
  let numbers_to_draw: Array[USize] val
  let caller: ResultReceiver
  let _inner: Array[BingoPosition]

  var total_drawn: USize = 0
  var last_number_drawn: USize = 0

  new create(caller': ResultReceiver, numbers_to_draw': Array[USize] val, board: Array[USize] val) =>
    numbers_to_draw = numbers_to_draw'
    caller = caller'
    _inner = Array[BingoPosition]
    for number in board.values() do
      _inner.push(BingoPosition(number))
    end

  be simulate_until_win() =>
    for number in numbers_to_draw.values() do
      total_drawn = total_drawn + 1
      last_number_drawn = number
      mark_position(number)
      if has_won() then
        break
      end
    end
    caller.receive_result(calculate_sim_result())

  fun ref mark_position(number: USize) =>
    for pos in _inner.values() do
      if pos.number == number then
        pos.marked = true
        break
      end
    end

  fun has_won(): Bool =>
    check_rows() or check_columns()

  fun check_rows(): Bool =>
    Debug.out("Checking Rows!")
    for i in Range(0, (board_width * (board_width - 1)) + 1, 5) do
      if check_win(i, i + 5, 1) then
        return true
      end
    end
    false

  fun check_columns(): Bool =>
    Debug.out("Checking Columns!")
    for i in Range(0, board_width) do
      if check_win(i, board_width * board_width, board_width) then
        return true
      end
    end
    false

  fun check_win(from: USize, to: USize, step: USize): Bool =>
    try
      Debug.out("From: " + from.string() + " To: " + to.string() + " Step: " + step.string())
      for i in Range(from, to, step) do
        let pos = _inner(i)?
        Debug.out(i.string() + " " + pos.string())
        if pos.marked == false then
          return false
        end
      end
      true
    else
      Debug.out("Check win failed!")
      false
    end


  fun calculate_sim_result(): SimulationResult =>
    var unmarked_sum: USize = 0
    for pos in _inner.values() do
      if not pos.marked then
        unmarked_sum = unmarked_sum + pos.number
      end
    end
    let score = unmarked_sum * last_number_drawn
    SimulationResult(score, total_drawn)


class BingoPosition is Stringable
  let number: USize
  var marked: Bool

  new create(number': USize) =>
    number = number'
    marked = false

  fun string(): String iso^ =>
    "Pos(" + number.string() + ", " + marked.string() + ")"


class val SimulationResult is Stringable
  let score: USize
  let numbers_to_win: USize

  new val create(score': USize, numbers_to_win': USize) =>
    score = score'
    numbers_to_win = numbers_to_win'

  fun string(): String iso^ =>
    "Board score: " + score.string() + "\n" + "Numbers to win: " + numbers_to_win.string()


trait tag ResultReceiver
  be receive_result(result: SimulationResult)


trait tag SimResultReceiver
  be receive_sim_results(results: SimResults)


class val SimResults is Stringable
  let best_board: SimulationResult
  let worst_board: SimulationResult

  new val create(best: SimulationResult, worst: SimulationResult) =>
    best_board = best
    worst_board = worst

  fun string(): String iso^ =>
    "Best board:\n" + best_board.string() + "\n\n" + "Worst board:\n" + worst_board.string()
