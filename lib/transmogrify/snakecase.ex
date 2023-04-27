defmodule Transmogrify.Snakecase do
  @moduledoc "Convert strings to snake_case"
  alias Transmogrify.Character

  @doc """
  Convert a string to `snake_case`, usually when originally `PascalCase` or
  `CamelCase`, using the following rules:

    * dashes are treated the same as underscores
    * uppercase ascii alphabetic letters are lowercased, and prefixed with
      an underscore, except when they are the first letter.
    * duplicate underscores are removed
    * ACRONYMS are preserved
    * other characters are preserved in all other cases

  Similar to Pathname, except `.` is not converted to `/`, and dashes are
  coverted to underbars

  ```elixir
  iex> convert("value-dashed")
  "value_dashed"
  iex> convert("Value")
  "value"
  iex> convert("vaLue")
  "va_lue"
  iex> convert("VALUE")
  "value"
  iex> convert("vaLUE")
  "va_lue"
  iex> convert("-vaLUE")
  "va_lue"
  iex> convert("_va___LUE")
  "va_lue"
  ```
  """
  @spec convert(String.t()) :: String.t()
  def convert(key) when is_atom(key), do: convert(to_string(key))
  def convert(<<?_, rest::binary>>), do: convert(rest)
  def convert(<<?-, rest::binary>>), do: convert(rest)
  def convert(<<ch, rest::binary>>), do: <<Character.lower(ch)>> <> do_convert(rest, ch)
  def convert(""), do: ""

  # convert dash to underbar
  defp do_convert(<<?-, rest::binary>>, prev), do: do_convert(<<?_, rest::binary>>, prev)

  # ignore multiple in a row
  defp do_convert(<<?_, c2, rest::binary>>, prev) when c2 == ?_ or c2 == ?-,
    do: do_convert(<<?_, rest::binary>>, prev)

  # already snaked
  defp do_convert(<<?_, rest::binary>>, _), do: <<?_>> <> do_convert(rest, ?_)

  defp do_convert(<<c1, rest::binary>>, ?_), do: <<Character.lower(c1)>> <> do_convert(rest, c1)

  defp do_convert(<<c1, rest::binary>>, prev)
       when c1 >= ?A and c1 <= ?Z and not (prev >= ?A and prev <= ?Z),
       do: <<?_, Character.lower(c1)>> <> do_convert(rest, c1)

  defp do_convert(<<c1, rest::binary>>, _), do: <<Character.lower(c1)>> <> do_convert(rest, c1)

  defp do_convert(<<>>, _) do
    <<>>
  end
end
