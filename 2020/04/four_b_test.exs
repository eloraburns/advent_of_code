ExUnit.start

defmodule FourBTest do
  use ExUnit.Case

  @valid %{"pid" => "087499704", "hgt" => "74in", "ecl" => "grn", "iyr" => "2012", "eyr" => "2030", "byr" => "1980", "hcl" => "#623a2f"}

  test "full parse of two records" do
    assert ([
      "a:1 b:2\n",
      "c:3 d:4\n",
      "\n",
      "g:8\n"
    ]
    |> A.parse) == [%{"g" => "8"}, %{"a" => "1", "b" => "2", "c" => "3", "d" => "4"}]
  end

  @data_cases [
    {%{"byr" => "190"}, false},
    {%{"byr" => "1900"}, false},
    {%{"byr" => "2900"}, false},
    {%{"byr" => "29000"}, false},
    {%{"byr" => "2000"}, true},
    {%{"iyr" => "190"}, false},
    {%{"iyr" => "1900"}, false},
    {%{"iyr" => "2900"}, false},
    {%{"iyr" => "29000"}, false},
    {%{"iyr" => "2015"}, true},
    {%{"eyr" => "190"}, false},
    {%{"eyr" => "1900"}, false},
    {%{"eyr" => "2900"}, false},
    {%{"eyr" => "29000"}, false},
    {%{"eyr" => "2025"}, true},
    {%{"hgt" => "20cm"}, false},
    {%{"hgt" => "200cm"}, false},
    {%{"hgt" => "160cm"}, true},
    {%{"hgt" => "1in"}, false},
    {%{"hgt" => "100in"}, false},
    {%{"hgt" => "70in"}, true},
    {%{"hcl" => "#a"}, false},
    {%{"hcl" => "buffoon"}, false},
    {%{"hcl" => "#012345"}, true},
    {%{"hcl" => "#abcdef"}, true},
    {%{"hcl" => "#abcdeg"}, false},
    {%{"hcl" => "#abcdefg"}, false},
    {%{"hcl" => "#abcde"}, false},
    {%{"ecl" => "amb"}, true},
    {%{"ecl" => "blu"}, true},
    {%{"ecl" => "brn"}, true},
    {%{"ecl" => "gry"}, true},
    {%{"ecl" => "grn"}, true},
    {%{"ecl" => "hzl"}, true},
    {%{"ecl" => "oth"}, true},
    {%{"ecl" => "blue"}, false},
    {%{"ecl" => "a"}, false},
    {%{"pid" => "00000000"}, false},
    {%{"pid" => "000000000"}, true},
    {%{"pid" => "0000000000"}, false},
    {%{"cid" => "129"}, true},
  ]

  for {override, is_valid?} <- @data_cases do
    test "validate #{inspect override}" do
      assert Enum.all?(unquote(Macro.escape(override)), &A.validate/1) == unquote(is_valid?)
    end

    test "valid? #{inspect override}" do
      assert (@valid |> Map.merge(unquote(Macro.escape(override))) |> A.valid?) == unquote(is_valid?)
    end
  end

  test "valid? %{}" do
    assert (@valid |> A.valid?) == true
  end

  test "refute all invalid passports" do
    assert [false, false, false, false] == [ 
      "eyr:1972 cid:100\n",
      "hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926\n",
      "\n",
      "iyr:2019\n",
      "hcl:#602927 eyr:1967 hgt:170cm\n",
      "ecl:grn pid:012533040 byr:1946\n",
      "\n",
      "hcl:dab227 iyr:2012\n",
      "ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277\n",
      "\n",
      "hgt:59cm ecl:zzz\n",
      "eyr:2038 hcl:74454a iyr:2023\n",
      "pid:3556412378 byr:2007\n",
    ]
    |> A.parse
    |> Enum.map(&A.valid?/1)
  end

  test "assert all valid passports" do
    assert [true, true, true, true] == [
      "pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980\n",
      "hcl:#623a2f\n",
      "\n",
      "eyr:2029 ecl:blu cid:129 byr:1989\n",
      "iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm\n",
      "\n",
      "hcl:#888785\n",
      "hgt:164cm byr:2001 iyr:2015 cid:88\n",
      "pid:545766238 ecl:hzl\n",
      "eyr:2022\n",
      "\n",
      "iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719\n",
    ]
    |> A.parse
    |> Enum.map(&A.valid?/1)
  end

end

ExUnit.Server.modules_loaded()
ExUnit.run
