defmodule Lucidboard.Seeds do
  @moduledoc "Some database seed data"
  import Ecto.Query

  alias Lucidboard.{Board, BoardRole, Card, Column, Like, Pile, Repo, User}

  def get_user do
    Repo.one(from(u in User, where: u.name == "bob")) ||
      Repo.insert!(User.new(name: "bob", full_name: "Mister Bob"))
  end

  def insert!(user \\ nil) do
    user = user || get_user()

    Repo.insert!(board(user))
    Repo.insert!(board2(user))
  end

  def board(user) do
    %User{id: uid} = user = user || get_user()

    Board.new(
      title: "My Test Board",
      user_id: user.id,
      board_roles: [BoardRole.new(user_id: user.id, role: :owner)],
      columns: [
        Column.new(title: "Col1", pos: 0),
        Column.new(
          title: "Col2",
          pos: 1,
          piles: [
            Pile.new(
              pos: 0,
              cards: [
                new_card(uid, [pos: 0, body: "hi"], [user.id])
              ]
            )
          ]
        ),
        Column.new(
          title: "Col3",
          pos: 2,
          piles: [
            Pile.new(
              pos: 0,
              cards: [
                new_card(uid, pos: 0, body: "whoa"),
                new_card(uid, pos: 1, body: "srs?"),
                new_card(uid, pos: 2, body: "neat")
              ]
            ),
            Pile.new(
              pos: 1,
              cards: [new_card(uid, pos: 0, body: "definitely")]
            ),
            Pile.new(pos: 2, cards: [new_card(uid, pos: 0, body: "cheese")]),
            Pile.new(
              pos: 3,
              cards: [new_card(uid, pos: 0, body: "flapjacks")]
            )
          ]
        )
      ]
    )
  end

  def board2(user \\ nil) do
    %User{id: uid} = user = user || get_user()

    Board.new(
      title: "Another Example Board About Nothing",
      user: user,
      columns: [
        Column.new(
          title: "What Went Well",
          pos: 0,
          piles: [
            Pile.new(
              pos: 0,
              cards: [new_card(uid, pos: 0, body: "Diversionary tactics")]
            ),
            Pile.new(
              pos: 1,
              cards: [new_card(uid, pos: 0, body: "Bitcoin")]
            ),
            Pile.new(
              pos: 2,
              cards: [
                new_card(
                  uid,
                  pos: 0,
                  body: """
                  This board is just an example, so we need to cover a range of \
                  different cases like maybe having a card with lots and lots of \
                  text.\
                  """
                )
              ]
            )
          ]
        ),
        Column.new(
          title: "What Didn't Go Well",
          pos: 1,
          piles: [
            Pile.new(
              pos: 0,
              cards: [new_card(uid, pos: 0, body: "I donno")]
            ),
            Pile.new(
              pos: 1,
              cards: [
                new_card(uid, pos: 0, body: "Tunafish?")
              ]
            )
          ]
        ),
        Column.new(
          title: "What Was Amazing",
          pos: 2,
          piles: [
            Pile.new(
              pos: 0,
              cards: [
                new_card(uid, pos: 0, body: "Seinfeld"),
                new_card(uid, pos: 1, body: "Tuesdays"),
                new_card(uid, pos: 2, body: "Drum and bass")
              ]
            ),
            Pile.new(
              pos: 1,
              cards: [
                new_card(uid, pos: 0, body: "Supercalifragilisticexpialidocious")
              ]
            ),
            Pile.new(
              pos: 2,
              cards: [new_card(uid, pos: 0, body: "orange juice")]
            ),
            Pile.new(pos: 3, cards: [new_card(uid, pos: 0, body: "bandanas")]),
            Pile.new(
              pos: 4,
              cards: [new_card(uid, pos: 0, body: "lucidboard?")]
            )
          ]
        )
      ]
    )
  end

  defp new_card(user_id, fields, like_uids \\ []) do
    base_card = Card.new([user_id: user_id] ++ fields)

    Enum.reduce(like_uids, base_card, fn uid, card ->
      %{card | likes: [Like.new(user_id: uid, card_id: card.id) | card.likes]}
    end)
  end
end
