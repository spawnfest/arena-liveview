defmodule ArenaLiveview.ConnectedUser do
  defstruct uuid: ""
  alias ArenaLiveview.ConnectedUser
  alias Identicon

  def create_connected_user do
    %ConnectedUser{uuid: UUID.uuid4()}
  end

  def create_user_avatar(uuid) do
    # avatars_path = Path.join([:code.priv_dir(:arena_liveview) , "images/avatars"]);
    avatars_path = Path.absname("priv/static/images/avatars")
    Identicon.main(uuid, "#{avatars_path}/#{uuid}")

  end
end
