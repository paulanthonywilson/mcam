defmodule ServerComms.ApiTest do
  use ExUnit.Case, async: true

  import Mox
  alias ServerComms.Api
  alias ServerComms.Api.MockRequest

  setup :verify_on_exit!

  describe "registration" do
    test "registration params" do
      MockRequest
      |> expect(:post, 1, fn url, body, headers, _opts ->
        assert url =~ "api/register_camera"

        assert {:ok,
                %{"email" => "bob@bob.com", "password" => "iambob", "board_id" => "camera42"}} ==
                 Jason.decode(body)

        assert headers == [{"Accept", "application/json"}, {"Content-Type", "application/json"}]

        {:ok, %HTTPoison.Response{status_code: 200, body: "12345"}}
      end)

      Api.register("bob@bob.com", "iambob", "camera42")
    end

    test "successful registration sets the email and registration token in the configuration" do
      Configure.subscribe()

      MockRequest
      |> expect(:post, 1, fn _url, _body, _headers, _opts ->
        {:ok, %HTTPoison.Response{status_code: 200, body: Jason.encode!("token12345")}}
      end)

      assert :ok == Api.register("bobsuccess@bob.com", "iambob", "camera42")

      assert_receive {:fake_setting_set, :email, "bobsuccess@bob.com"}
      assert_receive {:fake_setting_set, :registration_token, "token12345"}
    end

    test "no changes made on registration failure" do
      Configure.subscribe()

      MockRequest
      |> expect(:post, 1, fn _url, _body, _headers, _opts ->
        {:ok, %HTTPoison.Response{status_code: 400, body: ""}}
      end)

      assert {:error, _} = Api.register("bobfailure@bob.com", "iambob", "camera42")
      refute_receive {:fake_setting_set, :email, "bobsuccess@bob.com"}
    end

    test "authentication failure" do
      MockRequest
      |> expect(:post, 1, fn _url, _body, _headers, _opts ->
        {:ok, %HTTPoison.Response{status_code: 401, body: ""}}
      end)

      assert {:error, :authentication} == Api.register("bob@bob.com", "nope", "cam1")
    end

    test "quota exceeded" do
      MockRequest
      |> expect(:post, 1, fn _url, _body, _headers, _opts ->
        {:ok, %HTTPoison.Response{status_code: 402, body: ""}}
      end)

      assert {:error, :quota_exceeded} == Api.register("bob@bob.com", "nope", "cam1")
    end
  end

  describe "posting unregistered" do
    test "with ip address" do
      MockRequest
      |> expect(:post, 1, fn url, body, headers, _opts ->
        assert url =~ "api/unregistered_camera"

        assert {:ok, %{"hostname" => "the_camera", "local_ip" => "192.168.0.22"}} ==
                 Jason.decode(body)

        assert headers == [{"Accept", "application/json"}, {"Content-Type", "application/json"}]
        {:ok, %HTTPoison.Response{status_code: 200}}
      end)

      assert :ok == Api.post_unregistered('the_camera', {192, 168, 0, 22})
    end

    test "with nil ip address does noting" do
      expect(MockRequest, :post, 0, fn _, _, _, _ -> nil end)
      assert :ok == Api.post_unregistered('the_camera', nil)
    end
  end
end
