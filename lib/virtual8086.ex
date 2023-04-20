defmodule Virtual8086 do
  @moduledoc """
  A virtual 8086 CPU chip developed as part of the performance aware programming course.

  This is the schema for the mov to_asm:

      <<opcode::6, d_bit::1, w_bit::1, mod::2, reg::3, rm::3>>

  First 6 bits is the opcode. For register to/from register mov it is 100010
  """
  def to_asm(<<>>, asm), do: asm

  # To / From Register:
  def to_asm(<<0b100010::6, d_bit::1, w_bit::1, 0b11::2, reg::3, rm::3, rest::binary>>, asm) do
    {source, destination} = {register(reg, w_bit), register(rm, w_bit)} |> order_by(d_bit)
    to_asm(rest, asm <> "mov #{destination}, #{source}\n")
  end

  def to_asm(
        <<0b100010::6, d_bit::1, w_bit::1, 0b00::2, reg::3, 0b110::3,
          addr::unsigned-little-integer-size(16), rest::binary>>,
        asm
      ) do
    {source, destination} = {register(reg, w_bit), "[#{addr}]"} |> order_by(d_bit)
    to_asm(rest, asm <> "mov #{destination}, #{source}\n")
  end

  def to_asm(<<0b100010::6, d_bit::1, w_bit::1, 0b00::2, reg::3, rm::3, rest::binary>>, asm) do
    {source, destination} = {register(reg, w_bit), "[#{effective_addr(rm)}]"} |> order_by(d_bit)
    to_asm(rest, asm <> "mov #{destination}, #{source}\n")
  end

  def to_asm(
        <<0b100010::6, d_bit::1, w_bit::1, 0b01::2, reg::3, rm::3,
          low_disp::signed-little-integer-size(8), rest::binary>>,
        asm
      ) do
    rm = "[#{effective_addr(rm)}#{sign(low_disp)}]"
    {source, destination} = {register(reg, w_bit), rm} |> order_by(d_bit)
    to_asm(rest, asm <> "mov #{destination}, #{source}\n")
  end

  def to_asm(
        <<0b100010::6, d_bit::1, w_bit::1, 0b10::2, reg::3, rm::3, displacement::16-little,
          rest::binary>>,
        asm
      ) do
    rm = "[#{effective_addr(rm)} + #{displacement}]"
    {source, destination} = {register(reg, w_bit), rm} |> order_by(d_bit)
    to_asm(rest, asm <> "mov #{destination}, #{source}\n")
  end

  def to_asm(
        <<0b1011::4, 0::1, reg::3, immediate::8, rest::binary>>,
        asm
      ) do
    to_asm(rest, asm <> "mov #{register(reg, 0)}, #{immediate}\n")
  end

  def to_asm(
        <<0b1011::4, 1::1, reg::3, immediate::16-little, rest::binary>>,
        asm
      ) do
    to_asm(rest, asm <> "mov #{register(reg, 1)}, #{immediate}\n")
  end

  def sign(0), do: ""
  def sign(disp), do: if(disp > 0, do: " + #{abs(disp)}", else: " - #{abs(disp)}")

  defp effective_addr(0b000), do: "bx + si"
  defp effective_addr(0b001), do: "bx + di"
  defp effective_addr(0b010), do: "bp + si"
  defp effective_addr(0b011), do: "bp + di"
  defp effective_addr(0b100), do: "si"
  defp effective_addr(0b101), do: "di"
  defp effective_addr(0b110), do: "bp"
  defp effective_addr(0b111), do: "bx"

  defp order_by({source, dest}, 0), do: {source, dest}
  defp order_by({source, dest}, 1), do: {dest, source}

  defp register(location, 1), do: sixteen_bit_registers(location)
  defp register(location, 0), do: eight_bit_registers(location)

  defp sixteen_bit_registers(0), do: "ax"
  defp sixteen_bit_registers(1), do: "cx"
  defp sixteen_bit_registers(2), do: "dx"
  defp sixteen_bit_registers(3), do: "bx"
  defp sixteen_bit_registers(4), do: "sp"
  defp sixteen_bit_registers(5), do: "bp"
  defp sixteen_bit_registers(6), do: "si"
  defp sixteen_bit_registers(7), do: "di"

  defp eight_bit_registers(0), do: "al"
  defp eight_bit_registers(1), do: "cl"
  defp eight_bit_registers(2), do: "dl"
  defp eight_bit_registers(3), do: "bl"
  defp eight_bit_registers(4), do: "ah"
  defp eight_bit_registers(5), do: "ch"
  defp eight_bit_registers(6), do: "dh"
  defp eight_bit_registers(7), do: "bh"
end
