import Config

if Config.config_env() == :dev do
  DotenvParser.load_file(".ENV")
end

config :aoc2025,
  cookie: System.get_env("COOKIE", "failed"),
  blabla: "bla"
