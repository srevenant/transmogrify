defmodule Transmogrify.Pathname do
  @moduledoc "Convert Elixir ModuleName to file/paths."
  alias Transmogrify.Character

  @doc """
  Convert an Elixir's `Path.ModuleName.String` to `path/module_name/string`,
  using the following rules:

    * `PascalCase` to `snake_case` rules apply
    * dots are converted to slashes
    * "Elixir." prefix that exists on elixir module atoms is removed

  ```elixir
  iex> convert("Module")
  "module"
  iex> convert("ModuleName")
  "module_name"
  iex> convert("MODULENAME")
  "modulename"
  iex> convert("ModuleName")
  "module_name"
  iex> convert("ModuleName.Here")
  "module_name/here"
  iex> convert("path/name/here")
  "path/name/here"
  iex> convert(Transmogrify.Pathname)
  "transmogrify/pathname"
  iex> convert("A.AcronymNAME")
  "a/acronym_name"
  ```

  note: Original code from Macro.underscore()
  """

  @spec convert(atom | String.t()) :: String.t()
  def convert(atom) when is_atom(atom) do
    "Elixir." <> rest = to_string(atom)
    convert(rest)
  end

  def convert(<<h, t::binary>>) do
    <<Character.lower(h)>> <> do_convert(t, h)
  end

  def convert("") do
    ""
  end

  defp do_convert(<<h, t, rest::binary>>, _)
       when h >= ?A and h <= ?Z and not (t >= ?A and t <= ?Z) and not (t >= ?0 and t <= ?9) and
              t != ?. and t != ?_ do
    <<?_, Character.lower(h), t>> <> do_convert(rest, t)
  end

  defp do_convert(<<h, t::binary>>, prev)
       when h >= ?A and h <= ?Z and not (prev >= ?A and prev <= ?Z) and prev != ?_ do
    <<?_, Character.lower(h)>> <> do_convert(t, h)
  end

  defp do_convert(<<?., t::binary>>, _) do
    <<?/>> <> convert(t)
  end

  defp do_convert(<<h, t::binary>>, _) do
    <<Character.lower(h)>> <> do_convert(t, h)
  end

  defp do_convert(<<>>, _) do
    <<>>
  end
end
