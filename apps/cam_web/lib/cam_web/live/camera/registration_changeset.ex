defmodule CamWeb.RegistrationChangeset do
  @moduledoc """
  Creates changeset for registration from settings, for use in forms.
  """

  import Ecto.Changeset

  @types %{password: :string, email: :string}
  @keys Map.keys(@types)
  @required @keys

  def changeset_for(params) do
    {%{}, @types}
    |> cast(params, @keys)
    |> validate_required(@required)
    |> validate_format(:email, ~r/.+@.+/, message: "does not look like an email")
  end

  def insert_changeset_for(params) do
    %{changeset_for(params) | action: :insert}
  end
end
