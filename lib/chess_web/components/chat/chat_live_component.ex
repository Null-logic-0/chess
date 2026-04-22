defmodule ChessWeb.Chat.ChatLiveComponent do
  use ChessWeb, :live_component
  import ChessWeb.Chat.ChatForm
  import ChessWeb.Chat.Messages
  alias Chess.Messages

  def render(assigns) do
    ~H"""
    <div class="border border-base-300 rounded-box overflow-hidden bg-base-100">
      <div class="flex items-center justify-between px-4 py-2 border-b border-base-300 text-xs font-medium text-base-content/40 uppercase tracking-wider bg-base-200">
        <span>Chat</span>
      </div>
      <.messages my_id={@my_id} messages={@streams.messages} messages_count={@messages_count} />
      <.chat_form form={@message_form} target={@myself} />
    </div>
    """
  end

  def mount(socket) do
    {:ok,
     socket
     |> assign(:message_form, to_form(%{}))
     |> assign(:messages_count, 0)
     |> assign(:last_flash_id, nil)
     |> stream(:messages, [])}
  end

  def update(%{new_message: message}, socket) do
    {:ok,
     socket
     |> stream_insert(:messages, message)
     |> update(:messages_count, &(&1 + 1))}
  end

  def update(%{game: game, my_id: my_id, current_scope: current_scope}, socket) do
    if socket.assigns[:game] do
      {:ok,
       socket
       |> assign(:my_id, my_id)
       |> assign(:current_scope, current_scope)}
    else
      messages = Messages.list_messages(game.slug)

      {:ok,
       socket
       |> assign(:game, game)
       |> assign(:my_id, my_id)
       |> assign(:current_scope, current_scope)
       |> assign(:messages_count, length(messages))
       |> stream(:messages, messages)}
    end
  end

  def handle_event("send_message", %{"body" => body}, socket) do
    case Messages.create_message(socket.assigns.current_scope, socket.assigns.game.slug, %{
           content: body
         }) do
      {:ok, _message} ->
        {:noreply, push_event(socket, "clear_input", %{})}

      {:error, _} ->
        {:noreply, socket}
    end
  end
end
