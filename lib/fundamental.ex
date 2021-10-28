defmodule EodhistoricaldataEx.Fundamentals do
  @moduledoc """
  Documentation for `EodhistoricaldataEx`.
  """

  @fundamental_url "https://eodhistoricaldata.com/api/fundamentals/"

  alias EodhistoricaldataEx.Web

  defp construct_filter(list) do
    "&filter=" <> Enum.join(list, ",")
  end

  @doc """
  Get data from the fundamental api.

  Returns `{:ok, %{}}` or `{:error, :e}`.

  Filters will be directly passed to the eodhistoricaldata api.
  For more informations about filters have a look at
  https://eodhistoricaldata.com/financial-apis/stock-etfs-fundamental-data-feeds/#Filter_Fields_and_WEBSERVICE_support

  ## Examples

      iex> EodhistoricaldataEx.Fundamentals.fundamentals("apikey", "aapl")
      {:ok, %{}}

      iex> EodhistoricaldataEx.Fundamentals.fundamentals("apikey", "aapl", ["General"])
      {:ok, %{}}

      iex> EodhistoricaldataEx.Fundamentals.fundamentals("apikey", "aapl", ["General::Code"], ["Highlights"])
      {:ok, %{}}

      iex> EodhistoricaldataEx.Fundamentals.fundamentals("invalid", "aapl", ["General"])
      {:error, :forbidden}

  """
  def fundamentals(api_key, symbol, filter \\ []) when is_list(filter) do
    url =
      @fundamental_url <>
        symbol <> "?api_token=" <> api_key <> construct_filter(filter)

    case Web.get(url) do
      {:ok, json} -> Jason.decode(json)
      {:error, e} -> {:error, e}
    end
  end
end
