defmodule ChessWeb.Chat.ChatLiveComponent do
  @moduledoc """
  LiveComponent responsible for rendering and managing the in-game chat system.

  This component handles:
    * Streaming chat messages in real-time
    * Sending new messages
    * Maintaining local message state
    * Coordinating form input and message list UI

  It is designed to be embedded inside a game LiveView.
  """

  use ChessWeb, :live_component

  import ChessWeb.Chat.ChatForm
  import ChessWeb.Chat.Messages

  alias Chess.Messages

  @doc """
  Renders the chat UI.

  Combines the message list, empty state, and input form into a single
  reusable chat component.

  ## Attributes

    * `:my_id` - Current user ID used for message alignment.
    * `:messages` - Streamed list of chat messages.
    * `:messages_count` - Total number of messages.
    * `:message_form` - Phoenix form used for message input.
    * `:myself` - LiveComponent reference used for event targeting.

  """
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

  @doc """
  Initializes the component state.

  Sets up an empty form, message counter, and an empty message stream.
  """
  def mount(socket) do
    {:ok,
     socket
     |> assign(:message_form, to_form(%{}))
     |> assign(:messages_count, 0)
     |> assign(:last_flash_id, nil)
     |> stream(:messages, [])}
  end

  @doc """
   Handles insertion of a newly received message into the stream.

  Increments the local message counter and inserts the message into the UI stream.

  Initializes or updates the chat component with game context.

  If the game is already assigned, only user context is updated.
  Otherwise, it loads existing messages for the game and initializes the stream.

  ## Assigns expected
    * `:game` - Current game context
    * `:my_id` - Current user ID
    * `:current_scope` - Authentication scope
  """
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

  @doc """
  Handles sending a new chat message.

  Creates a message in the database and clears the input field on success.
  """
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
