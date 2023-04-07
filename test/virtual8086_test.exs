defmodule Virtual8086Test do
  use ExUnit.Case
  doctest Virtual8086

  describe "register to register mov" do
    test "listing 37" do
      fixture = "./lib/listing_0037_single_register_mov"
      answer = File.read!("./lib/listing_37.txt")
      binary = fixture |> Path.expand() |> File.read!()
      assert Virtual8086.to_asm(binary, "") == answer
    end

    test "listing 38" do
      fixture = "./lib/listing_0038_many_register_mov"
      answer = File.read!("./lib/listing_38.txt")
      binary = fixture |> Path.expand() |> File.read!()
      assert Virtual8086.to_asm(binary, "") == answer
    end
  end
end
