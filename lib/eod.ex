defmodule EodhistoricaldataEx.Eod do
  @moduledoc false
  alias EodhistoricaldataEx.Web

  @eod_url "https://eodhistoricaldata.com/api/eod/"

  def construct_options(list) do
    keywords = [:from, :to, :period, :order]

    Enum.map(keywords, fn x -> {x, Keyword.get(list, x)} end)
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.map_join("&", fn {k, v} -> Atom.to_string(k) <> "=" <> to_string(v) end)
  end

  @doc """
  Get data from the eod api.

  Returns `{:ok, %{}}` or `{:error, :e}`.

  Options can include `:from`,`:to`,`:period` and `:order`.
  `:from` and `:to` use the date format YYYY-MM-DD.


  The option `:period` does accept the values "d" for daily, "w" for weeky and "m" for monthly.
  Order does accept "a" for ascending and "d" for descending order by date.

  For more informations about the end-of-day api have a look at:
  https://eodhistoricaldata.com/financial-apis/api-for-historical-data-and-volumes/

  ## Examples

      iex> EodhistoricaldataEx.Eod.eod("apikey", "aapl")
      {:ok, %{}}

      iex> EodhistoricaldataEx.Eod.eod("apikey", "aapl", [from: "2000-01-01", to: "2001-01-01", period: "d", order: "a"])
      {:ok, %{}}

      iex> EodhistoricaldataEx.Eod.eod("invalid", "aapl")
      {:error, :forbidden}

  """
  def eod(api_key, symbol, options \\ []) when is_list(options) do
    opts = construct_options(options)

    url =
      @eod_url <>
        symbol <>
        "?api_token=" <>
        api_key <>
        "&fmt=json&" <>
        opts

    case Web.get(url) do
      {:ok, json} -> Jason.decode(json)
      {:error, e} -> {:error, e}
    end
  end
end
