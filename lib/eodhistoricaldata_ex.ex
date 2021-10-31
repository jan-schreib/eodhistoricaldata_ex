defmodule EodhistoricaldataEx do
  @fundamental_url "https://eodhistoricaldata.com/api/fundamentals/"
  @eod_url "https://eodhistoricaldata.com/api/eod/"
  @real_time_url "https://eodhistoricaldata.com/api/real-time/"

  # Helpers
  defp construct_filter(list) do
    "&filter=" <> Enum.join(list, ",")
  end

  defp get(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode(body)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :notfound}

      {:ok, %HTTPoison.Response{status_code: 403}} ->
        {:error, :forbidden}

      {:ok, %HTTPoison.Response{status_code: 401}} ->
        {:ok, :unauthenticated}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp construct_options(list) do
    keywords = [:from, :to, :period, :order]

    Enum.map(keywords, fn x -> {x, Keyword.get(list, x)} end)
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.map(fn {k, v} -> Atom.to_string(k) <> "=" <> to_string(v) end)
    |> Enum.join("&")
  end

  @doc """
  Get data from the fundamental api.

  Returns `{:ok, %{}}` or `{:error, :e}`.

  Filters will be directly passed to the eodhistoricaldata api.
  For more informations about filters have a look at
  https://eodhistoricaldata.com/financial-apis/stock-etfs-fundamental-data-feeds/#Filter_Fields_and_WEBSERVICE_support

  ## Examples

      iex> EodhistoricaldataEx.fundamentals("apikey", "aapl")
      {:ok, %{}}

      iex> EodhistoricaldataEx.fundamentals("apikey", "aapl", ["General"])
      {:ok, %{}}

      iex> EodhistoricaldataEx.fundamentals("apikey", "aapl", ["General::Code"], ["Highlights"])
      {:ok, %{}}

      iex> EodhistoricaldataEx.fundamentals("invalid", "aapl", ["General"])
      {:error, :forbidden}

  """
  def fundamentals(api_key, symbol, filter \\ []) when is_list(filter) do
    url =
      @fundamental_url <>
        symbol <> "?api_token=" <> api_key <> construct_filter(filter)

    get(url)
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

      iex> EodhistoricaldataEx.eod("apikey", "aapl")
      {:ok, %{}}

      iex> EodhistoricaldataEx.eod("apikey", "aapl", [from: "2000-01-01", to: "2001-01-01", period: "d", order: "a"])
      {:ok, %{}}

      iex> EodhistoricaldataEx.eod("invalid", "aapl")
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

    get(url)
  end

  @doc """
  Get delayed real time data from the real time api.

  Returns `{:ok, %{}}` or `{:error, :e}`.

  ## Examples

      iex> EodhistoricaldataEx.real_time("apikey", "aapl")
      {:ok, %{}}

      iex> EodhistoricaldataEx.real_time("invalid", "aapl")
      {:error, :forbidden}

  """
  def real_time(api_key, symbol) do
    url = @real_time_url <> symbol <> "?api_token=" <> api_key <> "&fmt=json"

    get(url)
  end

  @doc """
  Get delayed real time data from the real time api.

  Returns `{:ok, []` or `{:error, :e}`.

  ## Examples

      iex> EodhistoricaldataEx.real_time("apikey", ["aapl", "msft"])
      {:ok, []}

      iex> EodhistoricaldataEx.real_time("invalid", ["aapl", "msft"])
      {:error, :forbidden}

  """

  def real_time_bulk(api_key, symbols) when is_list(symbols) do
    url =
      @real_time_url <>
        hd(symbols) <>
        "?api_token=" <> api_key <> "&fmt=json" <> "&s=" <> Enum.join(tl(symbols), ",")

    get(url)
  end
end
