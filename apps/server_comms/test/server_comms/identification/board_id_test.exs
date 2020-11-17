defmodule ServerComms.Identification.BoardIdTest do
  use ExUnit.Case, async: true

  alias ServerComms.Identification.BoardId

  setup do
    cpuinfo_file = Path.join(System.tmp_dir!(), "#{inspect(self())}_#{__MODULE__}_cpuinfo")

    File.write!(
      cpuinfo_file,
      "processor\t: 0\nmodel name\t: ARMv6-compatible processor rev 7 (v6l)\nBogoMIPS\t: 697.95\n" <>
        "Features\t: half thumb fastmult vfp edsp java tls \nCPU implementer\t: 0x41\n" <>
        "CPU architecture: 7\nCPU variant\t: 0x0\nCPU part\t: 0xb76\nCPU revision\t: 7\n\n" <>
        "Hardware\t: BCM2835\nRevision\t: 9000c1\nSerial\t\t: 00000000352052e9\n" <>
        "Model\t\t: Raspberry Pi Zero W Rev 1.1\n"
    )

    on_exit(fn -> File.rm(cpuinfo_file) end)
    {:ok, cpuinfo_file: cpuinfo_file}
  end

  test "reading serial number", %{cpuinfo_file: cpuinfo_file} do
    assert {:ok, "00000000352052e9"} == BoardId.read_serial(cpuinfo_file)
  end

  test "file does not exist" do
    assert {:ok, hostname} = BoardId.read_serial("lolnope")
    assert is_binary(hostname)
  end

  test "file is nonsense", %{cpuinfo_file: cpuinfo_file} do
    File.write!(cpuinfo_file, "trolollo")
    assert {:ok, hostname} = BoardId.read_serial(cpuinfo_file)
    assert is_binary(hostname)
  end
end
