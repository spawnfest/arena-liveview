defmodule ArenaLiveview.ConnectedUser do
  defstruct uuid: ""
  alias ArenaLiveview.ConnectedUser

  def create_connected_user do
    %ConnectedUser{uuid: UUID.uuid4()}
  end
end
