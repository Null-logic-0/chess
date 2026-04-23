defmodule Chess.MessagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chess.Messages` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(scope, slug, attrs \\ %{}) do
    {:ok, message} =
      Chess.Messages.create_message(scope, slug, Enum.into(attrs, %{"content" => "hello"}))

    message
  end
end
