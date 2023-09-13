defmodule Transmogrify.As do
  @moduledoc """
  Polymorphic data transforms — accepts many input forms and tries to put
  them into the expected form.

  Easiest use:
  ```elixir
  iex> import Transmogrify.As
  iex> as_int("10")
  {:ok, 10}
  iex> as_int!(10.0)
  10
  ```
  """

  @invalid_error :error

  ##############################################################################
  @doc ~S"""
  Accept strings, floats, and ints, and assure the result is either
  an int (parsed if necessary) or an error.

  ```elixir
  iex> as_int(10)
  {:ok, 10}
  iex> as_int(10.0)
  {:ok, 10}
  iex> as_int("10")
  {:ok, 10}
  iex> as_int("tardis")
  :error
  iex> as_int(:foo)
  :error
  ```
  """
  def as_int(arg) when is_integer(arg), do: {:ok, arg}
  def as_int(arg) when is_float(arg), do: {:ok, Kernel.trunc(arg)}

  def as_int(arg) when is_binary(arg) do
    {:ok, String.to_integer(arg)}
  rescue
    ArgumentError -> @invalid_error
  end

  def as_int(_), do: @invalid_error

  @doc ~S"""
  Accept strings, floats, and ints, and assure the result is either
  an int (parsed if necessary) or return the specified default (which
  is `0` if unspecified)

  ```elixir
  iex> as_int!(10)
  10
  iex> as_int!(10.0)
  10
  iex> as_int!("10")
  10
  iex> as_int!("tardis", 9)
  9
  iex> as_int!(:foo, 8)
  8
  ```
  """
  def as_int!(arg, default \\ 0) do
    case as_int(arg) do
      {:ok, x} -> x
      @invalid_error -> default
    end
  end

  ##############################################################################
  @doc ~S"""
  Accept strings, floats, and ints, and assure the result is either
  an float (parsed if necessary) or an error.

  ```elixir
  iex> as_float(10.52)
  {:ok, 10.52}
  iex> as_float(10)
  {:ok, 10.0}
  iex> as_float("10.5")
  {:ok, 10.5}
  iex> as_float(".55")
  {:ok, 0.55}
  iex> as_float(".#")
  :error
  iex> as_float("tardis")
  :error
  iex> as_float({})
  :error
  ```
  """
  def as_float(data) when is_float(data), do: {:ok, data}
  def as_float(data) when is_integer(data), do: {:ok, data / 1}

  def as_float(<<?., data::binary>>) do
    {:ok, String.to_float("0.#{data}")}
  rescue
    ArgumentError -> @invalid_error
  end

  def as_float(data) when is_binary(data) do
    {:ok, String.to_float(data)}
  rescue
    ArgumentError -> @invalid_error
  end

  def as_float(_), do: @invalid_error

  @doc ~S"""
  Accept strings, floats, and ints, and assure the result is either
  an float (parsed if necessary) or return the specified default (which
  is `0.0` if unspecified)

  ```elixir
  iex> as_float!(10.0)
  10.0
  iex> as_float!(10)
  10.0
  iex> as_float!("10.0")
  10.0
  iex> as_float!("tardis", 9.0)
  9.0
  ```
  """
  def as_float!(arg, default \\ 0.0) do
    case as_float(arg) do
      {:ok, num} -> num
      @invalid_error -> default
    end
  end

  ##############################################################################
  @doc ~S"""
  Accept strings, floats, and ints, and assure the result is either
  a float or int (parsed if necessary) or an error.

  ```elixir
  iex> as_number(10.52)
  {:ok, 10.52}
  iex> as_number(10)
  {:ok, 10}
  iex> as_number("10.5")
  {:ok, 10.5}
  iex> as_number(".55")
  {:ok, 0.55}
  iex> as_number(".#")
  :error
  iex> as_number("tardis")
  :error
  iex> as_number({})
  :error
  ```
  """
  def as_number(arg) when is_number(arg), do: {:ok, arg}

  def as_number(<<?., data::binary>>) do
    {:ok, String.to_float("0.#{data}")}
  rescue
    ArgumentError -> @invalid_error
  end

  # TODO: benchmark which is faster: Scanning for a '.' first, or catching
  # the exception and handling
  def as_number(data) when is_binary(data) do
    {:ok, String.to_float(data)}
  rescue
    ArgumentError -> as_int(data)
  end

  def as_number(_), do: @invalid_error

  @doc ~S"""
  Accept strings, floats, and ints, and assure the result is either
  a float or int (parsed if necessary) or return the specified default (which
  is `0` if unspecified)

  ```elixir
  iex> as_number!(10.0)
  10.0
  iex> as_number!(10)
  10
  iex> as_number!("10.0")
  10.0
  iex> as_number!("tardis", 9.0)
  9.0
  ```
  """
  def as_number!(arg, default \\ 0.0) do
    case as_number(arg) do
      {:ok, num} -> num
      @invalid_error -> default
    end
  end

  ##############################################################################
  @doc """
  Accept various data forms and assures they are atoms.

  WARNING: Make sure inputs being called are not using user-submitted data;
  or this may exhaust the atoms table.

  ```elixir
  iex> as_atom("long ugly thing prolly")
  {:ok, :"long ugly thing prolly"}
  iex> as_atom("as_atom")
  {:ok, :as_atom}
  iex> as_atom(:atom)
  {:ok, :atom}
  iex> as_atom(["as_atom", "another"])
  {:ok, [:as_atom, :another]}
  iex> as_atom('test')
  {:ok, :test}
  iex> as_atom(:atom)
  {:ok, :atom}
  ```
  """
  def as_atom(key) when is_atom(key), do: {:ok, key}
  def as_atom(str) when is_binary(str), do: {:ok, String.to_atom(str)}
  # if first elem is an int, assume charlist...
  def as_atom([x | _] = list) when is_integer(x), do: as_atom(to_string(list))
  def as_atom(list) when is_list(list), do: {:ok, Enum.map(list, &as_atom!/1)}
  def as_atom(_), do: @invalid_error

  @doc """
  Accept various data forms and assures they are atoms.

  WARNING: Make sure inputs being called are not using user-submitted data;
  or this may exhaust the atoms table.

  ```elixir
  iex> as_atom!("long ugly thing prolly")
  :"long ugly thing prolly"
  iex> as_atom!("as_atom")
  :as_atom
  iex> as_atom!(:atom)
  :atom
  iex> as_atom!(["as_atom", "another"])
  [:as_atom, :another]
  iex> as_atom!('test')
  :test
  iex> as_atom!(:atom)
  :atom
  iex> as_atom!({:oops})
  ** (ArgumentError) argument error
  ```
  """
  def as_atom!(val) do
    case as_atom(val) do
      {:ok, val} -> val
      @invalid_error -> raise ArgumentError
    end
  end

  ##############################################################################
  @doc """
  Accept various data forms and assures they are atoms (from the existing
  atoms table). See String.to_existing_atom/1 for more details.

  ```elixir
  iex> as_existing_atom("long ugly thing prolly")
  {:ok, :"long ugly thing prolly"}
  iex> as_existing_atom("non_existing_atom")
  :error
  iex> as_existing_atom("as_existing_atom")
  {:ok, :as_existing_atom}
  iex> as_existing_atom(:atom)
  {:ok, :atom}
  iex> as_existing_atom(["as_existing_atom", "another"])
  {:ok, [:as_existing_atom, :another]}
  iex> as_existing_atom(:atom)
  {:ok, :atom}
  iex> as_existing_atom('test')
  {:ok, :test}
  ```
  """
  def as_existing_atom(key) when is_atom(key), do: {:ok, key}

  def as_existing_atom(str) when is_binary(str) do
    {:ok, String.to_existing_atom(str)}
  rescue
    ArgumentError -> @invalid_error
  end

  # if first elem is an int, assume charlist...
  def as_existing_atom([x | _] = list) when is_integer(x), do: as_existing_atom(to_string(list))
  def as_existing_atom(list) when is_list(list), do: {:ok, Enum.map(list, &as_existing_atom!/1)}
  def as_existing_atom(_), do: @invalid_error

  @doc """
  Accept various data forms and assures they are atoms.

  WARNING: Make sure inputs being called are not using user-submitted data;
  or this may exhaust the atoms table.

  ```elixir
  iex> as_existing_atom!("long ugly thing prolly")
  :"long ugly thing prolly"
  iex> as_existing_atom!("as_existing_atom")
  :as_existing_atom
  iex> as_existing_atom!(:atom)
  :atom
  iex> as_existing_atom!(["as_existing_atom", "another"])
  [:as_existing_atom, :another]
  iex> as_existing_atom!(:atom)
  :atom

  iex> as_existing_atom!({:oops})
  ** (ArgumentError) argument error

  iex> as_existing_atom!("non_existing_atom")
  ** (ArgumentError) argument error
  ```
  """
  def as_existing_atom!(val) do
    case as_existing_atom(val) do
      {:ok, val} -> val
      @invalid_error -> raise ArgumentError
    end
  end

  @doc """
  Accept atom or string.
  If string, run through snakecase and convert to atom.
  If atom, assume this is already done.

  iex> as_key("thiskey")
  :thiskey
  iex> as_key("this key")
  :"this key"
  iex> as_key(:thisKey)
  :thisKey
  iex> as_key(:this_key)
  :this_key
  """
  def as_key(key) when is_binary(key), do: Transmogrify.snakecase(key) |> String.to_atom()
  def as_key(key) when is_atom(key), do: key

  @doc """

  iex> as_kvstr(%{a: "b", c: "10", d: "longer with space", x: :c.pid(0, 999, 999), y: Module, z: nil})
  "c=10 a=b d=\\"longer with space\\" y=Module x=<0.999.999> z="
  """
  def as_kvstr(map) do
    Enum.map_join(map, " ", fn {k, v} ->
      [any_to_string(k), "=", any_to_string(v)]
    end)
  end

  defp json_safe_string(str) when is_binary(str) do
    if String.contains?(str, " ") or String.contains?(str, "\"") do
      "#{inspect(str)}"
    else
      to_string(str)
    end
  end

  # TODO:  how much of this is still needed today?
  defp any_to_string(pid) when is_pid(pid) do
    :erlang.pid_to_list(pid)
    |> to_string()
    |> json_safe_string
  end

  defp any_to_string(ref) when is_reference(ref) do
    ~c"#Ref" ++ rest = :erlang.ref_to_list(ref)

    to_string(rest)
    |> json_safe_string
  end

  defp any_to_string(str) when is_binary(str) do
    json_safe_string(str)
  end

  defp any_to_string(atom) when is_atom(atom) do
    case Atom.to_string(atom) do
      "Elixir." <> rest -> rest
      "nil" -> ""
      binary -> binary
    end
    |> json_safe_string
  end

  defp any_to_string(other) do
    any_to_string(Kernel.inspect(other))
  end
end
