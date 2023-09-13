defmodule Transmogrify.Camelcase do
  @moduledoc "Convert strings to CamelCase"
  alias Transmogrify.Character

  @doc """
  Convert a string to `camelCase`, usually when originally `snake_case`, using
  the following rules:

    * ascii alphabetic letters immediately following an underscore are capitalized
    * underscores are removed
    * existing case and other characters are preserved in all other cases

  TODO: xref common feels around camelcase — spaces? other chars?

  ```elixir
  iex> convert("_camel___case__")
  "camelCase"
  iex> convert("camel_case")
  "camelCase"
  iex> convert("camel_9case")
  "camel9case"
  iex> convert("camel_case")
  "camelCase"
  iex> convert("CamelCASE")
  "CamelCASE"
  iex> convert("Camel_CASE")
  "CamelCASE"
  iex> convert("CamelCase")
  "CamelCase"
  iex> convert(:CamelCase)
  "CamelCase"
  ```
  """
  # iex> convert("special camel case")
  # "special camel case"
  @spec convert(String.t() | atom()) :: String.t()
  def convert(string)

  # Original code from Macro module
  def convert(""), do: ""
  def convert(key) when is_atom(key), do: convert(to_string(key))
  def convert(<<?_, rest::binary>>), do: convert(rest)
  def convert(value), do: do_convert(value)

  defp do_convert(<<?_, ?_, rest::binary>>), do: do_convert(<<?_, rest::binary>>)

  defp do_convert(<<?_, c1, rest::binary>>) when c1 >= ?A and c1 <= ?z,
    do: <<Character.upper(c1)>> <> do_convert(rest)

  defp do_convert(<<?_, c1, rest::binary>>) when c1 >= ?0 and c1 <= ?9,
    do: <<c1>> <> do_convert(rest)

  defp do_convert(<<?_>>), do: <<>>
  defp do_convert(<<c1, rest::binary>>), do: <<c1>> <> do_convert(rest)
  defp do_convert(<<>>), do: <<>>
end
