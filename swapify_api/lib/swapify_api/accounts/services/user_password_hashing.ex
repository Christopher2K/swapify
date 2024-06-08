defmodule SwapifyApi.Accounts.Services.UserPasswordHashing do
  @moduledoc "Hashing tools for User password management"

  def hash(password), do: Argon2.hash_pwd_salt(password)

  def verify(password_input, hash), do: Argon2.verify_pass(password_input, hash)
end

