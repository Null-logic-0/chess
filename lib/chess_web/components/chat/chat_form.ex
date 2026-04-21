defmodule ChessWeb.Chat.ChatForm do
  use ChessWeb, :html

  def chat_form(assigns) do
    ~H"""
    <.form
      for={@form}
      phx-submit="send_message"
      phx-target={@target}
      class="flex items-center gap-2 px-3 py-2 border-t border-base-300 bg-base-200"
    >
      <textarea
        name="body"
        rows="2"
        id="message-input"
        phx-hook="ChatInput"
        data-target={@target}
        placeholder="Type a message..."
        class="input input-sm flex-1 bg-base-100 border-base-300 text-base-content placeholder:text-base-content/30 focus:outline-none focus:border-primary text-xs"
      />
      <button
        type="submit"
        class="btn btn-sm btn-primary px-3"
      >
        <.icon name="hero-paper-airplane" class="size-4 text-white" />
      </button>
    </.form>
    """
  end
end
