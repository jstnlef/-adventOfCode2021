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

    let commands = parse_input(auth)

    let part1_sub = part1_simulation(commands)
    env.out.print("Part1: " + part1_sub.solution().string())

    let part2_sub = part2_simulation(commands)
    env.out.print("Part2: " + part2_sub.solution().string())


  fun parse_input(auth: AmbientAuth): Array[Command] =>
    let commands = Array[Command](1000)
    let path = FilePath(auth, "input.txt")
    with file = File(path) do
      for line in file.lines() do
        commands.push(Command(consume line))
      end
    end
    commands

  fun part1_simulation(commands: Array[Command]): Sub =>
    let sub = Sub
    sub.perform_part1(commands)
    sub

  fun part2_simulation(commands: Array[Command]): Sub =>
    let sub = Sub
    sub.perform_part2(commands)
    sub


class Sub
  var depth: U32
  var position: U32
  var aim: U32

  new create() =>
    depth = 0
    position = 0
    aim = 0

  fun ref perform_part1(commands: Array[Command]) =>
    for command in commands.values() do
      match command.direction
        | Forward => position = position + command.units
        | Up => depth = depth - command.units
        | Down => depth = depth + command.units
      end
    end

  fun ref perform_part2(commands: Array[Command]) =>
    for command in commands.values() do
      match command.direction
        | Forward =>
          position = position + command.units
          depth = depth + (aim * command.units)
        | Up => aim = aim - command.units
        | Down => aim = aim + command.units
      end
    end

  fun solution(): U32 =>
    depth * position


class Command
  let direction: Direction
  let units: U32

  new create(line: String iso) =>
    let split = (consume line).split(" ")
    let dir_s = try split(0)? else "forward" end
    let units_s = try split(1)? else "0" end
    direction = match dir_s
      | "down" => Down
      | "up" => Up
      else Forward
    end

    units = try units_s.u32()? else 0 end


primitive Forward
  fun string(): String => "Forward"
primitive Down
  fun string(): String => "Down"
primitive Up
  fun string(): String => "Up"

type Direction is (Forward | Down | Up)

