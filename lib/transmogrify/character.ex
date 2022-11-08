defmodule Transmogrify.Character do
  @moduledoc false

  def upper(char) when char >= ?a and char <= ?z, do: char - 32
  def upper(char), do: char

  def lower(char) when char >= ?A and char <= ?Z, do: char + 32
  def lower(char), do: char
end
