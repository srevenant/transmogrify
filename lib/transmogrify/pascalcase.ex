defmodule Transmogrify.Pascalcase do
  @moduledoc "Convert strings to PascalCase"
  alias Transmogrify.Character

  @doc """
  Convert a string to `camelCase`, usually when originally `snake_case`, using
  the following rules:

    * first letter is always capitalized
    * ascii alphabetic letters immediately following an underscore are capitalized
    * underscores are removed
    * existing case and other characters are preserved in all other cases

  ```elixir
  iex> convert("PASCALCASE")
  "PASCALCASE"
  iex> convert("_pascal___case__")
  "PascalCase"
  iex> convert("pascal_case")
  "PascalCase"
  iex> convert("pascal_case")
  "PascalCase"
  iex> convert("PascalCASE")
  "PascalCASE"
  iex> convert("Pascal_CASE")
  "PascalCASE"
  iex> convert("PascalCase")
  "PascalCase"
  iex> convert("pascal_9case")
  "Pascal9case"
  ```
  """
  @spec convert(String.t()) :: String.t()
  def convert(string)

  def convert(""), do: ""
  def convert(key) when is_atom(key), do: convert(to_string(key))
  def convert(<<?_, rest::binary>>), do: convert(rest)
  def convert(<<c1, rest::binary>>), do: <<Character.upper(c1)>> <> do_convert(rest)

  defp do_convert(<<?_, ?_, rest::binary>>), do: do_convert(<<?_, rest::binary>>)

  defp do_convert(<<?_, c1, rest::binary>>) when c1 >= ?A and c1 <= ?z,
    do: <<Character.upper(c1)>> <> do_convert(rest)

  defp do_convert(<<?_, c1, rest::binary>>) when c1 >= ?0 and c1 <= ?9,
    do: <<c1>> <> do_convert(rest)

  defp do_convert(<<?_>>), do: <<>>
  defp do_convert(<<c1, rest::binary>>), do: <<c1>> <> do_convert(rest)
  defp do_convert(<<>>), do: <<>>
end
