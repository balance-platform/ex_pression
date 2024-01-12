defmodule ExPression.StandardLibTest do
  use ExUnit.Case
  alias ExPression.StandardLib

  describe "#len" do
    test "object" do
      assert 1 == StandardLib.len(%{"a" => "b"})
    end

    test "list" do
      assert 0 == StandardLib.len([])
    end

    test "string" do
      assert 3 == StandardLib.len("123")
    end
  end

  describe "#str" do
    test "object" do
      assert ~s({\n  "a": "b"\n}) == StandardLib.str(%{"a" => "b"})
    end

    test "number" do
      assert "1" == StandardLib.str(1)
    end

    test "string" do
      assert "123" == StandardLib.str("123")
    end
  end

  describe "#abs" do
    test "number" do
      assert 2.5 == StandardLib.abs(-2.5)
    end
  end

  describe "#round" do
    test "number" do
      assert -3 == StandardLib.round(-2.5)
    end

    test "float with precision" do
      assert 3.33 == StandardLib.round(3.3333, 2)
    end
  end

  describe "#int" do
    test "number" do
      assert 2 == StandardLib.int(2.7)
    end

    test "string" do
      assert 2 == StandardLib.int("2")
    end
  end

  describe "#min" do
    test "number" do
      assert 0 == StandardLib.min(0, 1)
    end

    test "list" do
      assert 0 == StandardLib.min([0, 1, 2])
    end
  end

  describe "#max" do
    test "number" do
      assert 1 == StandardLib.max(0, 1)
    end

    test "list" do
      assert 2 == StandardLib.max([0, 1, 2])
    end
  end

  describe "#pow" do
    test "number" do
      assert 8 == StandardLib.pow(2, 3)
    end
  end
end
