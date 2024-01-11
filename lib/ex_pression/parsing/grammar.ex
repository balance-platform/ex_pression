defmodule ExPression.Parsing.Grammar do
  @moduledoc """
  Expressions formal language grammar definition
  """
  import Xpeg

  # credo:disable-for-next-line
  def peg do
    peg Expr do
      # Space characters
      S <- {' ', '\t', '\r', '\n'}

      # Basic atoms
      True <- "true" * fn cs -> [true | cs] end
      False <- "false" * fn cs -> [false | cs] end
      Null <- "null" * fn cs -> [nil | cs] end

      # Strings
      Xdigit <- {'0'..'9', 'a'..'f', 'A'..'F'}
      Unicode_escape <- 'u' * Xdigit[4]
      Escape <- '\\' * ({'"', '\\', '/', 'b', 'f', 'n', 'r', 't'} | Unicode_escape)
      String_body <- star(Escape) * star(+({'\x20'..'\x7f', 'а'..'я', 'А'..'Я'} - {'"'} - {'\\'}) * star(Escape))
      String <- '"' * str(String_body) * '"'

      # Numbers
      Integer <- int(opt('-') * ('0' | {'1'..'9'}) * star({'0'..'9'}))
      Float <- float(opt('-') * ('0' | {'1'..'9'}) * star({'0'..'9'}) * (("." * +{'0'..'9'}) | ({'e', 'E'} * opt({'+', '-'}) * +{'0'..'9'})))

      KeyWord <- ("false" | "true" | "null" | "or" | "and" | "not")
      Identifier1 <- {'a'..'z', 'A'..'Z', '_'} * star({'a'..'z', 'A'..'Z', '_', '0'..'9'})
      Identifier <- str((KeyWord * Identifier1) | (!KeyWord * Identifier1))

      # Expressions
      Expr <- star(S) * L2 * star(L1BinOp)
      L2 <- L3 * star(L2BinOp)
      L3 <- L3UnOp | L4
      L4 <- L5 * star(L4BinOp)
      L5 <- L6 * star(L5BinOp)
      L6 <- L7 * star(L6BinOp)
      L7 <- (FCall | Object | Array | Var | Const | "(" * star(S) * Expr * star(S) * ")") * star(AccessOp)
      Var <- Identifier * fn [name | cs] -> [{:var, [name]} | cs] end
      Const <- String | Float | Integer  | Null | True | False

      # Function call
      FCall <- Identifier * "(" * fn cs -> [[] | cs] end * star(S) * (FArg * star("," * star(S) * FArg) | star(S)) * ")" * fn [args, name | cs] ->
        [{:fun_call, [name | Enum.reverse(args)]} | cs]
      end
      FArg <- Expr * fn [arg, args | cs] -> [[arg | args] | cs] end

      # Arrays
      ArrayItem <- Expr * fn [v, a | cs] -> [[v | a] | cs] end

      Array <- "[" * fn cs -> [[] | cs] end * (ArrayItem * star("," * ArrayItem) | star(S)) * star(S) * "]" *
          fn [a | cs] -> [{:array, Enum.reverse(a)} | cs] end

      # Objects
      ObjPair <- star(S) * String * star(S) * ":" * Expr * fn [v, k, obj | cs] -> [[{k, v} | obj] | cs] end
      Object <- "{" * fn cs -> [[] | cs] end * (ObjPair * star("," * ObjPair) | star(S)) * star(S) * "}" * fn [obj | cs] -> [{:obj, obj} | cs] end

      # Access
      AccessOp <- Access | FieldAccess
      FieldAccess <- star(L7) * "." * Identifier * fn [field, obj | cs] -> [{:field_access, [obj, field]} | cs] end
      Access <- star((FCall | Var | Const) * star(AccessOp)) * "[" * Expr * star(S) * "]" * fn [arg, obj | cs] -> [{:access, [obj, arg]} | cs] end

      # Operators
      # Op With lowest priority
      L1BinOp <- +S * "or" * +S * Expr * fn [b, a | cs] ->
        [{:or, [a, b]} | cs]
      end

      L2BinOp <- +S * "and" * +S * L2 * fn [b, a | cs] ->
        [{:and, [a, b]} | cs]
      end

      L3UnOp <- "not" * +S * L3 * fn [x | cs ] -> [{:not, [x]} | cs] end

      L4BinOp <- star(S) * str("==" | "!=" | ">=" | ">" | "<=" | "<") * star(S) * L4 * fn [b, op, a | cs] ->
        case op do
          "==" -> [{:==, [a, b]} | cs]
          "!=" -> [{:!=, [a, b]} | cs]
          ">" -> [{:>, [a, b]} | cs]
          ">=" -> [{:>=, [a, b]} | cs]
          "<" -> [{:<, [a, b]} | cs]
          "<=" -> [{:<=, [a, b]} | cs]
        end
      end

      L5BinOp <- star(S) * str({'+', '-'}) * star(S) * L5 * fn [b, op, a | cs] ->
        case op do
          "+" -> [{:+, [a, b]} | cs]
          "-" -> [{:-, [a, b]} | cs]
        end
      end

      L6BinOp <- star(S) * str({'*', '/'}) * star(S) * L6 * fn [b, op, a | cs] ->
        case op do
          "*" -> [{:*, [a, b]} | cs]
          "/" -> [{:/, [a, b]} | cs]
        end
      end
    end
  end
end
