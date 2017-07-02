defmodule FirstSlackBot.Slack.Supervisor do
  use Supervisor

  alias FirstSlackBot.Slack.Bot

  @doc """
  Start our Slack Supervisor
  """
  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Supervises the Slack.Bot module from the Slack RTM API. This is designed in such a way
  to allow for a single bot to be supervised. The bot receives its Oauth Token from the
  environment variables.
  """
  def init([]) do
    case System.get_env("SLACK_TOKEN") do
      nil -> IO.inspect "You must set SLACK_TOKEN environment variable to start this bot"
      oauth_token when is_bitstring(oauth_token) ->
        name = String.to_atom("bot_" <> oauth_token)

        children = [
          worker(Slack.Bot, [Bot, [], oauth_token, %{name: name}], restart: :transient)
        ]

        supervise(children, strategy: :one_for_one)
    end
  end
end
