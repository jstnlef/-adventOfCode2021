use "collections"
use "debug"
use "itertools"
use "files"

actor Main
  let env: Env
  new create(env': Env) =>
    env = env'

    let initial = parse_input(env.root)

    var end_state = run_lantern_fish_sim(initial, 80)
    env.out.print("Number of fish after 80: " +
      Iter[USize](end_state.values()).fold[USize](0, {(sum, x) => sum + x }).string())

    end_state = run_lantern_fish_sim(initial, 256)
    env.out.print("Number of fish after 256: " +
      Iter[USize](end_state.values()).fold[USize](0, {(sum, x) => sum + x }).string())

  fun run_lantern_fish_sim(initial: Array[USize], days: USize): Array[USize] =>
    var counts_by_day: Array[USize] = [0;0;0;0;0;0;0;0;0]
    try
      for fish in initial.values() do
        counts_by_day.update(fish, counts_by_day(fish)? + 1)?
      end

      for day in Range(0, days) do
        var new_counts: Array[USize] = [0;0;0;0;0;0;0;0;0]
        Debug.out("Counts: " + ",".join(counts_by_day.values()))
        new_counts.update(7, counts_by_day(8)?)?
        new_counts.update(6, counts_by_day(7)? + counts_by_day(0)?)?
        new_counts.update(5, counts_by_day(6)?)?
        new_counts.update(4, counts_by_day(5)?)?
        new_counts.update(3, counts_by_day(4)?)?
        new_counts.update(2, counts_by_day(3)?)?
        new_counts.update(1, counts_by_day(2)?)?
        new_counts.update(0, counts_by_day(1)?)?
        new_counts.update(8, counts_by_day(0)?)?
        counts_by_day = new_counts
      end
    else
      Debug.out("Error processing!!")
    end
    counts_by_day

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
