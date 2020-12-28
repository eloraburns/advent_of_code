defmodule Tiles do
  defmodule Tile do
    defstruct [
      id: nil,
      sides: [],
      neighbours: []
    ]
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

      data = scanlines |> Enum.join("") |> String.to_charlist
      side1 = data |> Enum.take(10)
      side2 = data |> Enum.drop(9) |> Enum.take_every(10)
      side3 = data |> Enum.drop(90) |> Enum.reverse
      side4 = data |> Enum.take_every(10) |> Enum.reverse

      %Tile{
        id: String.to_integer(id),
        image_data: data,
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
      sides0 in tile2.sides -> 0
      sides1 in tile2.sides -> 1
      sides2 in tile2.sides -> 2
      sides3 in tile2.sides -> 3
      true -> false
    end
  end

  def rotate_tile(tile, 0), do: tile
  def rotate_tile(tile, number_of_90_degree_rotations) do
    new_sides = tile.sides
    |> Enum.map(&String.to_charlist/)
    |> Enum.zip
    |> Enum.map(fn new_row ->
      new_row
      |> Tuple.to_list
      |> IO.iodata_to_binary
    end)

    %Tile{ tile | sides: new_sides }
    |> rotate_tile(number_of_90_degree_rotations - 1)
  end

  def orient_top_to(%Tile{sides: [side0, side1, side2, side3]} = tile, top) do
    fliptop = String.reverse(top)
    cond do
      side0 == top ->     tile
      side1 == top ->     tile |> rotate_tile(3)
      side2 == top ->     tile |> rotate_tile(2)
      side3 == top ->     tile |> rotate_tile(1)
      side0 == fliptop -> tile |> flip_tile |> rotate_tile(2)
      side1 == fliptop -> tile |> flip_tile |> rotate_tile(3)
      side2 == fliptop -> tile |> flip_tile
      side3 == fliptop -> tile |> flip_tile |> rotate_tile(1)
    end
  end

  def orient_left_to(%Tile{sides: [side0, side1, side2, side3]} = tile, left) do
    flipleft = String.reverse(left)
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
    %Tile{ tile | sides: Enum.reverse(tile.sides) }
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

    {remaining_tiles, image} = stitch(not_corner, 0, 0, %{{0, 0} => rotated_corner})
    stitch(
  end

  def stitch([], 11, 11, image), do: image
  def stitch(tiles, 11, 0, image), do: {tiles, image}
  def stitch(tiles, 11, placed_y, image) do
    # place next at {0, placed_y + 1}
  end
  def stitch(tiles, placed_x, placed_y, image) do
    # going right
    %Tile{sides: [_side0, side1, _side2, _side3]} = Map.get({placed_x, placed_y}, image)
    flipped_side1 = String.reverse(side1)
    next_tile = tiles
    |> Enum.find(tiles, fn t -> side1 in t.sides or side2 in t.sides end)


  end

end

#     id: 1321,
#    sides: ['.....#.##.', '.#.#.#.#.#', '#####.###.', '...###.#..']
