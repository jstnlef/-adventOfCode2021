class InputParser
  let _env: AmbientAuth ref
  new create(env: AmbientAuth ref) =>
    _env = env
