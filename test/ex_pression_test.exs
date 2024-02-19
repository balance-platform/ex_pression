defmodule ExPressionTest do
  use ExUnit.Case
  doctest ExPression, import: true

  defmodule MyFunctions1 do
    def handle_special("$", value) do
      %{"value" => value}
    end
  end

  defmodule MyFunctions2 do
    # use $ special symbol in expressions
    def handle_special("$", date_str), do: Date.from_iso8601!(date_str)
    # Use diff function in expresions
    def diff(date_1, date_2), do: Date.diff(date_1, date_2)
  end

  describe "#happy_path" do
    test "Special character" do
      assert {:ok, "special"} == ExPression.eval("$special.value", functions_module: MyFunctions1)
    end

    test "Special character: strings" do
      assert {:ok, 365} ==
               ExPression.eval(~s/diff($"2023-02-02", $"2022-02-02")/,
                 functions_module: MyFunctions2
               )
    end

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

    test "Strings concatenation" do
      assert {:ok, "abcde"} == ExPression.eval(~s("abc" + "de"))
    end

    test "dot access operator works with atom keys" do
      assert {:ok, 2022} == ExPression.eval("x.year", bindings: %{"x" => ~D[2022-02-02]})
    end
  end

  describe "#weird path" do
    defmodule MyWeirdFunctions do
      def handle_special("$", value) do
        ">>>#{value}<<<"
      end
    end

    test "build json with subfunction" do
      expression = """
      {
        "val1": $123,
        "val2": $222,
        "list": [$1, 2, $3]
      }
      """

      assert {:ok,
              %{"val1" => ">>>123<<<", "val2" => ">>>222<<<", "list" => [">>>1<<<", 2, ">>>3<<<"]}} ==
               ExPression.eval(expression, functions_module: MyWeirdFunctions)
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

    test "special character used, but no functinos_module provided" do
      assert {:error,
              %ExPression.Error{
                data: %{special: "$", value: "special"},
                message:
                  "Special symbol '$' used with value special, but no functions module was provided",
                name: "SpecialWithoutModule"
              }} == ExPression.eval(~s($special))
    end
  end
end
