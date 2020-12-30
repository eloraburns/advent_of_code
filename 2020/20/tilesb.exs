defmodule Tiles do
  defmodule Tile do
    defstruct [
      id: nil,
      image_data: [],
      sides: [],
      neighbours: []
    ]
  end

  defimpl String.Chars, for: Tile do
    def to_string(%Tile{id: id, neighbours: neighbours, image_data: image_data, sides: [side0, side1, side2, side3]}) do
      # Fetch corners
      << corner0, _::binary-size(8), corner1 >> = side0
      << corner3, _::binary-size(8), corner2 >> = side2
      # Assert they're the same corners
      << ^corner0, _::binary-size(8), ^corner3 >> = side3
      << ^corner1, _::binary-size(8), ^corner2 >> = side1

      middle = Enum.zip([
        side3 |> String.slice(1, 8) |> String.to_charlist,
        '        ',
        image_data,
        '        ',
        side1 |> String.slice(1, 8) |> String.to_charlist,
        '\n\n\n\n\n\n\n\n'
      ]) |> Enum.map(&Tuple.to_list/1)

      [
        "id:#{id} neighbours:#{inspect neighbours}\n\n",
        String.slice(side0, 0, 1),
        ?\s,
        String.slice(side0, 1, 8),
        ?\s,
        String.slice(side0, 9, 1),
        ?\n,
        ?\n,
        middle,
        ?\n,
        String.slice(side2, 0, 1),
        ?\s,
        String.slice(side2, 1, 8),
        ?\s,
        String.slice(side2, 9, 1)
      ] |> IO.iodata_to_binary
    end
  end

  def read(filename) do
    File.read!(filename)
  end

  def parse(input) do
    input
    |> String.trim
    |> String.split("\n\n")
    |> Enum.map(fn tile ->
      [<< "Tile ", id::binary-size(4), ":" >> | scanlines] = tile
      |> String.trim
      |> String.split("\n")

      raw_data = scanlines |> Enum.join("") |> String.to_charlist
      side0 = raw_data |> Enum.take(10)
      side1 = raw_data |> Enum.drop(9) |> Enum.take_every(10)
      side2 = raw_data |> Enum.drop(90)
      side3 = raw_data |> Enum.take_every(10)

      image_data = scanlines
      |> Enum.drop(1)
      |> Enum.take(8)
      |> Enum.map(&String.slice(&1, 1, 8))

      %Tile{
        id: String.to_integer(id),
        image_data: image_data,
        sides: [
          side0 |> IO.iodata_to_binary,
          side1 |> IO.iodata_to_binary,
          side2 |> IO.iodata_to_binary,
          side3 |> IO.iodata_to_binary
        ]}
    end)
  end

  def detect_neighbours(tiles) do
    tiles
    |> Enum.map(fn %{sides: [a, b, c, d]} = tile ->
      e = String.reverse(a)
      f = String.reverse(b)
      g = String.reverse(c)
      h = String.reverse(d)

      %Tile{
        tile |
        neighbours: (Enum.filter(tiles, fn tile2 ->
          (a in tile2.sides or
          b in tile2.sides or
          c in tile2.sides or
          d in tile2.sides or
          e in tile2.sides or
          f in tile2.sides or
          g in tile2.sides or
          h in tile2.sides)
          and tile.id != tile2.id
        end)
        |> Enum.map(&(&1.id)))
      }
    end)
  end

  def match_side(%Tile{sides: [side0, side1, side2, side3]}, tile2) do
    tile2_sides = tile2.sides ++ Enum.map(tile2.sides, &String.reverse/1)
    cond do
      side0 in tile2_sides -> 0
      side1 in tile2_sides -> 1
      side2 in tile2_sides -> 2
      side3 in tile2_sides -> 3
      true -> false
    end
  end

  def rotate_data(d) do
    d
    |> Enum.map(&String.to_charlist/1)
    |> Enum.zip
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&IO.iodata_to_binary/1)
  end

  def rotate_tile(tile, 0), do: tile
  def rotate_tile(%Tile{sides: [s0, s1, s2, s3]} = tile, number_of_90_degree_rotations) do
    %Tile{ tile |
      sides: [String.reverse(s3), s0, String.reverse(s1), s2],
      image_data: rotate_data(tile.image_data)
    }
    |> rotate_tile(number_of_90_degree_rotations - 1)
  end

  def orient_top_to(%Tile{sides: [side0, side1, side2, side3]} = tile, top) do
    fliptop = String.reverse(top)
    cond do
      side0 == top ->     tile
      side1 == top ->     tile              |> rotate_tile(3)
      side2 == top ->     tile |> flip_tile
      side3 == top ->     tile |> flip_tile |> rotate_tile(1)
      side0 == fliptop -> tile |> flip_tile |> rotate_tile(2)
      side1 == fliptop -> tile |> flip_tile |> rotate_tile(3)
      side2 == fliptop -> tile              |> rotate_tile(2)
      side3 == fliptop -> tile              |> rotate_tile(1)
    end
  end

  def orient_left_to(%Tile{sides: [side0, side1, side2, side3]} = tile, left) do
    flipleft = String.reverse(left)
    cond do
      side0 == left ->     tile |> flip_tile |> rotate_tile(1)
      side1 == left ->     tile |> flip_tile |> rotate_tile(2)
      side2 == left ->     tile              |> rotate_tile(1)
      side3 == left ->     tile
      side0 == flipleft -> tile              |> rotate_tile(3)
      side1 == flipleft -> tile              |> rotate_tile(2)
      side2 == flipleft -> tile |> flip_tile |> rotate_tile(3)
      side3 == flipleft -> tile |> flip_tile
    end
  end

  # Flips vertically
  def flip_tile(%Tile{sides: [s0, s1, s2, s3]} = tile) do
    %Tile{ tile |
      sides: [s2, String.reverse(s1), s0, String.reverse(s3)],
      image_data: Enum.reverse(tile.image_data)
    }
  end

  #      0
  #   +-----+
  #   |     |
  # 3 |     | 1
  #   |     |
  #   +-----+
  #      2
  def stitch(tiles) do
    corner = hd(Enum.filter(tiles, &(length(&1.neighbours) == 2)))
    not_corner = Enum.filter(tiles, &(&1.id != corner.id))

    rotations_required = Enum.map(not_corner, &match_side(corner, &1))
    |> Enum.filter(&(&1))
    |> Enum.sort
    |> case do
      [0, 1] -> 1 # turn to make top left
      [1, 2] -> 0 # turns to make top left
      [2, 3] -> 3 # turns to make top left
      [3, 0] -> 2 # turns to make top left
    end

    rotated_corner = rotate_tile(corner, rotations_required)

    IO.puts "0,0\n#{rotated_corner}"
    stitch(not_corner, 0, 0, %{{0, 0} => rotated_corner})
  end

  def stitch([], 11, 11, image), do: image
  def stitch(tiles, 11, placed_y, image) do
    # place next at {0, placed_y + 1}
    %Tile{sides: [_side0, _side1, side2, _side3]} = Map.get(image, {0, placed_y})
    flipped_side2 = String.reverse(side2)
    %{true => [next_tile], false => rest_of_tiles} = Enum.group_by(tiles, fn t ->
      side2 in t.sides or flipped_side2 in t.sides
    end)

    ready_to_place_tile = orient_top_to(next_tile, side2)

    IO.puts "0,#{placed_y + 1}\n#{ready_to_place_tile}"
    stitch(rest_of_tiles, 0, placed_y + 1, Map.put(image, {0, placed_y + 1}, ready_to_place_tile))
  end
  def stitch(tiles, placed_x, placed_y, image) do
    # going right, so get the right side of the lefterly (aka most recently placed) tile
    %Tile{sides: [_side0, side1, _side2, _side3]} = Map.get(image, {placed_x, placed_y})
    flipped_side1 = String.reverse(side1)
    tiles_true_false = Enum.group_by(tiles, fn t ->
      side1 in t.sides or flipped_side1 in t.sides
    end)

    next_tile = tiles_true_false |> Map.get(true) |> hd
    rest_of_tiles = tiles_true_false |> Map.get(false, [])

    ready_to_place_tile = orient_left_to(next_tile, side1)

    IO.puts "#{placed_x + 1},#{placed_y}\n#{ready_to_place_tile}"
    stitch(rest_of_tiles, placed_x + 1, placed_y, Map.put(image, {placed_x + 1, placed_y}, ready_to_place_tile))
  end
end
