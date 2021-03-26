defmodule KousaTest.Broth.Ws.FetchInviteListTest do
  use ExUnit.Case, async: true
  use Kousa.Support.EctoSandbox

  alias Beef.Schemas.User
  alias Beef.Users
  alias Broth.WsClient
  alias Broth.WsClientFactory
  alias Kousa.Support.Factory

  require WsClient

  setup do
    user = Factory.create(User)
    ws_client = WsClientFactory.create_client_for(user)

    {:ok, user: user, ws_client: ws_client}
  end

  describe "the websocket fetch_invite_list operation" do
    test "gets an empty list when you haven't invited anyone", t do
      WsClient.send_msg(t.ws_client, "fetch_invite_list", %{"cursor" => 0})
      WsClient.assert_frame("fetch_invite_list_done", %{"users" => []})
    end

    test "returns one user whe you have invited them", t do
      # create a follower user that is logged in.
      follower = %{id: follower_id} = Factory.create(User)
      WsClientFactory.create_client_for(follower)
      Kousa.Follow.follow(follower_id, t.user.id, true)

      WsClient.send_msg(t.ws_client, "invite_to_room", %{"userId" => follower_id})

      WsClient.send_msg(t.ws_client, "fetch_invite_list", %{"cursor" => 0})
      WsClient.assert_frame("fetch_invite_list_done", %{"users" => [%{"id" => ^follower_id}]})
    end
  end
end
