defmodule ExPression.InterpreterTest do
  use ExUnit.Case
  alias ExPression.Interpreter
  alias ExPression.Parser

  defmodule TestModule do
    def create_obj do
      %{"a" => %{"b" => "c"}}
    end

    def concat(a, b, c) do
      "#{a}#{b}#{c}"
    end

    def check_is_true(value) do
      value == true
    end
  end

  describe "#deep inside" do
    defmodule ObjWithStruct do
      defstruct [:field]

      def some_result do
        %{"key" => %__MODULE__{field: "Hello world"}}
      end

      def another_result do
        %{"KeyOneTwoThree" => %{"SubKey" => "Hello"}}
      end
    end

    test "function_call and deep dig 1" do
      {:ok, ast} = Parser.parse("another_result().KeyOneTwoThree.SubKey")
      assert {:ok, "Hello"} == Interpreter.eval(ast, %{}, ObjWithStruct)
    end

    test "function_call and deep dig 2" do
      {:ok, ast} = Parser.parse("some_result().key.field")
      assert {:ok, "Hello world"} == Interpreter.eval(ast, %{}, ObjWithStruct)
    end

    test "function_call and deep dig (sad path)" do
      {:ok, ast} = Parser.parse("some_result().key.unknown_field")

      assert_raise(ArgumentError, ~r/(existing atom)|(argument error)/, fn ->
        Interpreter.eval(ast, %{}, ObjWithStruct)
      end)
    end
  end

  describe "#happy_path" do
    test "function call" do
      {:ok, ast} = Parser.parse("div(5, 2)")
      assert {:ok, 2} == Interpreter.eval(ast, %{}, Kernel)
    end

    test "function call: 3 arguments" do
      {:ok, ast} = Parser.parse("concat(1, 2, 3)")
      assert {:ok, "123"} == Interpreter.eval(ast, %{}, TestModule)
    end

    test "function call: complex args" do
      {:ok, ast} = Parser.parse("concat(concat(1, 2, 3), concat(4, 5, 6), concat(7, 8, 9))")
      assert {:ok, "123456789"} == Interpreter.eval(ast, %{}, TestModule)
    end

    test "function call with variable" do
      {:ok, ast} = Parser.parse("div(5, x)")
      assert {:ok, 2} == Interpreter.eval(ast, %{"x" => 2}, Kernel)
    end

    test "function call with no vars + field access" do
      {:ok, ast} = Parser.parse("create_obj().a.b")
      assert {:ok, "c"} == Interpreter.eval(ast, %{}, TestModule)
    end

    test "function from standard library" do
      {:ok, ast} = Parser.parse("str(1)")
      assert {:ok, "1"} == Interpreter.eval(ast)
    end

    test "sum of two numbers" do
      {:ok, ast} = Parser.parse("1 + 0.5")
      assert {:ok, 1.5} == Interpreter.eval(ast)
    end

    test "minus number" do
      {:ok, ast} = Parser.parse("1 - 0.5")
      assert {:ok, 0.5} == Interpreter.eval(ast)
    end

    test "ops order" do
      {:ok, ast} = Parser.parse("2+3*4+5")
      assert {:ok, 19} == Interpreter.eval(ast)
    end

    test "parenthesis" do
      {:ok, ast} = Parser.parse("(2+3)*(4+5)")
      assert {:ok, 45} == Interpreter.eval(ast)
    end

    test "bool 1" do
      {:ok, ast} = Parser.parse("true or false")
      assert {:ok, true} == Interpreter.eval(ast)
    end

    test "bool 2" do
      {:ok, ast} = Parser.parse("true and false")
      assert {:ok, false} == Interpreter.eval(ast)
    end

    test "bool 3" do
      {:ok, ast} = Parser.parse("not false")
      assert {:ok, true} == Interpreter.eval(ast)
    end

    test "bool 4" do
      {:ok, ast} = Parser.parse("1 == 1")
      assert {:ok, true} == Interpreter.eval(ast)
    end

    test "bool 5" do
      {:ok, ast} = Parser.parse("1 != 1")
      assert {:ok, false} == Interpreter.eval(ast)
    end

    test "bool(and): ignore right part if left is false" do
      {:ok, ast} = Parser.parse("check_is_true(false) and 1 / 0")
      assert {:ok, false} == Interpreter.eval(ast, %{}, TestModule)
    end

    test "bool(or): ignore right part if left is true" do
      {:ok, ast} = Parser.parse("check_is_true(true) or 1 / 0")
      assert {:ok, true} == Interpreter.eval(ast, %{}, TestModule)
    end

    test "array 1" do
      {:ok, ast} = Parser.parse("[1, 2, 3]")
      assert {:ok, [1, 2, 3]} == Interpreter.eval(ast)
    end

    test "array 2" do
      {:ok, ast} = Parser.parse("[1 - 2, 2, 3]")
      assert {:ok, [-1, 2, 3]} == Interpreter.eval(ast)
    end

    test "array 3" do
      {:ok, ast} = Parser.parse("[1 - 2, str(2), [4, 5]]")
      assert {:ok, [-1, "2", [4, 5]]} == Interpreter.eval(ast)
    end

    test "obj 1" do
      {:ok, ast} = Parser.parse("{}")
      assert {:ok, %{}} == Interpreter.eval(ast)
    end

    test "obj 2" do
      {:ok, ast} = Parser.parse(~s({"a": "b"}))
      assert {:ok, %{"a" => "b"}} == Interpreter.eval(ast)
    end

    test "obj 3" do
      {:ok, ast} = Parser.parse(~s({"a": 1 + 2, "b": [{}], "c": {"d": "e"}}))
      assert {:ok, %{"a" => 3, "b" => [%{}], "c" => %{"d" => "e"}}} == Interpreter.eval(ast)
    end

    test "access 1" do
      {:ok, ast} = Parser.parse("[1, 2][0]")
      assert {:ok, 1} == Interpreter.eval(ast)
    end

    test "access 2" do
      {:ok, ast} = Parser.parse("[[1, 2], 3][0][1]")
      assert {:ok, 2} == Interpreter.eval(ast)
    end

    test "access 3" do
      {:ok, ast} = Parser.parse(~s({"a": "b", "c": "d"}["a"]))
      assert {:ok, "b"} == Interpreter.eval(ast)
    end

    test "access 4" do
      {:ok, ast} = Parser.parse(~s({"a": "b", "c": "d"}[x]))
      assert {:ok, "d"} == Interpreter.eval(ast, %{"x" => "c"})
    end

    test "access 5" do
      {:ok, ast} = Parser.parse(~s({"ключ 1": 1, "ключ 2": 2}["ключ 1"]))
      assert {:ok, 1} == Interpreter.eval(ast, %{"x" => "c"})
    end

    test "access 6" do
      {:ok, ast} = Parser.parse(~s({"key.with.dot": 54321}["key.with.dot"]))
      assert {:ok, 54_321} == Interpreter.eval(ast)
    end
  end

  describe "#sad_path" do
    test "unbound variable 1" do
      {:ok, ast} = Parser.parse(~s({"a": x}))
      assert {:error, {:var_not_bound, "x"}} == Interpreter.eval(ast)
    end

    test "unbound variable 2" do
      {:ok, ast} = Parser.parse(~s([1, x]))
      assert {:error, {:var_not_bound, "x"}} == Interpreter.eval(ast)
    end

    test "function not defined" do
      {:ok, ast} = Parser.parse("not_exist()")
      assert {:error, {:fun_not_defined, "not_exist", 0}} == Interpreter.eval(ast)
    end

    test "function call error" do
      {:ok, ast} = Parser.parse("div(5, 0)")

      assert {:error, {:function_call_exception, :div, [5, 0], %ArithmeticError{}, _msg}} =
               Interpreter.eval(ast, %{}, Kernel)
    end
  end
end
