defmodule ChessWeb.Chat.Empty do
  @moduledoc """
  Provides a reusable empty state component for the chat interface.

  This component is displayed when there are no chat messages available.
  It encourages user interaction by prompting the user to start the conversation.
  """

  use ChessWeb, :html

  @doc """
  Renders an empty state for the chat view.

  This component is conditionally displayed when there are no messages in the chat.
  It shows a simple icon and a friendly prompt encouraging the user to send the first message.

  ## Attributes

    * `:messages_count` - Integer representing the number of messages in the chat.
      The empty state is shown only when this value is `0`.

  ## Examples

      <.empty messages_count={length(@messages)} />

  """
  attr :messages_count, :integer,
    required: true,
    doc: "Number of chat messages; controls visibility of empty state."

  def empty(assigns) do
    ~H"""
    <div
      :if={@messages_count == 0}
      class="flex flex-col items-center justify-center h-full gap-1 text-base-content/30"
    >
      <.icon name="hero-chat-bubble-oval-left-ellipsis" class="size-8" />
      <p class="text-xs">No messages yet. Say hello!</p>
    </div>
    """
  end
end
