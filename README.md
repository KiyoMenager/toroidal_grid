# ToroidalGrid

Each point of the grid has a neighborhood that overlaps the neighborhoods of
nearby points. In basic algorithm, all the neighborhoods have the same size
and identical shapes. The two most commonly used neighborhoods are L5
(like defined here).

## Use case

[Cellular evolutionary algorithm](https://en.wikipedia.org/wiki/Cellular_evolutionary_algorithm)
*A Cellular Evolutionary Algorithm (cEA) is a kind of evolutionary algorithm (EA) in which individuals cannot mate arbitrarily, but every one interacts with its closer neighbors.

The cellular model simulates Natural evolution from the point of view of the individual, which encodes a tentative (optimization, learning, search) problem solution. The essential idea of this model is to provide the EA population with a special structure defined as a connected graph, in which each vertex is an individual who communicates with his nearest neighbors. Particularly, individuals are conceptually set in a toroidal mesh, and are only allowed to recombine with close individuals. This leads us to a kind of locality known as isolation by distance. The set of potential mates of an individual is called its neighborhood. It is known that, in this kind of algorithm, similar individuals tend to cluster creating niches, and these groups operate as if they were separate sub-populations (islands). Anyway, there is no clear borderline between adjacent groups, and close niches could be easily colonized by competitive niches and maybe merge solution contents during the process. Simultaneously, farther niches can be affected more slowly.*


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `toroidal_grid` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:toroidal_grid, "~> 0.1.0"}]
    end
    ```

  2. Ensure `toroidal_grid` is started before your application:

    ```elixir
    def application do
      [applications: [:toroidal_grid]]
    end
    ```
