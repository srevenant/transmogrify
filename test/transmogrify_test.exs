defmodule Transmogrify.Test do
  use ExUnit.Case
  alias Transmogrify.{Camelcase, Pascalcase, Snakecase, Modulename}
  import Transmogrify.Transmogrifier, only: [convert_case: 3, clean_word: 3]

  doctest Transmogrify, import: true
  doctest Transmogrify.Camelcase, import: true
  doctest Transmogrify.Pascalcase, import: true
  doctest Transmogrify.Snakecase, import: true
  doctest Transmogrify.Modulename, import: true
  doctest Transmogrify.Pathname, import: true
  doctest Transmogrify.Transmogrifier, import: true
  doctest Transmogrify.As, import: true

  test "Transmogrifier.convert_case/3" do
    assert convert_case("this_that", :preserve_type, &Camelcase.convert/1) == "thisThat"
    assert convert_case("this_that", :as_atom, &Camelcase.convert/1) == :thisThat
    assert convert_case(:this_that, :preserve_type, &Camelcase.convert/1) == :thisThat
    assert convert_case(:this_that, :as_binary, &Camelcase.convert/1) == "thisThat"
    assert convert_case("this_that", :as_binary, &Camelcase.convert/1) == "thisThat"

    assert convert_case("this_that", :preserve_type, &Pascalcase.convert/1) == "ThisThat"
    assert convert_case("this_that", :as_atom, &Pascalcase.convert/1) == :ThisThat
    assert convert_case(:this_that, :preserve_type, &Pascalcase.convert/1) == :ThisThat
    assert convert_case(:this_that, :as_binary, &Pascalcase.convert/1) == "ThisThat"

    assert convert_case("this_that", :preserve_type, &Modulename.convert/1) == "ThisThat"
    assert convert_case("this_that", :as_atom, &Modulename.convert/1) == :ThisThat
    assert convert_case(:this_that, :preserve_type, &Modulename.convert/1) == :ThisThat
    assert convert_case(:this_that, :as_binary, &Modulename.convert/1) == "ThisThat"

    assert convert_case(:value, :preserve_type, &Snakecase.convert/1) == :value
    assert convert_case(:Value, :preserve_type, &Snakecase.convert/1) == :value
    assert convert_case("vaLUE", :preserve_type, &Snakecase.convert/1) == "va_lue"

    assert convert_case("valueCamelToSnake", :as_atom, &Snakecase.convert/1) ==
             :value_camel_to_snake

    assert convert_case(:"value-dashed", :as_atom, &Snakecase.convert/1) == :value_dashed
    assert convert_case("Value-Dashed", :as_atom, &Snakecase.convert/1) == :value_dashed
    assert convert_case(:thisThat, :as_binary, &Snakecase.convert/1) == "this_that"

    assert convert_case(%{}, :as_atom, &Snakecase.convert/1) == %{}
  end

  test "Transmogrifier.clean_word/3" do
    assert clean_word(:camel, :string, "blah") == "blah"
    assert clean_word(:camel, :semi_atom, ":blah") == :blah
    assert clean_word(:camel, :atom, ":blah") == :blah
    assert clean_word(:camel, :atom, "blah") == :blah
    assert clean_word(:snake, :semi_atom, ":blah") == :blah
    assert clean_word(:module, :module, "Module") == "Module"
    assert clean_word(:module, :string, "Module") == "Module"
    assert clean_word(:module, :semi_atom, ":module") == :Module
    assert clean_word(:module, :atom, ":module") == :Module
    assert clean_word(:module, :atom, "module") == :Module
    assert clean_word(:pascal, :pascal, "Pascal") == "Pascal"
    assert clean_word(:pascal, :string, "Pascal") == "Pascal"
    assert clean_word(:pascal, :semi_atom, ":pascal") == :Pascal
    assert clean_word(:pascal, :atom, ":pascal") == :Pascal
    assert clean_word(:pascal, :atom, "pascal") == :Pascal
  end

  test "keep coveralls happy" do
    assert Transmogrify.transmogrify([]) == []
    assert Transmogrify.camelcase("") == ""
    assert Transmogrify.snakecase("") == ""
    assert Transmogrify.pascalcase("") == ""
    assert Transmogrify.modulename("") == ""
    assert Transmogrify.pathname("") == ""
    assert Transmogrify.transmogrify({nil}) == {nil}
  end
end
