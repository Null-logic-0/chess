defmodule ChessWeb.Chat.Empty do
  use ChessWeb, :html

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
