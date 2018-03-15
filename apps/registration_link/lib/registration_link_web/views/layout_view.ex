defmodule RegistrationLinkWeb.LayoutView do
  use RegistrationLinkWeb, :view

  def version do
    Application.spec(:registration_link, :vsn)
  end
end
