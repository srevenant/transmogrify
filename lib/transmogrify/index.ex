defmodule Transmogrify do
  @moduledoc """
  Accepts data with different shapes and changes them to an expected shape, such
  as switching keys in a map to camel case, or all string keys to atom keys, etc.
  """

  @spec transmogrify(data :: map() | list(), opts :: map() | keyword()) ::
          result :: map() | list()
  def transmogrify(data, opts \\ %{key_convert: :atom, key_case: :snake})
  defdelegate transmogrify(data, opts), to: Transmogrify.Transmogrifier

  @spec camelcase(binary()) :: binary()
  defdelegate camelcase(x), to: Transmogrify.Camelcase, as: :convert

  @spec snakecase(binary()) :: binary()
  defdelegate snakecase(x), to: Transmogrify.Snakecase, as: :convert

  @spec pascalcase(binary()) :: binary()
  defdelegate pascalcase(x), to: Transmogrify.Pascalcase, as: :convert
  @spec modulename(binary()) :: binary()
  defdelegate modulename(x), to: Transmogrify.Modulename, as: :convert

  @spec pathname(binary()) :: binary()
  defdelegate pathname(x), to: Transmogrify.Pathname, as: :convert
end
