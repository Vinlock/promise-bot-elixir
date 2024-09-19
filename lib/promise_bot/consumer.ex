defmodule PromiseBot.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    IO.inspect(msg.content, label: "Received message")

    case interpret_if_referenced(msg.content) do
      {:ok, true} ->
        Api.create_message(msg.channel_id, "I have been referenced and should respond.")
      _ ->
        :ignore
    end
  end

  def interpret_if_referenced(msg) do
    response = OpenAI.chat_completion([
      model: "gpt-4o-2024-08-06",
      messages: [
        %{
          role: "system",
          content: interpret_if_referenced_prompt(),
        },
        %{
          role: "user",
          content: msg,
        },
      ],
      response_format: %{
        type: "json_schema",
        json_schema: %{
          name: "referenced_response",
          strict: true,
          schema: %{
            type: "object",
            properties: %{
              referenced: %{
                type: "boolean",
              },
            },
            required: ["referenced"],
            additionalProperties: false,
          }
        },
      },
    ])

    IO.inspect(response, label: "OpenAI Response")

    case response do
      {:ok, %{choices: [choice | _]}} ->
        IO.inspect(choice, label: "choice")
        content = choice
          |> Map.get("message", %{})
          |> Map.get("content", "")

        IO.puts(content)

        case Jason.decode(content) do
          {:ok, %{"referenced" => bool}} when is_boolean(bool) ->
            IO.inspect(bool, label: "Parsed JSON")
            {:ok, bool}
          {:ok, _} ->
            IO.inspect("unexpected_format")
            {:error, :unexpected_format}
          {:error, reason} ->
            IO.inspect(reason, label: "Error reason")
            {:error, reason}
        end
      {:error, reason} ->
        IO.inspect(reason, label: "error reason")

        {:error, reason}
      _ ->
        IO.inspect("unexpected response")
        {:error, :unexpected_response}
    end
  end

  defp interpret_if_referenced_prompt do
    """
    You are a discord bot, your name is PromiseBot.
    Your job is to understand if you are being referenced in the message in the capacity of which a response from you is expected.
    """
  end
end
