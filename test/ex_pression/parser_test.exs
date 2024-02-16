defmodule ExPression.ParserTest do
  use ExUnit.Case

  alias ExPression.Parser

  describe "#happy_path" do
    test "string" do
      assert {:ok, "string"} == Parser.parse(~s("string"))
    end

    test "function call" do
      assert {:ok, {:fun_call, ["f", {:var, ["x"]}]}} == Parser.parse("f(x)")
    end

    test "field access" do
      assert {:ok, {:field_access, [{:var, ["x"]}, "field_name"]}} ==
               Parser.parse("x.field_name")
    end

    test "nested field access" do
      assert {:ok,
              {:field_access, [{:field_access, [{:var, ["x"]}, "field_name"]}, "another_field"]}} ==
               Parser.parse("x.field_name.another_field")
    end

    test "2 args function call: int and string" do
      assert {:ok, {:fun_call, ["my_function", 1, "some"]}} ==
               Parser.parse("my_function(1, \"some\")")
    end

    test "float number" do
      assert {:ok, {:fun_call, ["str", 1.5]}} == Parser.parse("str(1.5)")
    end

    test "sum of to numbers" do
      assert {:ok, {:+, [1, 0.5]}} == Parser.parse("1 + 0.5")
    end

    test "ops order" do
      assert {:ok, {:+, [2, {:+, [{:*, [3, 4]}, 5]}]}} == Parser.parse("2+3*4+5")
    end

    test "bool 2" do
      assert {:ok, {:and, [true, false]}} == Parser.parse("true and false")
    end

    test "bool 3" do
      assert {:ok, {:and, [true, false]}} == Parser.parse("True and False")
    end

    test "access 1" do
      assert {:ok, {:access, [{:array, [1, 2]}, 0]}} == Parser.parse("[1, 2][0]")
    end

    test "access 2" do
      assert {:ok, {:access, [{:access, [{:array, [{:array, [1, 2]}, 3]}, 0]}, 0]}} ==
               Parser.parse("[[1, 2], 3][0][0]")
    end

    test "empty obj" do
      assert {:ok, {:obj, []}} == Parser.parse("{}")
    end

    test "obj with 1 entry" do
      assert {:ok, {:obj, [{"a", "b"}]}} == Parser.parse(~s({"a": "b"}))
    end

    test "complex obj" do
      assert {:ok,
              {:obj,
               [{"c", {:obj, [{"d", "e"}]}}, {"b", {:array, [obj: []]}}, {"a", {:+, [1, 2]}}]}} ==
               Parser.parse(~s({"a": 1 + 2, "b": [{}], "c": {"d": "e"}}))
    end
  end

  describe "#sad_path" do
    test "invalid expression 2" do
      assert {:error, {:parsing_error, "}"}} == Parser.parse(~s({}}))
    end

    test "invalid expression 3" do
      assert assert {:error, {:parsing_error, " +"}} == Parser.parse(~s(1 +))
    end
  end
end
