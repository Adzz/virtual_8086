defmodule Virtual8086 do
  @moduledoc """
  A virtual 8086 CPU chip developed as part of the performance aware programming course.

  This is the schema for the mov instruction
    <<opcode::6, d_bit::1, w_bit::1, mod::2, reg::3, rm::3>>
  """
  def to_asm(<<>>, asm), do: asm

  def to_asm(<<instruction::bytes-size(2), rest::binary>>, asm) do
    to_asm(rest, asm <> instruction(instruction) <> "\n")
  end

  @doc """
  This is the schema for the mov instruction:

      <<opcode::6, d_bit::1, w_bit::1, mod::2, reg::3, rm::3>>

  First 6 bits is the opcode. For register to/from register mov it is 100010
  """
  def instruction(<<0b100010::6, d_bit::1, w_bit::1, 0b11::2, reg::3, rm::3>>) do
    {source, destination} =
      case {d_bit, w_bit} do
        {0, 1} -> {sixteen_bit_registers(reg), sixteen_bit_registers(rm)}
        {0, 0} -> {eight_bit_registers(reg), eight_bit_registers(rm)}
        {1, 0} -> {eight_bit_registers(rm), eight_bit_registers(reg)}
        {1, 1} -> {sixteen_bit_registers(rm), sixteen_bit_registers(reg)}
      end

    # Obviously horrible that destination comes first.
    "mov" <> " " <> destination <> ", " <> source
  end

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
