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

  describe "8 bit displacement" do
    test "we can do 8 bit displacements thank you very much" do
      binary = <<0b100010::6, 0b0::1, 0b0::1, 0b01::2, 0b000::3, 0b000::3, 0b11111111::8>>
      assert Virtual8086.to_asm(binary, "") == "mov [bx + si - 1], al\n"
    end

    test "special case for mod of 00" do
      binary =
        <<0b100010::6, 0b0::1, 0b0::1, 0b00::2, 0b001::3, 0b110::3, 0b0101010111111111::16>>

      assert Virtual8086.to_asm(binary, "") == "mov [65365], cl\n"
    end

    test "Listing 40" do
      binary =
        "../computer_enhance/perfaware/part1/listing_0039_more_movs"
        |> Path.expand()
        |> File.read!()

      asm = Virtual8086.to_asm(binary, "")
      File.write!("./output.asm", asm)
    end
  end
end
