defmodule Chess.MessagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chess.Messages` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(scope, slug, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        content: "some content"
      })

    {:ok, message} = Chess.Messages.create_message(scope, slug, attrs)
    message
  end
end
