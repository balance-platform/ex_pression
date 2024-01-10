defmodule ExPression.ParsingTest do
  use ExUnit.Case

  alias ExPression.Parsing

  describe "#happy_path" do
    test "string" do
      assert {:ok, "string"} == Parsing.parse(~s("string"))
    end

    test "function call" do
      assert {:ok, {:fun_call, ["f", {:var, ["x"]}]}} == Parsing.parse("f(x)")
    end

    test "field access" do
      assert {:ok, {:field_access, [{:var, ["x"]}, "field_name"]}} ==
               Parsing.parse("x.field_name")
    end

    test "nested field access" do
      assert {:ok,
              {:field_access, [{:field_access, [{:var, ["x"]}, "field_name"]}, "another_field"]}} ==
               Parsing.parse("x.field_name.another_field")
    end

    test "2 args function call: int and string" do
      assert {:ok, {:fun_call, ["my_function", 1, "some"]}} ==
               Parsing.parse("my_function(1, \"some\")")
    end

    test "float number" do
      assert {:ok, {:fun_call, ["str", 1.5]}} == Parsing.parse("str(1.5)")
    end

    test "sum of to numbers" do
      assert {:ok, {:+, [1, 0.5]}} == Parsing.parse("1 + 0.5")
    end

    test "ops order" do
      assert {:ok, {:+, [2, {:+, [{:*, [3, 4]}, 5]}]}} == Parsing.parse("2+3*4+5")
    end

    test "bool 2" do
      assert {:ok, {:and, [true, false]}} == Parsing.parse("true and false")
    end

    test "access 1" do
      assert {:ok, {:access, [{:array, [1, 2]}, 0]}} == Parsing.parse("[1, 2][0]")
    end

    test "access 2" do
      assert {:ok, {:access, [{:access, [{:array, [{:array, [1, 2]}, 3]}, 0]}, 0]}} ==
               Parsing.parse("[[1, 2], 3][0][0]")
    end

    test "empty obj" do
      assert {:ok, {:obj, []}} == Parsing.parse("{}")
    end

    test "obj with 1 entry" do
      assert {:ok, {:obj, [{"a", "b"}]}} == Parsing.parse(~s({"a": "b"}))
    end

    test "complex obj" do
      assert {:ok,
              {:obj,
               [{"c", {:obj, [{"d", "e"}]}}, {"b", {:array, [obj: []]}}, {"a", {:+, [1, 2]}}]}} ==
               Parsing.parse(~s({"a": 1 + 2, "b": [{}], "c": {"d": "e"}}))
    end
  end

  describe "#sad_path" do
    test "invalid expression 2" do
      assert {:error, {:parsing_error, "}"}} == Parsing.parse(~s({}}))
    end

    test "invalid expression 3" do
      assert assert {:error, {:parsing_error, " +"}} == Parsing.parse(~s(1 +))
    end
  end
end
