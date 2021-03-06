defmodule Carpooling.Rides do
  @moduledoc """
  The Rides context.
  """

  import Ecto.Query, warn: false
  alias Carpooling.{Rides.Ride, Repo, ZipCodes, Accounts.User}

  @doc """
  Returns the list of rides.

  ## Examples

      iex> list_rides()
      [%Ride{}, ...]

  """
  def list_rides do
    query =
      from ride in Ride,
        where: ride.is_verified == true and ride.seats > 0,
        limit: 10,
        order_by: [{:desc, :date}]

    Repo.all(query)
  end

  @doc """
  Gets a single ride.

  Raises `Ecto.NoResultsError` if the Ride does not exist.

  ## Examples

      iex> get_ride!(123)
      %Ride{}

      iex> get_ride!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ride!(id), do: Repo.get!(Ride, id)

  def get_ride(id) do
    driver_query = from u in User, where: u.role == "driver"

    Repo.get(Ride, id)
    |> Repo.preload(users: driver_query)
  end

  @doc """
  Creates a ride.

  ## Examples

      iex> create_ride(%{field: value})
      {:ok, %Ride{}}

      iex> create_ride(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ride(attrs \\ %{}) do
    %Ride{}
    |> Ride.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ride.

  ## Examples

      iex> update_ride(ride, %{field: new_value})
      {:ok, %Ride{}}

      iex> update_ride(ride, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ride(%Ride{} = ride, attrs) do
    ride
    |> Ride.changeset(attrs)
    |> Repo.update()
  end

  def update_ride_seats(%Ride{} = ride, :inc),
    do:
      ride
      |> change_ride_seats(ride.seats + 1)

  def update_ride_seats(%Ride{} = ride, :dec),
    do:
      ride
      |> change_ride_seats(ride.seats - 1)

  def verify_ride(%Ride{} = ride) do
    ride
    |> Ride.base_changeset(%{"is_verified" => true})
    |> Repo.update()
  end

  @doc """
  Deletes a ride.

  ## Examples

      iex> delete_ride(ride)
      {:ok, %Ride{}}

      iex> delete_ride(ride)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ride(%Ride{} = ride) do
    Repo.delete(ride)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ride changes.

  ## Examples

      iex> change_ride(ride)
      %Ecto.Changeset{data: %Ride{}}

  """
  def change_ride(%Ride{} = ride, attrs \\ %{}) do
    Ride.changeset(ride, attrs)
  end

  def get_rides_in_radius(origin_zipcode, destination_zipcode, radius_in_miles) do
    origin_zipcodes_in_radius = get_zipcodes_in_radius(origin_zipcode, radius_in_miles)
    destination_zipcodes_in_radius = get_zipcodes_in_radius(destination_zipcode, radius_in_miles)

    query =
      from ride in Ride,
        where:
          ride.origin_zipcode in ^origin_zipcodes_in_radius and
            ride.destination_zipcode in ^destination_zipcodes_in_radius and
            ride.is_verified == true and
            ride.seats > 0

    Repo.all(query)
  end

  defp get_zipcodes_in_radius(zipcode, radius_in_miles) do
    zipcode
    |> ZipCodes.get_zip_codes_in_radius(radius_in_miles)
    |> case do
      {:ok, zip_codes} -> Enum.map(zip_codes, & &1.zip_code)
      error -> error
    end
  end

  defp change_ride_seats(%Ride{} = ride, seats) do
    ride
    |> Ride.base_changeset(%{"seats" => seats})
    |> Repo.update()
  end
end
