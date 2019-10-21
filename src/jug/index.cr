require "./*"
require "../libs/dtype"
require "../flask/*"
require "../strides/offsets"
require "../indexing/base"

class Jug(T)
  # Pours a Flask from a Jug row
  #
  # ```
  # m = Jug.new [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  # m[0] # => [1, 2, 3]
  # ```
  def [](i : Indexer)
    slice = data[*Strides.offset_row(i, tda, ncols, 1)]
    Flask.new slice, ncols, 1
  end

  # Pours a Flask into a Jug row
  #
  # ```
  # m = Jug.new [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  # m[2] = [1, 2, 3]
  # ```
  def []=(i : Indexer, row : Flask(T))
    ncols.times do |j|
      self[i, j] = row[j]
    end
  end

  # Pours a Flask into a Jug column
  #
  # ```
  # m = Jug.new [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  # m[..., 2] = [1, 2, 3]
  # ```
  def []=(i : Range(Nil, Nil), j : Indexer, col : Flask(T))
    nrows.times do |r|
      self[r, j] = col[r]
    end
  end

  # Pours a drop from a Jug
  #
  # ```
  # m = Jug.new [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  # m[2, 2] # => 9
  # ```
  def [](i : Indexer, j : Indexer)
    data[Strides.offset(i, tda, j, 1)]
  end

  # Pours a drop into a Jug
  #
  # ```
  # m = Jug.new [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  # m[2, 2] = 100
  # ```
  def []=(i : Indexer, j : Indexer, x : T)
    data[Strides.offset(i, tda, j, 1)] = x
  end

  # Pours a Flask from a Jug column
  #
  # ```
  # m = Jug.new [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  # m[..., 0] # => [1, 4, 7]
  # ```
  def [](i : Range(Indexer?, Indexer?), j : Indexer)
    x = LL.convert_range_to_slice(
      i, nrows)
    x_offset = x.end - x.begin
    xi = x.end - 1
    start = Strides.offset(
      x.begin, tda, j, 1)
    finish = Strides.offset(
      xi, tda, ncols, 1)
    slice = data[start, finish - start]

    Flask(T).new(
      slice,
      x_offset.to_i32,
      tda,
    )
  end

  # Pours a view of a jug from given ranges
  #
  # ```
  # m = Jug.new [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
  # m[...2, ...2] # => [[1, 2], [4, 5]]
  # ```
  def [](i : Range(Indexer?, Indexer?) = ..., j : Range(Indexer?, Indexer?) = ...)
    x = LL.convert_range_to_slice(
      i, nrows)
    y = LL.convert_range_to_slice(
      j, ncols)
    x_offset = x.end - x.begin
    y_offset = y.end - y.begin
    xi = x.end - 1
    yi = y.end - 1
    start = Strides.offset(
      x.begin, tda, y.begin, 1)
    finish = Strides.offset(
      xi, tda, yi, 1) + 1
    slice = data[start, finish - start]
    rows = x_offset.to_i32
    cols = y_offset.to_i32

    Jug(T).new(
      slice,
      rows,
      cols,
      tda,
    )
  end
end