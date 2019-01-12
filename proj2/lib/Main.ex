defmodule Main do
    def main(args) do
      args |> read_arguments |> handle
    end

    defp read_arguments(args) do
      {_,arguments,_} = OptionParser.parse(args)
      arguments
    end

    def handle([]) do
      IO.puts "Please provide some arguments"
    end

    def handle(arguments) do
      numnodes = String.to_integer(Enum.at(arguments,0))
      topology = Enum.at(arguments,1)
      algorithm = Enum.at(arguments,2)
      IO.puts "Calculating the neighbour list...."
      Registry.start_link(keys: :unique, name: :hashmap)
      if topology =="full" do
        if algorithm == "gossip", do: Logic.g_full(numnodes,topology)
        if algorithm == "push-sum", do: Logic.p_full(numnodes,topology)
      end
      if topology =="line" do
        if algorithm == "gossip", do: Logic.g_line(numnodes,topology)
        if algorithm == "push-sum", do: Logic.p_line(numnodes,topology)
      end
      if topology =="imp2D" do
        if algorithm == "gossip", do: Logic.g_impline(numnodes,topology)
        if algorithm == "push-sum", do: Logic.p_impline(numnodes,topology)
      end
      if topology =="rand2D" do
        if algorithm == "gossip", do: Logic.g_rand2D(numnodes,topology)
        if algorithm == "push-sum", do: Logic.p_rand2D(numnodes,topology)
      end
      if topology =="torus" do
        if algorithm == "gossip", do: Logic.g_torus(numnodes,topology)
        if algorithm == "push-sum", do: Logic.p_torus(numnodes,topology)
      end
      if topology =="3D" do
        if algorithm == "gossip", do: Logic.g_3D(numnodes,topology)
        if algorithm == "push-sum", do: Logic.p_3D(numnodes,topology)
      end

    end
end
