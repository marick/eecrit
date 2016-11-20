defmodule Eecrit.Org do
  use GenServer
  
  def add_species(pid, newbie), do: GenServer.cast(pid, {:add_species, newbie})

  def allowable_species(pid), do: GenServer.call(pid, :allowable_species)


  def start_link(org_name) do
    GenServer.start_link(__MODULE__, org_name)
  end

  def init(org_name) do 
    state = %{name: org_name,
              allowable_species: []
             }
    Process.send_after(self, :tick, 10000)
    {:ok, state}
  end
  
  def handle_cast({:add_species, newbie}, state) do
    new_state =
      put_in(state[:allowable_species], [newbie | state[:allowable_species]])
    {:noreply, new_state}
  end

  def handle_call(:allowable_species, _from, state),
    do: {:reply, state[:allowable_species], state}


  def handle_info(:tick, state) do
    if (length(state[:allowable_species]) > 1) do
      raise "boom!"
    else
      IO.puts "tick #{inspect state}"
      Process.send_after(self, :tick, 10000)
      {:noreply, state}
    end
  end
end  
  
