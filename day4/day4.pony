use "collections"
use "debug"
use "itertools"
use "files"

actor Main is ResultReceiver
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

  be receive_result(result: SimulationResult) =>
    _env.out.print(result.string())

  fun parse_input(auth: AmbientAuth): BingoSim =>
    let lines = Array[String](1000)
    var bit_length: USize = 0
    let path = FilePath(auth, "input.txt")
    with file = File(path) do
      for line in file.lines() do
        bit_length = line.size()
        lines.push((consume line))
      end
    end

    let numbers_to_draw: Array[USize] val = [7;4;9;5;11;17;23;2;0;14;21;24;10;16;13;6;15;25;12;22;18;20;8;19;3;26;1]
    var test_boards: Array[Array[USize] val] val = [[
      14;21;17;24;4;10;16;15;9;19;18;8;23;26;20;22;11;13;6;5;2;0;12;3;7
    ]]
    BingoSim(this, numbers_to_draw, test_boards)


actor BingoSim is ResultReceiver
  let _caller: ResultReceiver
  let numbers_to_draw: Array[USize] val
  let boards: Array[Board] val
  let results: Array[SimulationResult]

  new create(
    caller: ResultReceiver,
    numbers_to_draw': Array[USize] val,
    boards': Array[Array[USize] val] val
  ) =>
    _caller = caller
    numbers_to_draw = numbers_to_draw'

    var b: Array[Board] iso = recover Array[Board] end
    for board in boards'.values() do
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

    var min_to_win: USize = 999999
    var min_result = SimulationResult(0, 0)
    for r in results.values() do
      if r.numbers_to_win < min_to_win then
        min_to_win = r.numbers_to_win
        min_result = r
      end
    end

    _caller.receive_result(min_result)


actor Board
  let board_width: USize = 5
  let numbers_to_draw: Array[USize] val
  let _caller: ResultReceiver
  let _inner: Array[BingoPosition]

  var _total_drawn: USize = 0
  var _last_number_drawn: USize = 0

  new create(caller: ResultReceiver, numbers_to_draw': Array[USize] val, board: Array[USize] val) =>
    numbers_to_draw = numbers_to_draw'
    _caller = caller
    _inner = Array[BingoPosition]
    for number in board.values() do
      _inner.push(BingoPosition(number))
    end

  be simulate_until_win() =>
    for number in numbers_to_draw.values() do
      _total_drawn = _total_drawn + 1
      _last_number_drawn = number
      mark_position(number)
      if has_won() then
        break
      end
    end

    // for pos in _inner.values() do
    //   Debug.out(pos.string())
    // end

    _caller.receive_result(calculate_sim_result())

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
    for i in Range(0, board_width * (board_width - 1), 5) do
      if check_win(i, i + 5, 1) then
        return true
      end
    end
    false

  fun check_columns(): Bool =>
    for i in Range(0, board_width) do
      if check_win(i, board_width * (board_width - 1), board_width) then
        return true
      end
    end
    false

  fun check_win(from: USize, to: USize, step: USize): Bool =>
    try
      for i in Range(from, to, step) do
        let pos = _inner(i)?
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
    let score = unmarked_sum * _last_number_drawn
    SimulationResult(score, _total_drawn)


class BingoPosition
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
