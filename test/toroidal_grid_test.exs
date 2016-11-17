defmodule ToroidalGridTest do
	use ExUnit.Case, async: true
	doctest ToroidalGrid

	defmodule Counter do
		def start_link do
    	Agent.start_link fn -> 0 end
    end

    def inc(counter) do
    	Agent.get_and_update(counter, fn count -> {count, count + 1} end)
  	end

		def get_value(counter) do
			Agent.get(counter, &(&1))
		end
	end

	setup do
		{:ok, counter} = ToroidalGridTest.Counter.start_link
		{:ok, counter: counter}
	end


	test "Initialize", %{counter: counter} do
		n = 2
		m = 4

		toroidal = ToroidalGrid.new(n, m, fn _, _-> counter |> ToroidalGridTest.Counter.inc end)
		assert tuple_size(toroidal.tuple) == n * m
	end


	test "ToroidalGrid.map function", %{counter: counter} do
		rows = 2
		cols = 3

		toroidal = ToroidalGrid.new(rows, cols, fn _, _-> counter |> ToroidalGridTest.Counter.inc end)
		result   = ToroidalGrid.map(toroidal, fn(x) -> x * 2 end)

    assert result.tuple == {0, 2, 4, 6, 8, 10}
	end


	test "neighborhood", %{counter: counter} do
		n = 5

		toroidal = ToroidalGrid.new(n, n, fn _, _ -> counter |> ToroidalGridTest.Counter.inc end)

		neighborhood =  toroidal |> ToroidalGrid.neighborhood(0, 0)
		assert Enum.sort(neighborhood) == [0, 1, 4, 5, 20]

		neighborhood =  toroidal |> ToroidalGrid.neighborhood(0, n-1)
		assert Enum.sort(neighborhood) == [0, 3, 4, 9, 24]

		neighborhood =  toroidal |> ToroidalGrid.neighborhood(n-1, 0)
		assert Enum.sort(neighborhood) == [0, 15, 20, 21, 24]

		neighborhood =  toroidal |> ToroidalGrid.neighborhood(n-1, n-1)
		assert Enum.sort(neighborhood) == [4, 19, 20, 23, 24]

		neighborhood =  toroidal |> ToroidalGrid.neighborhood(0, 2)
		assert Enum.sort(neighborhood) == [1, 2, 3, 7, 22]

		neighborhood =  toroidal |> ToroidalGrid.neighborhood(2, 0)
		assert Enum.sort(neighborhood) == [5, 10, 11, 14, 15]

		neighborhood =  toroidal |> ToroidalGrid.neighborhood(2, n-1)
		assert Enum.sort(neighborhood) == [9, 10, 13, 14, 19]

		neighborhood =  toroidal |> ToroidalGrid.neighborhood(n-1, 2)
		assert Enum.sort(neighborhood) == [2, 17, 21, 22, 23]

		neighborhood =  toroidal |> ToroidalGrid.neighborhood(1, 1)
		assert Enum.sort(neighborhood) == [1, 5, 6, 7, 11]
	end
end
