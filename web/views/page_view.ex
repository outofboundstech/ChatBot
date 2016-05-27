defmodule ChatBot.PageView do
  use ChatBot.Web, :view

  def render("auth.json", %{bearer_token: bearer_token}) do
    %{bearer_token: bearer_token}
  end
end
