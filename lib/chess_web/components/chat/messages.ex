defmodule ChessWeb.Chat.Messages do
  use ChessWeb, :html
  import ChessWeb.Chat.Empty

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
                  alt={message.user.username}
                  class="object-cover"
                />
              <% else %>
                {message.user.username |> String.upcase() |> String.slice(0, 2)}
              <% end %>
            </div>
          </div>
          <div class="chat-bubble chat-bubble-ghost text-base-content text-sm py-1.5 px-3">
            <span class="text-xs block text-gray-400">{message.user.username}</span>
            <hr class="my-1" />
            {message.content}
          </div>
        </div>
      </div>
    </div>
    """
  end
end
