import Config

config :nostrum,
  token: System.get_env("DISCORD_TOKEN"),
  num_shards: :auto,
  gateway_intents: [
    :guilds,
    :guild_messages,
    :message_content,
  ]

config :openai,
  api_key: System.get_env("OPEN_AI_API_KEY")
