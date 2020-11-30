defmodule McamServer.Cameras.Camera do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "cameras" do
    field :board_id, :string
    field :owner_id, :id

    timestamps()
  end

  @doc false
  def changeset(camera, attrs) do
    camera
    |> cast(attrs, [:board_id])
    |> validate_required([:board_id])
    |> unique_constraint([:owner_id, :board_id], name: :cameras_board_id_owner_id_index)
  end
end
