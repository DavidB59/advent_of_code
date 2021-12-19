defmodule Day19 do
  def file, do: Parser.read_file("day19")
  def test, do: Parser.read_file("test")

  def parse(input) do
    input
    |> Enum.chunk_by(fn x -> String.contains?(x, "scanner") end)
    |> Enum.reduce({%{}, ""}, fn
      [value], {map, _last_key} ->
        last_key =
          value
          |> String.trim("-")
          |> String.trim()
          |> String.trim("scanner")
          |> String.trim()
          |> String.to_integer()

        {map, last_key}

      list, {map, last_key} ->
        value =
          list
          |> Enum.reject(&(&1 == ""))
          |> Enum.map(fn coordinates ->
            coordinates |> String.split(",") |> Enum.map(&String.to_integer/1)
          end)

        {Map.put(map, last_key, value), last_key}
    end)
    |> elem(0)
  end

  def solve_part_one() do
    map =
      file()
      |> parse()
      |> to_distance_map()

    zero = Map.get(map, 0)
    keys = Map.keys(map)

    {zero, keys}
    |> align_all_point_to_first_scanner(map)
    |> Map.values()
    |> Enum.reduce([], fn [a, b], acc -> [a] ++ [b] ++ acc end)
    |> Enum.uniq()
    |> Enum.count()
  end

  def to_distance_map(input) do
    input
    |> Enum.map(fn {key, value} -> {key, distance_by_scanner(value)} end)
    |> Map.new()
  end

  def distance_by_scanner(beacon_list) do
    Enum.reduce(beacon_list, %{}, fn beacon1, acc ->
      Enum.reduce(beacon_list, %{}, fn
        ^beacon1, acc ->
          acc

        beacon2, acc ->
          key = Enum.sort([beacon1, beacon2])
          d = distance_between_two_points(beacon1, beacon2)

          Map.put(acc, d, key)
      end)
      |> Map.merge(acc)
    end)
  end

  def distance_between_two_points([x1, y1, z1], [x2, y2, z2]) do
    (:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2) + :math.pow(z2 - z1, 2)) |> :math.sqrt()
  end

  def align_all_point_to_first_scanner({map, []}, _original_map), do: map

  def align_all_point_to_first_scanner({map, key_later}, original_map) do
    Enum.reduce(key_later, {map, []}, fn key, {acc, key_later} ->
      scanner = Map.get(original_map, key)

      if scanner do
        result = align_point_from_scanner_1_to_2(acc, Map.get(original_map, key))

        if result == :try_later do
          {acc, [key | key_later]}
        else
          {result, key_later}
        end
      else
        {acc, key_later}
      end
    end)
    |> align_all_point_to_first_scanner(original_map)
  end

  def align_point_from_scanner_1_to_2(distance_map1, distance_map2) do
    keys1 = Map.keys(distance_map1)
    keys2 = Map.keys(distance_map2)
    common_keys = Enum.filter(keys1, &Enum.member?(keys2, &1))

    common_distance_map1 = Map.take(distance_map1, common_keys)
    common_distance_map2 = Map.take(distance_map2, common_keys)

    reverse_map_1 = common_distance_map1 |> Enum.map(fn {k, v} -> {v, k} end) |> Map.new()

    vectors1 = reverse_map_1 |> Map.keys()

    case find_two_distances_with_same_point(vectors1, vectors1) do
      {vector1, vector2} ->
        distance1 = Map.get(reverse_map_1, vector1)
        distance2 = Map.get(reverse_map_1, vector2)

        vector1_map2 = Map.get(common_distance_map2, distance1)

        vector2_map2 = Map.get(common_distance_map2, distance2)

        four_points = vector1_map2 ++ vector2_map2

        [common_point_2] = four_points -- Enum.uniq(four_points)

        [common_point_1, _] = vector1
        [^common_point_1, _] = vector2

        vector1_map2 =
          case vector1_map2 do
            [_, ^common_point_2] -> to_vector(vector1_map2)
            [^common_point_2, b] -> to_vector([b, common_point_2])
          end

        vector1 = to_vector(vector1)
        op_list = realign_vector(vector1_map2, vector1)

        reoriented = apply_list_operation_to_point(common_point_2, op_list)

        move = move_to_origin_scanner1(common_point_1, reoriented) |> IO.inspect(label: "move")

        list_points2 =
          distance_map2
          |> Map.values()
          |> Enum.reduce([], fn [a, b], acc -> [a] ++ [b] ++ acc end)
          |> Enum.uniq()
          |> Enum.map(fn point ->
            point
            |> apply_list_operation_to_point(op_list)
            |> to_vector(move)
            |> return_vector()
          end)

        list_points1 =
          distance_map1
          |> Map.values()
          |> Enum.reduce([], fn [a, b], acc -> [a] ++ [b] ++ acc end)
          |> Enum.uniq()

        (list_points1 ++ list_points2)
        |> Enum.uniq()
        |> distance_by_scanner

      # try later
      _ ->
        :try_later
    end
  end

  def move_to_origin_scanner1([x1, y1, z1], [x2, y2, z2]) do
    [x1 + x2, y1 + y2, z1 + z2]
  end

  def find_two_distances_with_same_point([], _), do: :try_later

  def find_two_distances_with_same_point([head | rest], list_point_a_point_b) do
    [point_a, _point_b] = head

    common_point =
      Enum.find(list_point_a_point_b, fn
        [^point_a, _point_b] = common -> common != head
        _ -> false
      end)

    if common_point do
      {head, common_point}
    else
      find_two_distances_with_same_point(rest, list_point_a_point_b)
    end
  end

  def to_vector([[x1, y1, z1], [x2, y2, z2]]) do
    [x1 - x2, y1 - y2, z1 - z2]
  end

  def to_vector([x1, y1, z1], [x2, y2, z2]) do
    [x1 - x2, y1 - y2, z1 - z2]
  end

  def apply_list_operation_to_point(point, operation_list) do
    Enum.reduce(operation_list, point, &apply_operation(&1, &2))
  end

  def apply_operation(:return, point), do: return_vector(point)
  def apply_operation(:xy_mirror, point), do: xy_mirror(point)
  def apply_operation(:xz_mirror, point), do: xz_mirror(point)
  def apply_operation(:yz_mirror, point), do: yz_mirror(point)
  def apply_operation(:x_rotation, point), do: x_rotation(point)
  def apply_operation(:y_rotation, point), do: y_rotation(point)
  def apply_operation(:z_rotation, point), do: z_rotation(point)

  def realign_vector(vector1, vector2, operation_list \\ [])
  def realign_vector([x1, y1, z1], [x1, y1, z1], operation_list), do: Enum.reverse(operation_list)

  def realign_vector([x1, y1, z1] = vector1, [x2, y2, z2] = vector2, operation_list)
      when x1 == -x2 and y1 == -y2 and z1 == -z2 do
    vector1 |> return_vector() |> realign_vector(vector2, [:return | operation_list])
  end

  def realign_vector([x1, y1, z1] = vector1, [x2, y2, z2] = vector2, operation_list)
      when x1 == x2 and y1 == -y2 and z1 == -z2 do
    vector1
    |> x_rotation()
    |> x_rotation()
    |> realign_vector(vector2, [:x_rotation, :x_rotation | operation_list])
  end

  def realign_vector([x1, y1, z1] = vector1, [x2, y2, z2] = vector2, operation_list)
      when x1 == -x2 and y1 == y2 and z1 == -z2 do
    vector1
    |> y_rotation()
    |> y_rotation()
    |> realign_vector(vector2, [:y_rotation, :y_rotation | operation_list])
  end

  def realign_vector([x1, y1, z1] = vector1, [x2, y2, z2] = vector2, operation_list)
      when x1 == -x2 and y1 == -y2 and z1 == z2 do
    vector1
    |> z_rotation()
    |> z_rotation()
    |> realign_vector(vector2, [:z_rotation, :z_rotation | operation_list])
  end

  def realign_vector([x1, y1, z1] = vector1, [x2, y2, z2] = vector2, operation_list)
      when x1 == x2 and y1 == y2 and z1 == -z2 do
    vector1
    |> xy_mirror()
    |> realign_vector(vector2, [:xy_mirror | operation_list])
  end

  def realign_vector([x1, y1, z1] = vector1, [x2, y2, z2] = vector2, operation_list)
      when x1 == x2 and y1 == -y2 and z1 == z2 do
    vector1
    |> xz_mirror()
    |> realign_vector(vector2, [:xz_mirror | operation_list])
  end

  def realign_vector([x1, y1, z1] = vector1, [x2, y2, z2] = vector2, operation_list)
      when x1 == -x2 and y1 == y2 and z1 == z2 do
    vector1
    |> yz_mirror()
    |> realign_vector(vector2, [:yz_mirror | operation_list])
  end

  def realign_vector([x1, y1, z1] = vector1, [x2, y2, z2] = vector2, operation_list)
      when abs(x1) == abs(x2) and abs(y1) != abs(y2) and abs(z1) != abs(z2) do
    vector1
    |> x_rotation()
    |> realign_vector(vector2, [:x_rotation | operation_list])
  end

  def realign_vector([x1, y1, z1] = vector1, [x2, y2, z2] = vector2, operation_list)
      when abs(y1) == abs(y2) and abs(x1) != abs(x2) and abs(z1) != abs(z2) do
    vector1
    |> y_rotation()
    |> realign_vector(vector2, [:y_rotation | operation_list])
  end

  def realign_vector([x1, y1, z1] = vector1, [x2, y2, z2] = vector2, operation_list)
      when abs(z1) == abs(z2) and abs(y1) != abs(y2) and abs(x1) != abs(x2) do
    vector1
    |> z_rotation()
    |> realign_vector(vector2, [:z_rotation | operation_list])
  end

  def realign_vector(vector1, vector2, operation_list) do
    vector1
    |> z_rotation()
    |> realign_vector(vector2, [:z_rotation | operation_list])
  end

  def return_vector([x, y, z]), do: [-x, -y, -z]

  def x_rotation([x, y, z]), do: [x, -z, y]
  def y_rotation([x, y, z]), do: [z, y, -x]
  def z_rotation([x, y, z]), do: [-y, x, z]

  def xy_mirror([x, y, z]), do: [x, y, -z]
  def xz_mirror([x, y, z]), do: [x, -y, z]
  def yz_mirror([x, y, z]), do: [-x, y, z]

  def manhanattan_distance(list_move) do
    list_move
    |> Enum.map(fn move ->
      Enum.reduce(list_move, 0, fn move2, acc ->
        distance =
          to_vector(move, move2)
          |> Enum.map(&abs/1)
          |> Enum.sum()

        if distance > acc, do: distance, else: acc
      end)
    end)
    |> Enum.max()
  end
end
