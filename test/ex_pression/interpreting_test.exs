defmodule ExPression.InterpretingTest do
  use ExUnit.Case
  alias ExPression.Interpreting
  alias ExPression.Parsing

  defmodule TestModule do
    def create_obj do
      %{"a" => %{"b" => "c"}}
    end

    def concat(a, b, c) do
      "#{a}#{b}#{c}"
    end
  end

  describe "#happy_path" do
    test "function call" do
      {:ok, ast} = Parsing.parse("div(5, 2)")
      assert {:ok, 2} == Interpreting.eval(ast, %{}, Kernel)
    end

    test "function call: 3 arguments" do
      {:ok, ast} = Parsing.parse("concat(1, 2, 3)")
      assert {:ok, "123"} == Interpreting.eval(ast, %{}, TestModule)
    end

    test "function call: complex args" do
      {:ok, ast} = Parsing.parse("concat(concat(1, 2, 3), concat(4, 5, 6), concat(7, 8, 9))")
      assert {:ok, "123456789"} == Interpreting.eval(ast, %{}, TestModule)
    end

    test "function call with variable" do
      {:ok, ast} = Parsing.parse("div(5, x)")
      assert {:ok, 2} == Interpreting.eval(ast, %{"x" => 2}, Kernel)
    end

    test "function call with no vars + field access" do
      {:ok, ast} = Parsing.parse("create_obj().a.b")
      assert {:ok, "c"} == Interpreting.eval(ast, %{}, TestModule)
    end

    test "function from standard library" do
      {:ok, ast} = Parsing.parse("str(1)")
      assert {:ok, "1"} == Interpreting.eval(ast)
    end

    test "sum of two numbers" do
      {:ok, ast} = Parsing.parse("1 + 0.5")
      assert {:ok, 1.5} == Interpreting.eval(ast)
    end

    test "minus number" do
      {:ok, ast} = Parsing.parse("1 - 0.5")
      assert {:ok, 0.5} == Interpreting.eval(ast)
    end

    test "ops order" do
      {:ok, ast} = Parsing.parse("2+3*4+5")
      assert {:ok, 19} == Interpreting.eval(ast)
    end

    test "parenthesis" do
      {:ok, ast} = Parsing.parse("(2+3)*(4+5)")
      assert {:ok, 45} == Interpreting.eval(ast)
    end

    test "bool 1" do
      {:ok, ast} = Parsing.parse("true or false")
      assert {:ok, true} == Interpreting.eval(ast)
    end

    test "bool 2" do
      {:ok, ast} = Parsing.parse("true and false")
      assert {:ok, false} == Interpreting.eval(ast)
    end

    test "bool 3" do
      {:ok, ast} = Parsing.parse("not false")
      assert {:ok, true} == Interpreting.eval(ast)
    end

    test "bool 4" do
      {:ok, ast} = Parsing.parse("1 == 1")
      assert {:ok, true} == Interpreting.eval(ast)
    end

    test "bool 5" do
      {:ok, ast} = Parsing.parse("1 != 1")
      assert {:ok, false} == Interpreting.eval(ast)
    end

    test "array 1" do
      {:ok, ast} = Parsing.parse("[1, 2, 3]")
      assert {:ok, [1, 2, 3]} == Interpreting.eval(ast)
    end

    test "array 2" do
      {:ok, ast} = Parsing.parse("[1 - 2, 2, 3]")
      assert {:ok, [-1, 2, 3]} == Interpreting.eval(ast)
    end

    test "array 3" do
      {:ok, ast} = Parsing.parse("[1 - 2, str(2), [4, 5]]")
      assert {:ok, [-1, "2", [4, 5]]} == Interpreting.eval(ast)
    end

    test "obj 1" do
      {:ok, ast} = Parsing.parse("{}")
      assert {:ok, %{}} == Interpreting.eval(ast)
    end

    test "obj 2" do
      {:ok, ast} = Parsing.parse(~s({"a": "b"}))
      assert {:ok, %{"a" => "b"}} == Interpreting.eval(ast)
    end

    test "obj 3" do
      {:ok, ast} = Parsing.parse(~s({"a": 1 + 2, "b": [{}], "c": {"d": "e"}}))
      assert {:ok, %{"a" => 3, "b" => [%{}], "c" => %{"d" => "e"}}} == Interpreting.eval(ast)
    end

    test "access 1" do
      {:ok, ast} = Parsing.parse("[1, 2][0]")
      assert {:ok, 1} == Interpreting.eval(ast)
    end

    test "access 2" do
      {:ok, ast} = Parsing.parse("[[1, 2], 3][0][1]")
      assert {:ok, 2} == Interpreting.eval(ast)
    end

    test "access 3" do
      {:ok, ast} = Parsing.parse(~s({"a": "b", "c": "d"}["a"]))
      assert {:ok, "b"} == Interpreting.eval(ast)
    end

    test "access 4" do
      {:ok, ast} = Parsing.parse(~s({"a": "b", "c": "d"}[x]))
      assert {:ok, "d"} == Interpreting.eval(ast, %{"x" => "c"})
    end
  end
end
