defmodule Transmogrify.Transmogrifier do
  @moduledoc "Convert keys and values in maps and lists of maps"
  alias Transmogrify.{Camelcase, Modulename, Pascalcase, Snakecase}

  @default_opts %{
    key_convert: nil,
    value_convert: nil,
    key_case: nil,
    value_case: nil,
    deep: true,
    clean_nil: false,
    clean_empty_list: false,
    clean_empty_string: false
  }

  @doc """
  Primary function for transmogrifying maps and lists of data that may include maps.

  # Options

  * `key_convert:` — convert types on keys in maps
    - `:none` | `nil` (default) — do not convert key types
    - `:atom` — make all binary/string keys into atoms
    - `:semi_atom` - make binary/string keys starting with `:` into atoms
    - `:string` — make all keys into binary/strings
  * `value_convert:` — convert types on values in maps
    - `:none` | `nil` (default) — do not convert key types
    - `:atom` — make all binary/string keys into atoms
    - `:semi_atom` - make binary/string keys starting with `:` into atoms
    - `:string` — make all keys into binary/strings
  * `key_case:` — convert case on keys in maps
    - `nil` (default) — do not alter case
    - `:snake` — convert keys into `snake_case`
    - `:camel` — convert keys into `camelCase`
    - `:pascal` — convert keys into `PascalCase`
  * `value_case:` — convert case on values in maps
    - `nil` (default) — do not alter case
    - `:snake` — convert keys into `snake_case`
    - `:camel` — convert keys into `camelCase`
    - `:pascal` — convert keys into `PascalCase`
  * `deep:` `false` | `true` (default) — recurse full depth of maps/lists or not
  * `clean_nil:` `false` (default) | `true` — remove list/map entry if value is nil
  * `clean_empty_list:` `false` (default) | `true`  — remove list/map entry if zero-length list
  * `clean_empty_string:` `false` (default) | `true` — remove list/map entry if zero-length string

  # Examples

  ```elixir
  iex> transmogrify(%{"Tardis" => %{"Key" => 10}, "is" => 2, "The.Color" => "blue"}, key_convert: :atom)
  %{Tardis: %{Key: 10}, is: 2, "The.Color": "blue"}

  iex> transmogrify(%{"Tardis" => %{"Key" => 10}, "is" => 2, "The.Color" => "blue"}, key_convert: :atom, deep: false)
  %{Tardis: %{"Key" => 10}, is: 2, "The.Color": "blue"}

  iex> transmogrify(%{"Sonic" => 1, "ScrewDriver" => ":thIrd"}, key_convert: :atom, key_case: :snake, value_convert: :atom, value_case: :snake)
  %{sonic: 1, screw_driver: :th_ird}

  iex> transmogrify([%{ :thisCase => 1, "thatCase" => 2 }], key_case: :snake, key_convert: :none)
  [%{ :this_case => 1, "that_case" => 2}]

  iex> transmogrify([%{ :this_case => 1, "that_case" => 2 }], key_case: :camel, key_convert: :none)
  [%{ :thisCase => 1, "thatCase" => 2}]

  iex> transmogrify([
  ...>     %{a: 1,
  ...>       b: ["red", nil, "", [], ":green"],
  ...>       c: [], d: nil, e: "",
  ...>       f: %{TarVis: "blue"},
  ...>       j: ":sonic"}
  ...>   ],
  ...>   key_case: :snake, key_convert: :atom,
  ...>   value_case: :snake, value_convert: :none,
  ...>   clean_nil: true, clean_empty_list: true, clean_empty_string: true
  ...> )
  [%{a: 1, b: ["red", ":green"], f: %{tar_vis: "blue"}, j: ":sonic"}]

  iex> transmogrify([
  ...>     %{a: 1,
  ...>       b: ["red", nil, "", [], ":green"],
  ...>       c: [], d: nil, e: "",
  ...>       f: %{TarDis: "blue"},
  ...>       j: ":sonic"}, 10
  ...>   ],
  ...>   value_convert: :semi_atom
  ...> )
  [%{ a: 1, b: ["red", nil, "", [], :green], f: %{TarDis: "blue"}, j: :sonic, c: [], d: nil, e: ""}, 10]

  iex> transmogrify(%{key1: 10, keyTwo: "foo"}, key_convert: :string)
  %{"key1" => 10, "keyTwo" => "foo"}

  iex> transmogrify(%{key1: 10, keyTwo: "foo"}, key_convert: :string, key_case: :snake)
  %{"key1" => 10, "key_two" => "foo"}
  ```
  """

  # TODO: Benchmarks & convert opts to use Keyword.validate w/out dict
  def transmogrify(map, opts) when is_list(opts), do: transmogrify(map, Map.new(opts))

  def transmogrify(map, opts) when is_map(opts),
    do: clean_data(map, Map.merge(@default_opts, opts))

  defp clean_data(map, opts) when is_map(map) and not is_struct(map) do
    Enum.reduce(map, [], fn {k, v}, a -> clean_key_value(k, v, a, opts) end) |> Map.new()
  end

  defp clean_data(list, opts) when is_list(list) do
    Enum.reduce(list, [], fn value, accum -> clean_value(value, accum, opts) end)
    |> Enum.reverse()
  end

  defp clean_data(data, _), do: data

  ##############################################################################
  defp clean_key_value(_, "", accum, %{clean_empty_string: true}), do: accum
  defp clean_key_value(_, [], accum, %{clean_empty_list: true}), do: accum
  defp clean_key_value(_, nil, accum, %{clean_nil: true}), do: accum

  defp clean_key_value(key, value, accum, %{deep: true} = opts)
       when is_map(value) or is_list(value),
       do: [{clean_word(opts.key_case, opts.key_convert, key), clean_data(value, opts)} | accum]

  defp clean_key_value(key, value, accum, opts),
    do: [
      {clean_word(opts.key_case, opts.key_convert, key),
       clean_word(opts.value_case, opts.value_convert, value)}
      | accum
    ]

  ##############################################################################
  defp clean_value("", accum, %{clean_empty_string: true}), do: accum
  defp clean_value([], accum, %{clean_empty_list: true}), do: accum
  defp clean_value(nil, accum, %{clean_nil: true}), do: accum

  defp clean_value(value, accum, opts)
       when (is_map(value) and not is_struct(value)) or is_list(value),
       do: [clean_data(value, opts) | accum]

  defp clean_value(value, accum, opts),
    do: [clean_word(opts.value_case, opts.value_convert, value) | accum]

  ##############################################################################
  @doc false
  def clean_word(:snake, :atom, <<?:, word::binary>>),
    do: convert_case(word, :as_atom, &Snakecase.convert/1)

  def clean_word(:snake, :atom, word), do: convert_case(word, :as_atom, &Snakecase.convert/1)

  def clean_word(:snake, :semi_atom, <<?:, word::binary>>),
    do: convert_case(word, :as_atom, &Snakecase.convert/1)

  def clean_word(:snake, :string, word), do: convert_case(word, :as_binary, &Snakecase.convert/1)
  def clean_word(:snake, _, word), do: convert_case(word, :preserve_type, &Snakecase.convert/1)

  def clean_word(:camel, :atom, <<?:, word::binary>>),
    do: convert_case(word, :as_atom, &Camelcase.convert/1)

  def clean_word(:camel, :atom, word), do: convert_case(word, :as_atom, &Camelcase.convert/1)

  def clean_word(:camel, :semi_atom, <<?:, word::binary>>),
    do: convert_case(word, :as_atom, &Camelcase.convert/1)

  def clean_word(:camel, :string, word), do: convert_case(word, :as_binary, &Camelcase.convert/1)
  def clean_word(:camel, _, word), do: convert_case(word, :preserve_type, &Camelcase.convert/1)

  def clean_word(:pascal, :atom, <<?:, word::binary>>),
    do: convert_case(word, :as_atom, &Pascalcase.convert/1)

  def clean_word(:pascal, :atom, word), do: convert_case(word, :as_atom, &Pascalcase.convert/1)

  def clean_word(:pascal, :semi_atom, <<?:, word::binary>>),
    do: convert_case(word, :as_atom, &Pascalcase.convert/1)

  def clean_word(:pascal, :string, word),
    do: convert_case(word, :as_binary, &Pascalcase.convert/1)

  def clean_word(:pascal, _, word), do: convert_case(word, :preserve_type, &Pascalcase.convert/1)

  def clean_word(:module, :atom, <<?:, word::binary>>),
    do: convert_case(word, :as_atom, &Modulename.convert/1)

  def clean_word(:module, :atom, word), do: convert_case(word, :as_atom, &Modulename.convert/1)

  def clean_word(:module, :semi_atom, <<?:, word::binary>>),
    do: convert_case(word, :as_atom, &Modulename.convert/1)

  def clean_word(:module, :string, word),
    do: convert_case(word, :as_binary, &Modulename.convert/1)

  def clean_word(:module, _, word), do: convert_case(word, :preserve_type, &Modulename.convert/1)

  def clean_word(_, :atom, <<word::binary>>), do: String.to_atom(word)
  def clean_word(_, :semi_atom, <<?:, word::binary>>), do: String.to_atom(word)
  def clean_word(_, :string, word) when is_atom(word), do: "#{word}"
  def clean_word(_, _, word), do: word

  #############################################################################
  @doc false
  def convert_case(word, :as_binary, convertor) when is_binary(word),
    do: convertor.(word)

  def convert_case(word, :preserve_type, convertor) when is_binary(word),
    do: convertor.(word)

  def convert_case(word, :as_atom, convertor) when is_binary(word),
    do: convertor.(word) |> String.to_atom()

  def convert_case(word, :as_binary, convertor) when is_atom(word),
    do: convertor.(to_string(word))

  def convert_case(word, _, convertor) when is_atom(word),
    do: convertor.(to_string(word)) |> String.to_atom()

  def convert_case(word, _, _), do: word
end
