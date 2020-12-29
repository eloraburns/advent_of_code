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
      middle = Enum.zip([
        side3 |> String.slice(1, 8) |> String.to_charlist |> Enum.reverse,
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
        String.slice(side2, 9, 1),
        ?\s,
        String.slice(side2, 1, 8) |> String.reverse,
        ?\s,
        String.slice(side2, 0, 1)
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
      side1 = raw_data |> Enum.take(10)
      side2 = raw_data |> Enum.drop(9) |> Enum.take_every(10)
      side3 = raw_data |> Enum.drop(90) |> Enum.reverse
      side4 = raw_data |> Enum.take_every(10) |> Enum.reverse

      image_data = scanlines
      |> Enum.drop(1)
      |> Enum.take(8)
      |> Enum.map(&String.slice(&1, 1, 8))

      %Tile{
        id: String.to_integer(id),
        image_data: image_data,
        sides: [
          side1 |> IO.iodata_to_binary,
          side2 |> IO.iodata_to_binary,
          side3 |> IO.iodata_to_binary,
          side4 |> IO.iodata_to_binary
        ]}
    end)
  end

  def check_uniqueness(tiles) do
    num_tiles = length(tiles)
    num_sides = num_tiles * 4

    tile_set = tiles
    |> Enum.flat_map(fn tile ->
      tile.sides ++ Enum.map(tile.sides, &String.reverse/1)
    end)
    |> MapSet.new

    IO.puts "tiles: #{num_tiles}, sides: #{num_sides}, size(tile_set): #{MapSet.size(tile_set)}"
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

  def solvea(filename) do
    filename
    |> Tiles.read
    |> Tiles.parse
    |> Tiles.detect_neighbours
    |> Enum.filter(&(length(&1.neighbours) == 2))
    |> Enum.map(&(&1.id))
    |> Enum.reduce(&Kernel.*/2)
  end

  def test20a do
    solvea("test.txt")
  end

  def solve20a do
    solvea("input.txt")
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
    %Tile{ tile | sides: [s3, s0, s1, s2], image_data: rotate_data(tile.image_data) }
    |> rotate_tile(number_of_90_degree_rotations - 1)
  end

  def orient_top_to(%Tile{sides: [side0, side1, side2, side3]} = tile, fliptop) do
    # Because the "top" we're aligning to is the bottom of the tile above,
    # when we're passed the "bottom side" it's read backwards (clockwise).
    top = String.reverse(fliptop)
    cond do
      side0 == top ->     IO.puts("rotate(0)"); tile
      side1 == top ->     IO.puts("rotate(3)"); tile |> rotate_tile(3)
      side2 == top ->     IO.puts("rotate(2)"); tile |> rotate_tile(2)
      side3 == top ->     IO.puts("rotate(1)"); tile |> rotate_tile(1)
      side0 == fliptop -> IO.puts("flip;rotate(2)"); tile |> flip_tile |> rotate_tile(2)
      side1 == fliptop -> IO.puts("flip;rotate(3)"); tile |> flip_tile |> rotate_tile(3)
      side2 == fliptop -> IO.puts("flip;rotate(0)"); tile |> flip_tile
      side3 == fliptop -> IO.puts("flip;rotate(1)"); tile |> flip_tile |> rotate_tile(1)
    end
  end

  def orient_left_to(%Tile{sides: [side0, side1, side2, side3]} = tile, flipleft) do
    left = String.reverse(flipleft)
    cond do
      side0 == left ->     tile |> rotate_tile(3)
      side1 == left ->     tile |> rotate_tile(2)
      side2 == left ->     tile |> rotate_tile(1)
      side3 == left ->     tile
      side0 == flipleft -> tile |> flip_tile |> rotate_tile(1)
      side1 == flipleft -> tile |> flip_tile |> rotate_tile(2)
      side2 == flipleft -> tile |> flip_tile |> rotate_tile(3)
      side3 == flipleft -> tile |> flip_tile
    end
  end

  # Flips vertically
  def flip_tile(tile) do
    [s0, s1, s2, s3] = Enum.map(tile.sides, &String.reverse/1)
    %Tile{ tile |
      sides: [s2, s3, s0, s1],
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

    stitch(not_corner, 0, 0, %{{0, 0} => rotated_corner})
  end

  def stitch([], 11, 11, image), do: image
  def stitch(tiles, 11, placed_y, image) do
    # place next at {0, placed_y + 1}
    %Tile{sides: [_side0, _side1, side2, _side3]} = Map.get({0, placed_y + 1}, image)
    flipped_side2 = String.reverse(side2)
    %{true => [next_tile], false => rest_of_tiles} = Enum.group_by(tiles, fn t ->
      side2 in t.sides or flipped_side2 in t.sides
    end)

    ready_to_place_tile = orient_top_to(next_tile, side2)

    stitch(rest_of_tiles, 0, placed_y + 1, Map.put(image, {0, placed_y + 1}, ready_to_place_tile))
  end
  def stitch(tiles, placed_x, placed_y, image) do
    # going right, so get the right side of the lefterly (aka most recently placed) tile
    %Tile{sides: [_side0, side1, _side2, _side3]} = Map.get({placed_x, placed_y}, image)
    flipped_side1 = String.reverse(side1)
    %{true => [next_tile], false => rest_of_tiles} = Enum.group_by(tiles, fn t ->
      side1 in t.sides or flipped_side1 in t.sides
    end)

    ready_to_place_tile = orient_left_to(next_tile, side1)

    stitch(rest_of_tiles, placed_x + 1, placed_y, Map.put(image, {placed_x + 1, placed_y}, ready_to_place_tile))
  end

  def test do
    raw_tile = """
    Tile 0123:
    ...#.#....
    .........#
    #.........
    #....##.##
    .#...##...
    ..#.#..#.#
    .....#...#
    #...#..#.#
    ##....#...
    #.####....
    """
    [tile] = parse(raw_tile)

    expected_stringified_tile = """
    id:123 neighbours:[]
    . ..#.#... .

    . ........ #
    # ........ .
    # ....##.# #
    . #...##.. .
    . .#.#..#. #
    . ....#... #
    # ...#..#. #
    # #....#.. .

    # .####... .
    """

    [expected_flipped_tile] = parse("""
    Tile 0123:
    #.####....
    ##....#...
    #...#..#.#
    .....#...#
    ..#.#..#.#
    .#...##...
    #....##.##
    #.........
    .........#
    ...#.#....
    """)

    stringified_tile = to_string(tile)
    actual_flipped_tile = flip_tile(tile)
 
    cond do
      stringified_tile != expected_stringified_tile ->
        IO.puts "NOT STRINGIFIED"
        IO.puts "Raw #{raw_tile}"
        IO.puts "Expected #{expected_stringified_tile}"
        IO.puts "Actual #{stringified_tile}"
      actual_flipped_tile != expected_flipped_tile ->
        IO.puts "NOT FLIPPED"
        IO.puts "Tile #{tile}"
        IO.puts "Expected #{expected_flipped_tile}"
        IO.puts "Actual #{actual_flipped_tile}"
      true -> :passed
    end

  end
end
