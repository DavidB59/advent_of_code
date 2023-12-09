defmodule PokerBbJoker do
  # calculate the number of cards having a given suit in a hand

  # give the index corresponding to the rank of a card
  # A -> 14, K ->  13 , Q -> 12... , 3 -> 2 , 2 -> 1
  def cardPower(card) do
    order = ["J", "2", "3", "4", "5", "6", "7", "8", "9", "T", "Q", "K", "A"]
    Enum.find_index(order, fn x -> String.at(card, 0) == x end)
  end

  # give the type of cards corresponding to its index from the cardPower function
  def whichCard(index) do
    name = {
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "T",
      "J",
      "Q",
      "K",
      "A"
    }

    elem(name, index)
  end

  # return the hand sorted from the strongest card to the weakest card
  def sorting(hand) do
    Enum.sort(hand, &(cardPower(&1) >= cardPower(&2)))
  end

  # Transform the hand into a list of number ranked from strongest to weakest
  def cardsByPower(hand) do
    sorting(hand) |> Enum.map(fn x -> cardPower(x) end)
  end

  # Return true if the hand is straight
  def straight(hand) do
    [a, b, c, d, e] = cardsByPower(hand)
    a - b === b - c and c - d === d - e and a - b === 1 and c - d === 1
  end

  # take out cards that aren't present more than once ouf out the hand - must be called on cardsByPower(hand)
  def removing(hand) do
    one = Enum.dedup(hand)
    hand -- one
  end

  # Return rank of the hand if neither straight nor flush
  def handPowerNoColour(hand) do
    {jokers, rest} = Enum.split_with(hand, fn a -> a == "J" end)
    hand = cardsByPower(rest)

    before_joker =
      case removing(hand) |> length do
        0 ->
          # high card
          1

        1 ->
          # one pair
          2

        2 ->
          case removing(hand) |> removing |> length do
            1 ->
              # three of a kind
              4

            0 ->
              # two pairs
              3

            _ ->
              nil
          end

        3 ->
          # case length(removing(removing(hand))) do
          case removing(hand) |> removing |> length do
            1 ->
              # full house
              7

            2 ->
              # four of a kind
              8

            _ ->
              IO.puts("error power no colour 2")
          end

        _ ->
          # five of a kind
          9
      end

    joker_count = Enum.count(jokers)
    convert_to_higher_power(before_joker, joker_count)
  end

  def convert_to_higher_power(current_power, joker_count)

  def convert_to_higher_power(power, 0), do: power
  # five jokers
  def convert_to_higher_power(_, 5), do: 9

  def convert_to_higher_power(1, 1), do: 2
  def convert_to_higher_power(1, 2), do: 4
  def convert_to_higher_power(1, 3), do: 8
  def convert_to_higher_power(1, 4), do: 9

  def convert_to_higher_power(2, 1), do: 4
  def convert_to_higher_power(2, 2), do: 8
  def convert_to_higher_power(2, 3), do: 9

  # double pair with 1 joker = full house
  def convert_to_higher_power(3, 1), do: 7

  # three of kind with 1 joker -> 4 of a kind
  def convert_to_higher_power(4, 1), do: 8

  # three of kind with 2 jokers -> 5 of a kind
  def convert_to_higher_power(4, 2), do: 9

  # 4 of kind with 1 joker -> 5 of a kind
  def convert_to_higher_power(8, 1), do: 9

  # Return rank of the hand as an integer
  # 1 for high card,  2 for pair, 3 for two pairs, 4 for three of a kind
  # 5 for  straight, 6 for flush, 7 for full house, 8 for four of a kind
  # 9 for straight flush
  def handPower(hand) do
    handPowerNoColour(hand)
  end

  # give the type of hand corresponding to its index from the handPower
  def whichHand(index) do
    name = {
      "index0",
      "high card",
      "pair",
      "two pairs",
      "three of a kind",
      "straight",
      "flush",
      "full house",
      "four of a kind",
      "straight flush"
    }

    elem(name, index)
  end

  # compare the cards of both hand one by one - must be called on ordered hands ( cardsByPower)
  # return 1 if hand1 wins, 2 if hand2 wins, 3 if it's a tie
  def tieBreaker(hand1, hand2, index) do
    cond do
      Enum.at(hand1, index) > Enum.at(hand2, index) ->
        {1, "high card:"}

      Enum.at(hand1, index) < Enum.at(hand2, index) ->
        {2, "high card:"}

      index > length(hand1) ->
        {3, "tiebrekaer"}

      true ->
        tieBreaker(hand1, hand2, index + 1)
    end
  end

  # return 1 if hand1 wins, 2 if hand2 wins, 3 if it's a tie
  def winner(hand1, hand2) do
    cond do
      handPower(hand1) > handPower(hand2) ->
        {1, handPower(hand1) |> whichHand}

      handPower(hand1) < handPower(hand2) ->
        {2, handPower(hand2) |> whichHand}

      handPower(hand1) == handPower(hand2) ->
        hand1 = Enum.map(hand1, &cardPower/1)
        hand2 = Enum.map(hand2, &cardPower/1)
        tieBreaker(hand1, hand2, 0)

      true ->
        3
    end
  end

  def takeInput do
    IO.puts("Give both hands")
    IO.puts("follow the format: 'Black: 2H 3D 5S 9C KD White: 2D 3H 5C 9S KH'")
    input = IO.gets("")
    list = String.split(input)

    case length(list) do
      12 ->
        {black, white} = Enum.split(list, 6)
        {_color1, hand1} = Enum.split(black, 1)
        {_color2, hand2} = Enum.split(white, 1)
        winner(hand1, hand2)

      _ ->
        IO.puts("format not respected")
    end
  end

  def final do
    a = takeInput()

    case elem(a, 0) do
      1 ->
        case tuple_size(a) do
          2 ->
            "Black wins - #{elem(a, 1)}"

          3 ->
            "Black wins - #{elem(a, 1)} #{elem(a, 2)}"
        end

      2 ->
        case tuple_size(a) do
          2 ->
            "White wins - #{elem(a, 1)}"

          3 ->
            "White wins - #{elem(a, 1)} #{elem(a, 2)}"
        end

      3 ->
        "Tie"

      _ ->
        IO.puts("error bottom")
    end
  end
end
