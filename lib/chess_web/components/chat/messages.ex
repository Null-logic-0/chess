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
      >
        <div
          :for={{dom_id, message} <- @messages}
          id={dom_id}
          class={[
            "chat",
            if(to_string(message.user_id) == @my_id, do: "chat-end", else: "chat-start")
          ]}
        >
          <div class="chat-image avatar placeholder">
            <div class={[
              "w-6 rounded-full text-xs flex items-center justify-center",
              if(to_string(message.user_id) == @my_id,
                do: "bg-success/10 text-success",
                else: "bg-info/10 text-info"
              )
            ]}>
              <img
                src={message.user.profile_image}
                alt={message.user.username}
                class="object-cover"
              />
            </div>
          </div>

          <div class="chat-bubble chat-bubble-ghost text-base-content text-xs py-1.5 px-3">
            {message.content}
          </div>
        </div>
      </div>
    </div>
    """
  end
end
