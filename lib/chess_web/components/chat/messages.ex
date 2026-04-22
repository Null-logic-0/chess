defmodule ChessWeb.Chat.Messages do
  @moduledoc """
  Renders the chat message list for the chat interface.

  This component displays streamed chat messages in real-time using
  Phoenix LiveView streams. It also integrates an empty state component
  when no messages are present and handles user-based message alignment.
  """
  use ChessWeb, :html
  import ChessWeb.Chat.Empty

  @doc """
  Renders the chat message list.

  Displays messages in a scrollable container using LiveView streams.
  Messages are visually differentiated based on whether they belong to
  the current user or other participants.

  Also renders an empty state when there are no messages.

  ## Attributes

    * `:messages` - A LiveView stream of chat messages. Each message is expected
      to include:
        * `:id` (used for DOM tracking)
        * `:user_id`
        * `:content`
        * `:user` (with `:full_name` and optional `:profile_image`)

    * `:messages_count` - Integer representing total number of messages.

    * `:my_id` - The current user's ID, used to align messages (start/end).

  ## Examples

      <.messages
        messages={@streams.messages}
        messages_count={length(@messages)}
        my_id={@current_user.id}
      />

  """

  attr :messages, :list,
    required: true,
    doc: "Streamed list of chat messages."

  attr :messages_count, :integer,
    required: true,
    doc: "Total number of messages in the chat."

  attr :my_id, :any,
    required: true,
    doc: "Current user ID used for message alignment."

  def messages(assigns) do
    ~H"""
    <div
      id="chat-scroll"
      phx-hook="ChatScroll"
      class="flex flex-col gap-1 p-3 h-36 overflow-y-auto"
    >
      <.empty messages_count={@messages_count} />
      <div
        id="chat-messages"
        phx-update="stream"
        class="flex flex-col gap-1"
      >
        <div
          :for={{dom_id, message} <- @messages}
          id={dom_id}
          class={[
            "chat",
            if(to_string(message.user_id) == to_string(@my_id), do: "chat-end", else: "chat-start")
          ]}
        >
          <div class="chat-image avatar placeholder">
            <div class={[
              "w-6 rounded-full text-xs flex items-center justify-center",
              if(to_string(message.user_id) == to_string(@my_id),
                do: "bg-success/10 text-success",
                else: "bg-info/10 text-info"
              )
            ]}>
              <%= if message.user.profile_image do %>
                <img
                  src={message.user.profile_image}
                  alt={message.user.full_name}
                  class="object-cover"
                />
              <% else %>
                {message.user.full_name |> String.upcase() |> String.slice(0, 2)}
              <% end %>
            </div>
          </div>
          <div class="chat-bubble chat-bubble-ghost text-base-content text-sm py-1.5 px-3">
            <span class="text-xs block text-gray-400">{message.user.full_name}</span>
            <hr class="my-1" />
            {message.content}
          </div>
        </div>
      </div>
    </div>
    """
  end
end
