defmodule Transmogrify.Modulename do
  @moduledoc "Convert file/paths to Elixir ModuleName"
  alias Transmogrify.Character

  @doc """
  Convert a `path/module_name/string` to Elixir's `Path.ModuleName.String`,
  using the following rules similar to PascalCase:

    * first letter is always capitalized
    * ascii alphabetic letters immediately following an underscore are capitalized
    * underscores are removed
    * slashes are converted to dots
    * existing case and other characters are preserved in all other cases

  ```elixir
  iex> convert("MODULENAME")
  "MODULENAME"
  iex> convert("_module___name__")
  "ModuleName"
  iex> convert("module_name")
  "ModuleName"
  iex> convert("module_name")
  "ModuleName"
  iex> convert("module_name")
  "ModuleName"
  iex> convert("ModuleNAME")
  "ModuleNAME"
  iex> convert("Module_NAME")
  "ModuleNAME"
  iex> convert("ModuleName")
  "ModuleName"
  iex> convert("Module Name")
  "Module Name"
  iex> convert("module/name/here")
  "Module.Name.Here"
  iex> convert("module_9name.here")
  "Module9name.Here"
  iex> convert(Module.Name)
  "Module.Name"
  ```

  note: Original code from `Macro.camelize/1` with minor changes:

  * underscore followed by capital letter is treated the same as lowercase letter
    (the underscore is removed and the letter is capitalized)
  * existing dots are treated the same as slashes (following letter is capitalized)
  """

  @spec convert(String.t()) :: String.t()
  def convert(string)

  def convert(""), do: ""
  def convert(x) when is_atom(x), do: convert(to_string(x))
  def convert("Elixir." <> rest), do: do_convert(rest)
  def convert(<<?_, rest::binary>>), do: convert(rest)
  def convert(<<c1, rest::binary>>), do: <<Character.upper(c1)>> <> do_convert(rest)

  defp do_convert(<<?_, ?_, rest::binary>>), do: do_convert(<<?_, rest::binary>>)

  defp do_convert(<<?., rest::binary>>), do: do_convert(<<?/, rest::binary>>)

  defp do_convert(<<?_, c1, rest::binary>>) when c1 >= ?A and c1 <= ?z,
    do: <<Character.upper(c1)>> <> do_convert(rest)

  # defp do_convert(<<?., c1, rest::binary>>) when c1 >= ?A and c1 <= ?z,
  #   do: <<Character.upper(c1)>> <> do_convert(rest)

  defp do_convert(<<?_, c1, rest::binary>>) when c1 >= ?0 and c1 <= ?9,
    do: <<c1>> <> do_convert(rest)

  defp do_convert(<<?_>>), do: <<>>
  defp do_convert(<<?/, rest::binary>>), do: <<?.>> <> convert(rest)
  defp do_convert(<<c1, rest::binary>>), do: <<c1>> <> do_convert(rest)
  defp do_convert(<<>>), do: <<>>
end
