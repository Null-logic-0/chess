alias Chess.Repo
alias Chess.Accounts.User
import Ecto.Changeset

players = [
  %{full_name: "Magnus Carlsen", email: "magnus@chess.com"},
  %{full_name: "Hikaru Nakamura", email: "hikaru@chess.com"},
  %{full_name: "Fabiano Caruana", email: "fabiano@chess.com"},
  %{full_name: "Ding Liren", email: "ding@chess.com"},
  %{full_name: "Ian Nepomniachtchi", email: "ian@chess.com"},
  %{full_name: "Anish Giri", email: "anish@chess.com"},
  %{full_name: "Wesley So", email: "wesley@chess.com"},
  %{full_name: "Levon Aronian", email: "levon@chess.com"},
  %{full_name: "Viswanathan Anand", email: "vishy@chess.com"},
  %{full_name: "Garry Kasparov", email: "garry@chess.com"},
  %{full_name: "Vladimir Kramnik", email: "kramnik@chess.com"},
  %{full_name: "Anatoly Karpov", email: "karpov@chess.com"},
  %{full_name: "Bobby Fischer", email: "bobby@chess.com"},
  %{full_name: "Mikhail Tal", email: "tal@chess.com"},
  %{full_name: "Jose Raul Capablanca", email: "capablanca@chess.com"},
  %{full_name: "Alireza Firouzja", email: "alireza@chess.com"},
  %{full_name: "Richard Rapport", email: "rapport@chess.com"},
  %{full_name: "Maxime Vachier-Lagrave", email: "mvl@chess.com"},
  %{full_name: "Sergey Karjakin", email: "karjakin@chess.com"},
  %{full_name: "Peter Svidler", email: "svidler@chess.com"},
  %{full_name: "Teimour Radjabov", email: "radjabov@chess.com"},
  %{full_name: "Boris Gelfand", email: "gelfand@chess.com"},
  %{full_name: "Pentala Harikrishna", email: "hari@chess.com"},
  %{full_name: "Shakhriyar Mamedyarov", email: "shakh@chess.com"},
  %{full_name: "Alexander Grischuk", email: "grischuk@chess.com"},
  %{full_name: "Veselin Topalov", email: "topalov@chess.com"},
  %{full_name: "Ruslan Ponomariov", email: "ponomariov@chess.com"},
  %{full_name: "Vassily Ivanchuk", email: "ivanchuk@chess.com"},
  %{full_name: "Judit Polgar", email: "judit@chess.com"},
  %{full_name: "Gata Kamsky", email: "kamsky@chess.com"}
]

Enum.each(players, fn player ->
  wins = Enum.random(10..200)
  losses = Enum.random(5..100)
  draws = Enum.random(5..80)

  encoded_name = URI.encode(player.full_name)

  profile_image =
    "https://ui-avatars.com/api/?name=#{encoded_name}&size=200&background=random&color=fff&bold=true&format=png"

  %User{}
  |> change(%{
    full_name: player.full_name,
    email: player.email,
    profile_image: profile_image,
    wins: wins,
    losses: losses,
    draws: draws,
    confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second)
  })
  |> unique_constraint(:email)
  |> Repo.insert!(on_conflict: :nothing)
end)

IO.puts("✅ Seeded #{length(players)} chess players")
