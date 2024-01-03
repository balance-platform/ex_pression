# Used by "mix format"
[
  inputs:
    Enum.flat_map(
      ["{mix,.formatter,.recode,.credo}.exs", "{config,lib,test}/**/*.{ex,exs}"],
      &Path.wildcard(&1, match_dot: true)
    ) -- ["lib/ex_pression/parsing/grammar.ex"]
]
