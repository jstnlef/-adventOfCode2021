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

    let initial = parse_input(auth)
    Debug.out("Initial State: " + ",".join(initial.values()))

    var end_state = run_lantern_fish_sim(initial, 80)
    env.out.print("Number of fish after 80: " + end_state.size().string())

    end_state = run_lantern_fish_sim(initial, 256)
    env.out.print("Number of fish after 256: " + end_state.size().string())

  fun run_lantern_fish_sim(initial: Array[USize], days: USize): Array[USize] =>
    let state = initial.clone()
    for day in Range(0, days) do
      for i in Range(0, state.size()) do
        try
          let fish = state(i)?
          if fish == 0 then
            state.push(8)
            try
              state.update(i, 6)?
            else
              Debug.out("Unable to update fish!")
            end
          else
            try
              state.update(i, fish - 1)?
            else
              Debug.out("Unable to update fish!")
            end
          end
        end
      end
      Debug.out("After " + day.string() + " days: " + ",".join(state.values()))
    end
    state

  fun parse_input(auth: AmbientAuth): Array[USize] =>
    let initial = Array[USize]
    let path = FilePath(auth, "input.txt")
    with file = File(path) do
      let read = file.read_string(file.size())
      let split = read.split(",")
      for n in (consume split).values() do
        initial.push(n.usize()?)
      end
    end
    initial
