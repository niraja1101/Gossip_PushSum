defmodule Server do
    use GenServer


    def start_link(nid,neighbourlist,topology) do
        GenServer.start_link(__MODULE__, [nid,neighbourlist,topology], name: register_node(nid))
    end

    def init([nid,neighbourlist,topology]) do

        receive do
            {:message,r} -> generator = Task.start fn -> begin_rumor(r,neighbourlist,nid,topology) end
                         actor(r,generator,1,nid)
        end
    end

    defp register_node(nid) do
        {:via, Registry, {:hashmap, nid}}
      end

    def findnode(nid) do
      ret=Registry.lookup(:hashmap, nid)
      val=handle(ret)
      val
    end

    def handle ([{pid,_}]) do
     pid
    end

    def handle([]) do
     nil
    end

    def begin_rumor(r,neighbourlist,nid,topology) do
        if(topology == "line") do
            selected_node_pos = :rand.uniform(length(neighbourlist))-1
            selected_node = Enum.at(neighbourlist,selected_node_pos)
            selected_node_id = findnode(selected_node)
            if selected_node_id != nil do
                send(selected_node_id,{:message,r})
            end
        end

        if(topology == "full") do
            selected_node = :rand.uniform(length(neighbourlist))
            selected_node_id = if selected_node != nid, do: findnode(selected_node), else: findnode(selected_node+1)
            if selected_node_id != nil do
                send(selected_node_id,{:message,r})
            end
        end

        if(topology == "imp2D") do
            selected_node_pos = :rand.uniform(length(neighbourlist)) - 1
            selected_node = Enum.at(neighbourlist,selected_node_pos)
            selected_node_id = findnode(selected_node)
            if selected_node_id != nil do
                send(selected_node_id,{:message,r})
            end
        end

        if(topology == "rand2D" and length(neighbourlist) >0) do
            selected_node_pos = :rand.uniform(length(neighbourlist))-1
            selected_node = Enum.at(neighbourlist,selected_node_pos)
            selected_node_id = findnode(selected_node)
            if selected_node_id != nil do
                send(selected_node_id,{:message,r})
            end

        end

        if(topology == "3D") do
            selected_node_pos = :rand.uniform(length(neighbourlist))-1
            selected_node = Enum.at(neighbourlist,selected_node_pos)
            selected_node_id = findnode(selected_node)
            if selected_node_id != nil do
                send(selected_node_id,{:message,r})
            end
        end

        if(topology == "torus") do
            selected_node_pos = :rand.uniform(length(neighbourlist))-1
            selected_node = Enum.at(neighbourlist,selected_node_pos)
            selected_node_id = findnode(selected_node)
            if selected_node_id != nil do
                send(selected_node_id,{:message,r})
            end
        end

    Process.sleep(100)
    begin_rumor(r,neighbourlist,nid,topology)
end


    def actor(r,generator,count,nid)  do
        if(count < 10) do
            receive do
                {:message,r} ->  actor(count+1,r,generator,nid)
            end
        else

            send(:global.whereis_name(:conv_pid),{:done,self(),nid})
            Task.shutdown(generator,:brutal_kill)
            r
        end
    end


end
