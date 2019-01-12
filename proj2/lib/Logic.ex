defmodule Logic do

    ###################################  Gossip : Math for fully connected  #######################################


    def g_full(numnodes,topology) do
        neighbourlist= Enum.to_list 1..numnodes
        for i <- 1..numnodes do
            pid = spawn(fn -> Server.start_link(i, neighbourlist,topology) end)
            Process.monitor(pid)
        end
        helper(numnodes)
    end


    ######################################### Gossip : Math for line  ###############################################

    def g_line(numnodes,topology) do
        for i <- 1..numnodes do
            #neighbourlist =[]
            neighbourlist = cond do
                        i==1 -> [i+1]
                        i == numnodes -> [i-1]
                        true -> [i-1,i+1]
            end

            pid = spawn(fn -> Server.start_link(i,neighbourlist,topology) end)
            Process.monitor(pid)
        end
        helper(numnodes)
    end

 ##################################### Gossip : Math for imperfect line  ##############################################

    def g_impline(numnodes,topology) do
        for i <- 1..numnodes do
            x = select_random(numnodes)
            selected_rand_neighbour = if x == i do
                                        select_random(numnodes)
                                      else
                                       x
                                      end

                neighbourlist =  cond do
                                    i == 1 -> [i+1, selected_rand_neighbour]
                                    i == numnodes -> [i-1, selected_rand_neighbour]
                                    true -> [i-1, i+1, selected_rand_neighbour]
                              end
                pid = spawn(fn -> Server.start_link(i,neighbourlist,topology) end)
                Process.monitor(pid)
        end
        helper(numnodes)
    end

    def select_random(numnodes) do
        selected_rand_node = :rand.uniform(numnodes)
        selected_rand_node
    end


 ######################################  Gossip : Math for random 2D grid  ###############################################

    def g_rand2D(numnodes,topology) do
        createtable(numnodes)
        for i <- 1..numnodes do
            neighbourlist = findneighbour(i,numnodes)

            pid = spawn(fn -> Server.start_link(i,neighbourlist,topology) end)
            Process.monitor(pid)

        end
        helper(numnodes)
        deletetab()

    end

    def createtable(numnodes) do

        :ets.new(:pointreg,[:set,:protected,:named_table])
        for i <- 1..numnodes do
             x = Float.round(:rand.uniform,3)
             y = Float.round(:rand.uniform,3)
             :ets.insert_new(:pointreg,{i,x,y})
        end
    end

    def findneighbour(nid,numnodes) do

        mycor = :ets.match(:pointreg,{nid,:"$1",:"$2"})
        [h|_]=mycor
        [myxcor|sec]=h
        [myycor|_]=sec

        neighbourlist = appendlist(myxcor,myycor,1,[],numnodes);
        neighbourlist


    end

    def appendlist(myxcor,myycor,i,neighbourlist,x) do
            if(i<x) do
                newcor = :ets.match(:pointreg,{i,:"$1",:"$2"})
                [newh|_]=newcor
                [newxcor|newsec]=newh
                [newycor|_]=newsec
                dist = :math.sqrt(:math.pow((newxcor-myxcor),2) + :math.pow((newycor-myycor),2))
                neighbourlist = if dist < 0.1 && dist != 0.0 do [ i | neighbourlist] else neighbourlist end
                appendlist(myxcor,myycor,i+1,neighbourlist,x)
            else
                neighbourlist
            end
    end

    def deletetab do
         :ets.delete(:pointreg)
    end





######################################## Gossip :Math for 3D grid ##################################################

def g_3D(numnodes, topology) do
    rowsize = Kernel.trunc(:math.ceil(:math.pow(numnodes,1/3)))
    #IO.puts rowsize
    for i <- 1..numnodes do
      neighbourlist = cond do
                        i == 1 -> [ i+1, i+rowsize, i+(rowsize*rowsize)]  ##for 1
                        i == rowsize -> [i-1, i+rowsize, i+(rowsize*rowsize)] ## for 3
                        i == ((rowsize*rowsize) - rowsize + 1) -> [i+1,i+(rowsize*rowsize),i-rowsize] ## for 7
                        i == (rowsize*rowsize) -> [i-1, i-rowsize, i + (rowsize*rowsize)]   ## for 9
                        i == ((rowsize*rowsize*rowsize)-(rowsize*rowsize)+1) -> [i+1, i+rowsize, i -(rowsize*rowsize)]  ## for 19
                        i == ((rowsize*rowsize*rowsize)-(rowsize*rowsize)+rowsize) -> [i-1, i+rowsize ,i -(rowsize*rowsize)]  ## for 21
                        i == ((rowsize*rowsize*rowsize) - rowsize + 1) -> [i+1, i-rowsize , i-(rowsize*rowsize)] ## for 25
                        i == (rowsize*rowsize*rowsize) -> [ i-1, i-rowsize , i-(rowsize*rowsize)] ## for 27
                        i < rowsize -> [i-1,i+1,i+rowsize, i+(rowsize*rowsize)] ## for 2
                        rem(i-1, rowsize) == 0 and i < (rowsize*rowsize) -> [i-rowsize,i+rowsize, i+1, i + (rowsize*rowsize)] ## for 4
                        rem(i, rowsize) == 0 and i < (rowsize*rowsize) -> [i-rowsize,i+rowsize, i-1, i + (rowsize*rowsize)] ## for 6
                        i < (rowsize*rowsize) and i > ((rowsize*rowsize) - rowsize + 1) -> [i-rowsize,i+1, i-1, i + (rowsize*rowsize)] ## for 8
                        rem(i-1, rowsize*rowsize) == 0 -> [i+rowsize,i+1, i-(rowsize*rowsize), i + (rowsize*rowsize)] ## for 10
                        rem(i- rowsize, rowsize*rowsize) == 0 -> [i+rowsize,i-1, i-(rowsize*rowsize), i + (rowsize*rowsize)] ## for 12
                        rem(i + rowsize - 1, (rowsize*rowsize)) == 0 -> [i+1,i-rowsize, i-(rowsize*rowsize), i + (rowsize*rowsize)] ## for 16
                        rem(i,rowsize*rowsize) == 0 -> [i-rowsize, i-1, i-(rowsize*rowsize), i + (rowsize*rowsize)] ## for 18
                        i > ((rowsize*rowsize*rowsize) -(rowsize*rowsize) + 1) and i < ((rowsize*rowsize*rowsize) -(rowsize*rowsize) + rowsize) -> [i-1, i+1 ,i+rowsize, i -(rowsize*rowsize)] ## for 20
                        rem(i-1, rowsize) == 0 and i > ((rowsize*rowsize*rowsize) - (rowsize*rowsize)) -> [i-rowsize,i+rowsize, i+1, i - (rowsize*rowsize)] ## for 22
                        rem(i, rowsize) == 0 and i > ((rowsize*rowsize*rowsize) - (rowsize*rowsize)) -> [i-rowsize,i+rowsize, i-1, i - (rowsize*rowsize)] ## for 24
                        i > ((rowsize*rowsize*rowsize) - rowsize + 1) -> [i-rowsize,i+1, i-1, i - (rowsize*rowsize)] ## for 26
                        i < (rowsize*rowsize) -> [i+1, i-1, i+rowsize, i-rowsize, i + (rowsize*rowsize)] ## for 5
                        rem(i,(rowsize*rowsize)) < rowsize -> [i+1, i-1, i+rowsize, i - (rowsize*rowsize),i + (rowsize*rowsize)] ## for 11
                        rem(i-1, rowsize) == 0 -> [i+1, i-rowsize, i + rowsize, i - (rowsize*rowsize), i + (rowsize*rowsize)] ## for 13
                        rem(i, rowsize) == 0 -> [i-1, i-rowsize, i + rowsize, i - (rowsize*rowsize), i + (rowsize*rowsize)] ## for 15
                        rem(i,(rowsize*rowsize)) > ((rowsize*rowsize) - rowsize + 1) -> [i+1, i-1, i-rowsize, i - (rowsize*rowsize), i + (rowsize*rowsize)] ## for 17
                        i > ((rowsize*rowsize*rowsize) -(rowsize*rowsize) + 1) -> [i+1, i-1 , i-rowsize, i+rowsize, i - (rowsize*rowsize)]
                        true -> [i+1, i-1, i+rowsize, i-rowsize, i+(rowsize*rowsize), i-(rowsize*rowsize)]
                      end
      neighbourlist = Enum.reject(neighbourlist,fn x -> x > numnodes end)
      pid = spawn(fn -> Server.start_link(i,neighbourlist,topology) end)
      Process.monitor(pid)


      #IO.puts Kernel.inspect (neighbourlist ++ [0])
      #IO.puts Enum.at(neighbourlist,3)
      #IO.inspect Enum.at(neighbourlist,3)


    end
    helper(numnodes)
end


######################################### Gossip: Math for Torus ####################################################

def g_torus(numnodes,topology) do
    dim = :math.sqrt(numnodes)
    rowcount = Kernel.trunc(:math.ceil(dim))
    for i <- 1..numnodes do
        neighbourlist =  cond do
                                i == 1 -> [i+1,i+rowcount,i+rowcount-1,i+rowcount*(rowcount-1)]
                                i == rowcount -> [i-1,i+rowcount,1,i+rowcount*(rowcount-1)]
                                i == numnodes - rowcount + 1 -> [i+1,i-rowcount,1,numnodes]
                                i == numnodes -> [i-1,i-rowcount,i-rowcount*(rowcount-1),i-(rowcount+1)]
                                i < rowcount -> [i-1,i+1,i+rowcount,i+rowcount*(rowcount-1)]  #done
                                i > numnodes - rowcount + 1 and i < numnodes -> [i-1,i+1,i-rowcount,i-rowcount*(rowcount-1)] #done
                                rem(i-1,rowcount) == 0 -> [i+1,i-rowcount,i+rowcount,i+rowcount-1]
                                rem(i,rowcount) == 0 -> [i-1,i-rowcount,i+rowcount,i-rowcount+1] #done
                                true -> [i-1,i+1,i-rowcount,i+rowcount]
                          end
         #IO.puts Kernel.inspect (neighboursList ++ [0])
         pid = spawn(fn -> Server.start_link(i,neighbourlist,topology) end)
         Process.monitor(pid)
    end

    helper(numnodes)
end


######################################### Pushsum : Math for fully connected ###############################################

def p_full(numnodes,topology) do

    neighbourlist= Enum.to_list 1..numnodes
    for i <- 1..numnodes do
        pid = spawn(fn -> PServer.start_link(i, neighbourlist,topology) end)
        Process.monitor(pid)
    end
    phelper(numnodes)

end

######################################### Pushsum : Math for line  ###############################################

def p_line(numnodes,topology) do
    for i <- 1..numnodes do
        #neighbourlist =[]
        neighbourlist = cond do
                    i==1 -> [i+1]
                    i == numnodes -> [i-1]
                    true -> [i-1,i+1]
        end

        pid = spawn(fn -> PServer.start_link(i,neighbourlist,topology) end)
        Process.monitor(pid)
    end
    phelper(numnodes)
end

######################################### Pushsum : Math for Imperfect line ###############################################

def p_impline(numnodes,topology) do

    for i <- 1..numnodes do
        x = select_random(numnodes)
        selected_rand_neighbour = if x == i do
                                        select_random(numnodes)
                                  else
                                    x
                                  end
        neighbourlist =  cond do
                                i == 1 -> [i+1, selected_rand_neighbour]
                                i == numnodes -> [i-1, selected_rand_neighbour]
                                true -> [i-1, i+1, selected_rand_neighbour]
                          end
        pid = spawn(fn -> PServer.start_link(i,neighbourlist,topology) end)
        Process.monitor(pid)
    end
    phelper(numnodes)
end

######################################### Pushsum : Math for Random2D grid ###############################################

def p_rand2D(numnodes,topology) do
    createtable(numnodes)
    for i <- 1..numnodes do
        neighbourlist = findneighbour(i,numnodes)
        #IO.puts(length(neighbourlist))
        pid = spawn(fn -> PServer.start_link(i,neighbourlist,topology) end)
        Process.monitor(pid)

    end
    deletetab()
    phelper(numnodes)
end

######################################### Pushsum : Math for 3D grid  ###############################################

def p_3D(numnodes,topology) do
    rowsize = Kernel.trunc(:math.ceil(:math.pow(numnodes,1/3)))
    #IO.puts rowsize
    for i <- 1..numnodes do
      neighbourlist = cond do
                        i == 1 -> [ i+1, i+rowsize, i+(rowsize*rowsize)]  ##for 1
                        i == rowsize -> [i-1, i+rowsize, i+(rowsize*rowsize)] ## for 3
                        i == ((rowsize*rowsize) - rowsize + 1) -> [i+1,i+(rowsize*rowsize),i-rowsize] ## for 7
                        i == (rowsize*rowsize) -> [i-1, i-rowsize, i + (rowsize*rowsize)]   ## for 9
                        i == ((rowsize*rowsize*rowsize)-(rowsize*rowsize)+1) -> [i+1, i+rowsize, i -(rowsize*rowsize)]  ## for 19
                        i == ((rowsize*rowsize*rowsize)-(rowsize*rowsize)+rowsize) -> [i-1, i+rowsize ,i -(rowsize*rowsize)]  ## for 21
                        i == ((rowsize*rowsize*rowsize) - rowsize + 1) -> [i+1, i-rowsize , i-(rowsize*rowsize)] ## for 25
                        i == (rowsize*rowsize*rowsize) -> [ i-1, i-rowsize , i-(rowsize*rowsize)] ## for 27
                        i < rowsize -> [i-1,i+1,i+rowsize, i+(rowsize*rowsize)] ## for 2
                        rem(i-1, rowsize) == 0 and i < (rowsize*rowsize) -> [i-rowsize,i+rowsize, i+1, i + (rowsize*rowsize)] ## for 4
                        rem(i, rowsize) == 0 and i < (rowsize*rowsize) -> [i-rowsize,i+rowsize, i-1, i + (rowsize*rowsize)] ## for 6
                        i < (rowsize*rowsize) and i > ((rowsize*rowsize) - rowsize + 1) -> [i-rowsize,i+1, i-1, i + (rowsize*rowsize)] ## for 8
                        rem(i-1, rowsize*rowsize) == 0 -> [i+rowsize,i+1, i-(rowsize*rowsize), i + (rowsize*rowsize)] ## for 10
                        rem(i- rowsize, rowsize*rowsize) == 0 -> [i+rowsize,i-1, i-(rowsize*rowsize), i + (rowsize*rowsize)] ## for 12
                        rem(i + rowsize - 1, (rowsize*rowsize)) == 0 -> [i+1,i-rowsize, i-(rowsize*rowsize), i + (rowsize*rowsize)] ## for 16
                        rem(i,rowsize*rowsize) == 0 -> [i-rowsize, i-1, i-(rowsize*rowsize), i + (rowsize*rowsize)] ## for 18
                        i > ((rowsize*rowsize*rowsize) -(rowsize*rowsize) + 1) and i < ((rowsize*rowsize*rowsize) -(rowsize*rowsize) + rowsize) -> [i-1, i+1 ,i+rowsize, i -(rowsize*rowsize)] ## for 20
                        rem(i-1, rowsize) == 0 and i > ((rowsize*rowsize*rowsize) - (rowsize*rowsize)) -> [i-rowsize,i+rowsize, i+1, i - (rowsize*rowsize)] ## for 22
                        rem(i, rowsize) == 0 and i > ((rowsize*rowsize*rowsize) - (rowsize*rowsize)) -> [i-rowsize,i+rowsize, i-1, i - (rowsize*rowsize)] ## for 24
                        i > ((rowsize*rowsize*rowsize) - rowsize + 1) -> [i-rowsize,i+1, i-1, i - (rowsize*rowsize)] ## for 26
                        i < (rowsize*rowsize) -> [i+1, i-1, i+rowsize, i-rowsize, i + (rowsize*rowsize)] ## for 5
                        rem(i,(rowsize*rowsize)) < rowsize -> [i+1, i-1, i+rowsize, i - (rowsize*rowsize),i + (rowsize*rowsize)] ## for 11
                        rem(i-1, rowsize) == 0 -> [i+1, i-rowsize, i + rowsize, i - (rowsize*rowsize), i + (rowsize*rowsize)] ## for 13
                        rem(i, rowsize) == 0 -> [i-1, i-rowsize, i + rowsize, i - (rowsize*rowsize), i + (rowsize*rowsize)] ## for 15
                        rem(i,(rowsize*rowsize)) > ((rowsize*rowsize) - rowsize + 1) -> [i+1, i-1, i-rowsize, i - (rowsize*rowsize), i + (rowsize*rowsize)] ## for 17
                        i > ((rowsize*rowsize*rowsize) -(rowsize*rowsize) + 1) -> [i+1, i-1 , i-rowsize, i+rowsize, i - (rowsize*rowsize)]
                        true -> [i+1, i-1, i+rowsize, i-rowsize, i+(rowsize*rowsize), i-(rowsize*rowsize)]
                      end
      neighbourlist = Enum.reject(neighbourlist,fn x -> x > numnodes end)
      pid = spawn(fn -> PServer.start_link(i,neighbourlist,topology) end)
      Process.monitor(pid)
      #IO.puts Kernel.inspect (neighbourlist ++ [0])
      #IO.puts Enum.at(neighbourlist,3)
      #IO.inspect Enum.at(neighbourlist,3)
    end
    phelper(numnodes)
end
######################################### Pushsum: Math for Torus ####################################################
def p_torus(numnodes,topology) do
    dim = :math.sqrt(numnodes)
    rowcount = Kernel.trunc(:math.ceil(dim))
    for i <- 1..numnodes do
        neighbourlist =  cond do
                                i == 1 -> [i+1,i+rowcount,i+rowcount-1,i+rowcount*(rowcount-1)]
                                i == rowcount -> [i-1,i+rowcount,1,i+rowcount*(rowcount-1)]
                                i == numnodes - rowcount + 1 -> [i+1,i-rowcount,1,numnodes]
                                i == numnodes -> [i-1,i-rowcount,i-rowcount*(rowcount-1),i-(rowcount+1)]
                                i < rowcount -> [i-1,i+1,i+rowcount,i+rowcount*(rowcount-1)]  #done
                                i > numnodes - rowcount + 1 and i < numnodes -> [i-1,i+1,i-rowcount,i-rowcount*(rowcount-1)] #done
                                rem(i-1,rowcount) == 0 -> [i+1,i-rowcount,i+rowcount,i+rowcount-1]
                                rem(i,rowcount) == 0 -> [i-1,i-rowcount,i+rowcount,i-rowcount+1] #done
                                true -> [i-1,i+1,i-rowcount,i+rowcount]
                          end
         #IO.puts Kernel.inspect (neighboursList ++ [0])
         pid = spawn(fn -> PServer.start_link(i,neighbourlist,topology) end)
         Process.monitor(pid)
    end
    phelper(numnodes)
end



def helper(numnodes) do
    conv = Task.async(fn -> wait_to_converge(numnodes) end)
    :global.register_name(:conv_pid,conv.pid)
    begin_timestamp = System.system_time(:millisecond)
    start_rumor(numnodes)
    Task.await(conv, :infinity)
    end_timestamp = System.system_time(:millisecond)
    IO.puts "Time taken to achieve convergence: #{end_timestamp - begin_timestamp} milliseconds"
end

def start_rumor(numnodes) do
    first_node = :rand.uniform(numnodes)
    first_node_id = Server.findnode(first_node)
    if first_node_id != nil do
        send(first_node_id,{:message,"this is a test"})
    else
        start_rumor(numnodes)
    end
end


def phelper(numnodes) do
    conv = Task.async(fn -> wait_to_converge(numnodes) end)
    :global.register_name(:conv_pid,conv.pid)
    begin_timestamp = System.system_time(:millisecond)
    start_psum(numnodes)
    Task.await(conv, :infinity)
    end_timestamp = System.system_time(:millisecond)
    IO.puts "Time to converge the topology : #{end_timestamp - begin_timestamp} milliseconds"
end



def start_psum(numnodes) do
    first_node = :rand.uniform(numnodes)
    first_node_id = Server.findnode(first_node)
    if first_node_id != nil do
        send(first_node_id,{:message,0,0})
    else
        start_psum(numnodes)
    end
end



def wait_to_converge(numnodes) do

    if(numnodes > 0) do

        receive do
        {:done,pid, nid} -> IO.puts "#{nid} : converged with pid #{inspect(pid)}"
            wait_to_converge(numnodes-1)

        after
            6000 -> IO.puts "Convergence was not attained for a node"
            wait_to_converge(numnodes-1)

        end

    else
    nil
    end
end
end
