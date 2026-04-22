defmodule ChessWeb.Chat.ChatForm do
  @moduledoc """
  Provides a reusable chat message input form component.

  This component renders a textarea input with a submit button and is designed
  for real-time chat interfaces using Phoenix LiveView. It supports a custom
  event target and integrates with client-side hooks for enhanced UX.
  """
  use ChessWeb, :html

  @doc """
  Renders the chat message input form.

  This form allows users to submit chat messages via a LiveView event.
  It includes a multi-line textarea input and a submit button with an icon.
  It is designed to work with a `phx-hook` for improved input behavior.

  ## Attributes

    * `:form` - The Phoenix form struct used by `<.form />`.

    * `:target` - The LiveView or component target for event handling.

  ## Events

    * `"send_message"` - Triggered on form submission.

  ## Examples

      <.chat_form form={@form} target={@myself} />

  """
  attr :form, :map,
    required: true,
    doc: "Phoenix form struct used for rendering the form."

  attr :target, :any,
    required: true,
    doc: "LiveView or component target for phx-submit events."

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
