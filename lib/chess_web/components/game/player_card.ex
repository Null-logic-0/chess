defmodule ChessWeb.Game.PlayerCard do
  use ChessWeb, :html

  @doc """
  Renders a player card showing avatar, name, color label, turn indicator, and clock.

  ## Attributes

  - `user`         - The user map/struct (must have `:full_name` and `:profile_image`).
  - `initials`     - Fallback initials string when no profile image is present.
  - `is_me`        - Boolean. Drives "(you)" label and avatar ring color.
  - `is_creator`   - Boolean. Shows the "creator" badge when true.
  - `color_label`  - String shown below the name, e.g. "playing white".
  - `is_active`    - Boolean. True when it's this player's turn and game is playing.
  - `time`         - Pre-formatted clock string, e.g. "05:00".
  - `class`        - Optional extra CSS classes for the wrapper.

  ## Examples

      <.player_card
        user={@current_scope.user}
        initials={user_initials(@current_scope.user)}
        is_me={true}
        is_creator={@game.user_id == @my_id}
        color_label={my_color_label(@my_color)}
        is_active={@active_color == @my_color && @game.status == "playing"}
        time={format_time(my_time_ms(@my_color, @white_ms, @black_ms))}
      />

      <.player_card
        user={@opponent}
        initials={opponent_initials(@opponent)}
        is_me={false}
        is_creator={@opponent && @game.user_id == @opponent.id}
        color_label={opponent_color_label(@my_color)}
        is_active={@opponent && @active_color != @my_color && @game.status == "playing"}
        time={format_time(opponent_time_ms(@my_color, @white_ms, @black_ms))}
      />
  """

  attr :user, :map, default: nil
  attr :initials, :string, default: ""
  attr :is_me, :boolean, default: false
  attr :is_creator, :boolean, default: false
  attr :color_label, :string, required: true
  attr :is_active, :boolean, default: false
  attr :time, :string, required: true
  attr :class, :string, default: nil

  def player_card(assigns) do
    ~H"""
    <div class={["flex items-center gap-3 p-3 bg-base-100 border border-base-300 rounded-box", @class]}>
      <%!-- Avatar --%>
      <div class={[
        "w-9 h-9 rounded-full flex items-center justify-center text-sm font-medium shrink-0 overflow-hidden",
        if(@is_me, do: "bg-success/10 text-success", else: "bg-info/10 text-info")
      ]}>
        <%= if @user && @user.profile_image do %>
          <img src={@user.profile_image} class="w-full h-full object-cover" />
        <% else %>
          {@initials}
        <% end %>
      </div>

      <div class="flex-1 min-w-0">
        <p class="text-sm font-medium text-base-content truncate flex items-center gap-1.5">
          {if @user, do: @user.full_name, else: "Waiting for opponent…"}
          <%= if @is_me do %>
            <span class="text-xs text-base-content/40 font-normal">(you)</span>
          <% end %>
          <%= if @is_creator do %>
            <span class="text-[10px] bg-base-300 text-base-content/60 px-1.5 py-0.5 rounded font-normal">
              creator
            </span>
          <% end %>
        </p>
        <p class="text-xs text-base-content/50 font-mono">
          {@color_label}
          <%= if @is_active do %>
            ·
            <span class={if @is_me, do: "text-success", else: "text-warning"}>
              {if @is_me, do: "your turn", else: "their turn"}
            </span>
          <% end %>
        </p>
      </div>

      <div class={[
        "font-mono text-lg font-medium px-3 py-1.5 rounded-field border text-center min-w-[70px] transition-colors",
        if(@is_active,
          do: "bg-primary text-primary-content border-primary",
          else: "bg-base-200 text-base-content border-base-300"
        )
      ]}>
        {@time}
      </div>
    </div>
    """
  end
end
