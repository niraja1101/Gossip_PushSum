defmodule PServer do

  use GenServer



  def start_link(nid,neighbourlist,topology) do
    GenServer.start_link(__MODULE__, [nid,neighbourlist,topology], name: register_node(nid))
  end

  def init([nid,neighbourlist,topology]) do
     receive do
        {_,sum,weight} -> generator = Task.start fn -> begin_rumor(sum+nid,weight+1,neighbourlist,nid,topology) end
        actor(sum+nid,weight+1,nid,generator,1,nid)
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


  def begin_rumor(sum,weight,neighbourlist,nid,topology) do

    {sum,weight} = receive do
                     {:newmessage,news,neww}->{news,neww}
                   end

   if(topology == "line") do
     selected_node_pos = :rand.uniform(length(neighbourlist))-1
     selected_node = Enum.at(neighbourlist,selected_node_pos)
     selected_node_id = findnode(selected_node)
     if selected_node_id != nil do
       send(selected_node_id,{:message,sum,weight})
     end
   end

   if(topology == "full") do
     selected_node = :rand.uniform(length(neighbourlist))
     selected_node_id = if selected_node != nid, do: findnode(selected_node), else: findnode(selected_node+1)
     if selected_node_id != nil do
       send(selected_node_id,{:message,sum,weight})
     end
   end

   if(topology == "imp2D") do
     selected_node_pos = :rand.uniform(length(neighbourlist))-1
     selected_node = Enum.at(neighbourlist,selected_node_pos)
     selected_node_id = findnode(selected_node)
     if selected_node_id != nil do
       send(selected_node_id,{:message,sum,weight})
     end
   end

   if(topology == "rand2D") do
     selected_node_pos = :rand.uniform(length(neighbourlist))-1
     selected_node = Enum.at(neighbourlist,selected_node_pos)
     selected_node_id = findnode(selected_node)
     if selected_node_id != nil do
       send(selected_node_id,{:message,sum,weight})
     end
   end

   if(topology == "3D") do
     selected_node_pos = :rand.uniform(length(neighbourlist))-1
     selected_node = Enum.at(neighbourlist,selected_node_pos)
     selected_node_id = findnode(selected_node)
     if selected_node_id != nil do
       send(selected_node_id,{:message,sum,weight})
     end
   end

   if(topology == "torus") do
     selected_node_pos = :rand.uniform(length(neighbourlist))-1
     selected_node = Enum.at(neighbourlist,selected_node_pos)
     selected_node_id = findnode(selected_node)
     if selected_node_id != nil do
       send(selected_node_id,{:message,sum,weight})
     end
   end

   begin_rumor(sum,weight,neighbourlist,nid,topology)
 end

  def actor(sum,weight,oldratio,generator,count,nid)  do
    newratio = sum/weight
    delta = abs(newratio-oldratio)
    count = if delta > :math.pow(10,-10) do
              0
            else
              count+1
            end

    if(count >= 3) do
      send(:global.whereis_name(:conv_pid),{:done,self(),nid})
      Task.shutdown(generator,:brutal_kill)
    else
      send(elem(generator,1),{:newmessage,sum/2,weight/2})
      send(self(),{:newmessage,sum/2,weight/2})
      receive do
        {:message,gots,gotw} ->  actor(gots+(sum/2),gotw+(weight/2),newratio,generator,count+1,nid)

      after
        80 -> actor(sum/2,weight/2,newratio,generator,count,nid)
      end
    end
  end



end

