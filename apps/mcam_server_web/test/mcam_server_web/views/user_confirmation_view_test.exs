defmodule McamServerWeb.UserConfirmationViewTest do
  use ExUnit.Case

  import McamServerWeb.UserConfirmationView

  describe "user email" do
    test "with user" do
      assert user_email(%{assigns: %{current_user: %{email: "bob@example.com"}}}) ==
               "bob@example.com"
    end

    test "without user" do
      assert user_email(%{assigns: %{}}) == ""
    end
  end
end
