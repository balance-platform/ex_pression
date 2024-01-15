defmodule ExPressionTest do
  use ExUnit.Case
  doctest ExPression, import: true

  describe "#happy_path" do
    test "Support cyrillic symbols in strings" do
      assert {:ok, "Привет!"} == ExPression.eval(~s("Привет!"))
    end

    test "Multi line JSON" do
      assert {:ok, %{"a" => "b"}} ==
               ExPression.eval("""
               {
                 "a": "b"
               }
               """)
    end

    test "strings concatenation" do
      assert {:ok, "abcde"} == ExPression.eval(~s("abc" + "de"))
    end
  end

  describe "#sad_path" do
    test "Parsing error" do
      assert {:error,
              %ExPression.Error{
                name: "SyntaxError",
                message: "Syntax Error: couldn't parse '}'",
                data: %{rest: "}"}
              }} == ExPression.eval("{}}")
    end

    test "Variable not defined error" do
      assert {:error,
              %ExPression.Error{
                data: %{var: "x"},
                message: "Variable 'x' was used, but was not defined",
                name: "UndefinedVariableError"
              }} == ExPression.eval("x")
    end

    test "Function not defined error" do
      assert {:error,
              %ExPression.Error{
                data: %{function: :f},
                message: "Function 'f/0' was referenced, but was not defined",
                name: "UndefinedFunctionError"
              }} == ExPression.eval("f()")
    end

    test "Function call exception" do
      assert {:error,
              %ExPression.Error{
                name: "FunctionCallException",
                message:
                  "Function 'div' called with args [5, 0] raised exception: ArithmeticError",
                data: %{
                  args: [5, 0],
                  function: :div,
                  message: _msg,
                  exception: %ArithmeticError{}
                }
              }} = ExPression.eval("div(5, 0)", functions_module: Kernel)
    end

    test "bad operation argument types" do
      assert {
               :error,
               %ExPression.Error{
                 name: "BadOperationArgumentTypes",
                 message: "Opeartion '+' does not support argument types of [\"abc\", 3]",
                 data: %{arguments: ["abc", 3], operation: :+}
               }
             } == ExPression.eval(~s("abc" + 3))
    end
  end
end
