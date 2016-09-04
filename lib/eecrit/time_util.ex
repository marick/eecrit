defmodule Eecrit.TimeUtil do
  use Timex

  # TODO: Use Timex compatibility with Ecto.Date
  # TODO: protocols

  def cast_to_date!(d = %Date{}), do: d
  def cast_to_date!(d) when is_tuple(d), do: Date.from_erl!(d)
  def cast_to_date!(d = %Ecto.Date{}), do: cast_to_date!(Ecto.Date.to_erl(d))
  def cast_to_date!(d) when is_binary(d), do: Date.from_iso8601!(d)

  def cast_to_erl!(d), do: d |> cast_to_date! |> Date.to_erl

  def friendly_format(nil), do: ""
  def friendly_format(date),
    do: date |> cast_to_date! |> Timex.format!("%B %-d, %Y", :strftime)

  def adjust_range({first, last}, within: {earliest_first, latest_last}) do
    use_first =
      if cast_to_erl!(first) < cast_to_erl!(earliest_first),
        do: earliest_first, else: first

    use_last =
      if cast_to_erl!(last) > cast_to_erl!(latest_last),
        do: latest_last, else: last

    {use_first, use_last}
  end

  def adjust_range_in_struct(struct, {first_key, last_key}, within: bounds) do
    {first, last} =
      {Map.get(struct, first_key), Map.get(struct, last_key)}
      |> adjust_range(within: bounds)

    struct
    |> Map.put(first_key, first)
    |> Map.put(last_key, last)
  end

  def days_covered({first, last}) do
    Timex.diff(cast_to_date!(last), cast_to_date!(first), :days) + 1
  end
end
