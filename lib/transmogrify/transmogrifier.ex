defmodule Transmogrify.Transmogrifier do
  @moduledoc "Convert keys and values in maps and lists of maps"
  alias Transmogrify.{Camelcase, Modulename, Pascalcase, Snakecase}

  @default_opts %{
    key_convert: nil,
    value_convert: nil,
    key_case: nil,
    value_case: nil,
    deep: true,
    no_nil_value: false,
    no_0list_value: false,
    no_0map_value: false,
    no_0string_value: false,
    no_nil_elem: false,
    no_0list_elem: false,
    no_0map_elem: false,
    no_0string_elem: false
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
  * `no_{what}_{from}` — remove the specified {what} from the {from}, where
    {what} is nil, or `0` and list, map, or string; and {from} is either value
    (for maps) or elem (for lists).

    - `no_nil_value:` `false` (default) | `true` — remove key/value from map if value is nil
    - `no_0list_value:` `false` (default) | `true`  — remove key/value from map if value is a zero-length list
    - `no_0map_value:` `false` (default) | `true`  — remove key/value from a map if value is an empty map
    - `no_0string_value:` `false` (default) | `true` — remove key/value from a map if value is a zero-length string
    - `no_nil_elem:` `false` (default) | `true` — remove element from list if elem is nil
    - `no_0list_elem:` `false` (default) | `true`  — remove element from list if elem is a zero-length list
    - `no_0map_elem:` `false` (default) | `true`  — remove element from a list if elem is an empty map
    - `no_0string_elem:` `false` (default) | `true` — remove element from a list if elem is a zero-length string

  # Examples

  ```elixir
  iex> transmogrify(%{"Tardis" => %{"Key1" => 10}, "is" => 2, "The.Color" => "blue"}, key_convert: :atom)
  %{Tardis: %{Key1: 10}, is: 2, "The.Color": "blue"}

  iex> transmogrify(%{"Tardis" => %{"Key2" => 10}, "is" => 2, "The.Color" => "blue"}, key_convert: :atom, deep: false)
  %{Tardis: %{"Key2" => 10}, is: 2, "The.Color": "blue"}

  iex> transmogrify(%{"Sonic" => 1, "ScrewDriver" => ":thIrd"}, key_convert: :atom, key_case: :snake, value_convert: :atom, value_case: :snake)
  %{sonic: 1, screw_driver: :th_ird}

  iex> transmogrify([%{ :thisCase => 1, "thatCase" => 2 }], key_case: :snake, key_convert: :none)
  [%{ :this_case => 1, "that_case" => 2}]

  iex> transmogrify([%{ :this_case => 1, "that_case" => 2 }], key_case: :camel, key_convert: :none)
  [%{ :thisCase => 1, "thatCase" => 2}]

  iex> transmogrify([
  ...>     %{t1a: 1,
  ...>       t1b: ["red", nil, "", [], ":green"],
  ...>       t1c: [%{}], t1d: nil, t1e: "",
  ...>       t1f: %{TarVis: "blue"},
  ...>       t1j: ":sonic"}
  ...>   ],
  ...>   key_case: :snake, key_convert: :atom,
  ...>   value_case: :snake, value_convert: :none,
  ...>   no_nil_value: true, no_0list_value: true, no_0string_value: true, no_0map_value: true,
  ...>   no_nil_elem: true, no_0list_elem: true, no_0string_elem: true, no_0map_elem: true
  ...> )
  [%{t1a: 1, t1b: ["red", ":green"], t1f: %{tar_vis: "blue"}, t1j: ":sonic"}]

  iex> transmogrify([
  ...>     %{t2a: 1,
  ...>       t2b: ["red", nil, "", [], ":green"],
  ...>       t2c: [], t2d: nil, t2e: "",
  ...>       t2f: %{TarDis: "blue"},
  ...>       t2j: ":sonic"}, 10
  ...>   ],
  ...>   value_convert: :semi_atom
  ...> )
  [%{ t2a: 1, t2b: ["red", nil, "", [], :green], t2f: %{TarDis: "blue"}, t2j: :sonic, t2c: [], t2d: nil, t2e: ""}, 10]

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

  ##############################################################################
  @doc """
  Shortcut to clean out nulls, empty lists, and empty maps from a map

  iex> prune(%{sub: %{}, keep: %{this: 1}, all: %{more: %{deeper: []}}})
  %{keep: %{this: 1}}
  """
  def prune(d) when is_map(d),
    do:
      transmogrify(d, %{no_nil_value: true, no_0list_value: true, no_0map_value: true, deep: true})

  ##############################################################################
  defp clean_data(map, opts) when is_map(map) and not is_struct(map),
    do: Enum.reduce(map, [], fn {k, v}, a -> clean_map_value(k, v, a, opts) end) |> Map.new()

  defp clean_data(list, opts) when is_list(list),
    do: Enum.reduce(list, [], fn v, a -> clean_elem(v, a, opts) end) |> Enum.reverse()

  defp clean_data(data, _), do: data

  ##############################################################################

  defp clean_map_value(key, value, acc, %{deep: true} = opts)
       when is_list(value) or is_map(value),
       do: add_map_value(key, clean_data(value, opts), acc, opts)

  defp clean_map_value(key, value, acc, opts),
    do: add_map_value(key, clean_word(opts.value_case, opts.value_convert, value), acc, opts)

  defp add_map_value(_, "", a, %{no_0string_value: true}), do: a
  defp add_map_value(_, [], a, %{no_0list_value: true}), do: a
  defp add_map_value(_, nil, a, %{no_nil_value: true}), do: a
  defp add_map_value(_, m, a, %{no_0map_value: true}) when is_map(m) and map_size(m) == 0, do: a
  defp add_map_value(k, v, a, opts), do: [{clean_word(opts.key_case, opts.key_convert, k), v} | a]

  ##############################################################################
  defp clean_elem("", accum, %{no_0string_elem: true}), do: accum
  defp clean_elem([], accum, %{no_0list_elem: true}), do: accum
  defp clean_elem(nil, accum, %{no_nil_elem: true}), do: accum
  defp clean_elem(m, accum, %{no_0map_elem: true}) when is_map(m) and map_size(m) == 0, do: accum

  defp clean_elem(value, accum, opts)
       when (is_map(value) and not is_struct(value)) or is_list(value),
       do: [clean_data(value, opts) | accum]

  defp clean_elem(value, accum, opts),
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

  def convert_case(word, _, convertor) when is_atom(word) and not is_nil(word),
    do: convertor.(to_string(word)) |> String.to_atom()

  def convert_case(word, _, _), do: word
end
