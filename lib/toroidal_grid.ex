defmodule ToroidalGrid do
  @moduledoc """
  A set of functions to work with a 2d toroidal grid and apply tranformation on
  elements' neighborhoods.

  Each point of the grid has a neighborhood that overlaps the neighborhoods of
  nearby points. In basic algorithm, all the neighborhoods have the same size
  and identical shapes. The two most commonly used neighborhoods are L5
  (like defined here).

  """
  defstruct max_row_i: 0, max_col_i: 0, grid: {}
  @type t :: TupleMatrix.t

  @type element :: TupleMatrix.element
  @type size :: non_neg_integer
  @type row :: non_neg_integer
  @type col :: non_neg_integer

  @doc ~S"""
  Returns a toroidalgrid of size `rows`X`cols` where each item is the result
  of invoking `fun`, passing the row number and column number as arguments.

  ## Examples
      iex> rows = 2
      iex> cols = 3
      iex> ToroidalGrid.new(rows, cols, &(&1 * cols + &2))
      %TupleMatrix{
        nb_rows: 2,
        nb_cols: 3,
        tuple: {0, 1, 2, 3, 4, 5}
      }

  """
  @spec new(size, size, TupleMatrix.producer) :: t
  def new(rows, cols, producer) do
    TupleMatrix.new(rows, cols, producer)
  end

  @doc ~S"""
  Returns a toroidalgrid where each item is the result of invoking
  `fun` on each corresponding item of `toroidal`.

  ## Examples

      iex> rows = 2
      iex> cols = 3
      iex> toroidal = ToroidalGrid.new(rows, cols, &(&1 * cols + &2))
      iex>
      iex> ToroidalGrid.map(toroidal, &(&1 * 2))
      %TupleMatrix{
        nb_rows: 2,
        nb_cols: 3,
        tuple: {0, 2, 4, 6, 8, 10}
      }

  """
  @spec map(t, ((element) -> element)) :: t
  def map(%{tuple: grid} = toroidal, fun) do
    new_grid =
      grid
      |> Tuple.to_list
      |> Enum.map(&fun.(&1))
      |> List.to_tuple

    %TupleMatrix{toroidal | tuple: new_grid}
  end

  @doc ~S"""
  Invokes `fun` for each element in the `toroidal`, passing that
  element and the accumulator as arguments. `fun`'s return value
  is stored in the accumulator.

  The first element of the `toroidal` is used as the initial value of
  the accumulator.
  This function won't call the specified function for enumerables that
  are one-element long.

  Returns the accumulator.

  Note that since the first element of the toroidal is used as the
  initial value of the accumulator, `fun` will only be executed `n - 1`
  times where `n` = rows x cols.

  ## Examples
      iex> ToroidalGrid.reduce(%{tuple: {1, 2, 3, 1, 2, 3}}, fn(x, acc) -> x * acc end)
      36

  """
  @spec reduce(t, ((element, element) -> any)) :: any

  def reduce(%{tuple: grid} = _toroidal, fun) do
    grid
    |> Tuple.to_list
    |> Enum.reduce(fun)
  end

  @doc """
  Returns a toroidalgrid where each item is the result of invoking
  `fun` on each corresponding item's neighborhood.

  ## Examples

      iex> rows = 3
      iex> cols = 3
      iex> toroidal = ToroidalGrid.new(rows, cols, &(&1 * cols + &2))
      iex>
      iex> transform = fn _current, hood ->
      ...>   hood
      ...>   |> Enum.reduce([], &([&1|&2]))
      ...>   |> Enum.sort
      ...> end
      iex> ToroidalGrid.map_neighborhoods(toroidal, transform)
      %TupleMatrix{
        nb_cols: 3,
        nb_rows: 3,
        tuple: {
          [0, 1, 2, 3, 6], [0, 1, 2, 4, 7], [0, 1, 2, 5, 8],
          [0, 3, 4, 5, 6], [1, 3, 4, 5, 7], [2, 3, 4, 5, 8],
          [0, 3, 6, 7, 8], [1, 4, 6, 7, 8], [2, 5, 6, 7, 8]
          }
        }

  """
  @spec map_neighborhoods(t, ((element, list(element)) -> element)) :: t

  def map_neighborhoods(%{nb_rows: nb_rows, nb_cols: nb_cols} = toroidal, transform) do
    fun = fn row, col ->
      current      = toroidal |> at(row, col)
      neighborhood = toroidal |> neighborhood(row, col)

      transform.(current, neighborhood)
    end

    new(nb_rows, nb_cols, fun)
  end

  #SOUTH #EAST + OPPOSITE_SOUTH + OPPOSITE_NORTH
  def neighborhood(t, 0 = r, 0 = c) do
    [at(t, r, c), south(t, r, c), east(t, r, c), extrm_south(t, r, c), extrm_east(t, r, c)]
  end
  def neighborhood(%{nb_cols: nb_cols} = t, 0 = r, c) do
    c_max = nb_cols - 1
    if c == c_max do #WEST #SOUTH + OPPOSITE_WEST + OPPOSITE_SOUTH
      [at(t, r, c_max), west(t, r, c_max), south(t, r, c_max), extrm_west(t, r, c_max), extrm_south(t, r, c_max)]
    else #WEST #EAST #SOUTH + OPPOSITE_SOUTH
      [at(t, r, c), west(t, r, c), east(t, r, c), south(t, r, c), extrm_south(t, r, c)]
    end
  end
  def neighborhood(%{nb_rows: nb_rows} = t, r, 0 = c) do
    r_max = nb_rows - 1
    if r ==  r_max do #NORTH #EAST + OPPOSITE_NORTH + OPPOSITE_EAST
      [at(t, r_max, c), north(t, r_max, c), east(t, r_max, c), extrm_north(t, r_max, c),extrm_east(t, r_max, c)]
    else #NORTH #EAST #SOUTH + OPPOSITE_EAST
      [at(t, r, c), north(t, r, c), east(t, r, c), south(t, r, c), extrm_east(t, r, c)]
    end
  end

  def neighborhood(%{nb_rows: nb_rows, nb_cols: nb_cols} = t, row, col) do
    r_max = nb_rows - 1
    c_max = nb_cols - 1
    case {row, col} do
      {^r_max, ^c_max} -> #WEST #NORTH + OPPOSITE_WEST + OPPOSITE_NORTH
        [at(t, r_max, c_max), west(t, r_max, c_max), north(t, r_max, c_max), extrm_west(t, r_max, c_max), extrm_north(t, r_max, c_max)]
      {^r_max, _} -> #WEST #NORTH #EAST + TOP_ROW_POS
        [at(t, r_max, col), west(t, r_max, col), north(t, r_max, col), east(t, r_max, col)]
          ++ [extrm_north(t, r_max, col)|[]]
      {_, ^c_max} -> #NORTH #WEST #SOUTH + OPPOSITE_west
        [at(t, row, c_max), north(t, row, c_max), west(t, row, c_max), south(t, row, c_max)]
          ++ [extrm_west(t, row, c_max)|[]]
      {_, _} -> #WEST #NORTH #EAST #SOUTH
        [at(t, row, col), west(t, row, col), north(t, row, col), east(t, row, col), south(t, row, col)]
    end

  end

  defdelegate at(grid, row, col), to: TupleMatrix, as: :at

  defp north(grid, row, col), do: TupleMatrix.at(grid, row - 1, col)

  defp east(grid, row, col), do: TupleMatrix.at(grid, row, col + 1)

  defp south(grid, row, col), do: TupleMatrix.at(grid, row + 1, col)

  defp west(grid, row, col), do: TupleMatrix.at(grid, row, col - 1)

  defp extrm_north(grid, _, col), do: TupleMatrix.at(grid, 0, col)

  defp extrm_east(%{nb_cols: nb_cols} = grid, row, _), do: TupleMatrix.at(grid, row, nb_cols - 1)

  defp extrm_south(%{nb_rows: nb_rows} = grid, _, col), do: TupleMatrix.at(grid, nb_rows - 1, col)

  defp extrm_west(grid, row, _), do: TupleMatrix.at(grid, row, 0)
end
