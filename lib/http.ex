defmodule EodhistoricaldataEx.Http do
  @moduledoc false
  def get(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

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
end
