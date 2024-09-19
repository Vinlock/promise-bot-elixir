defmodule PromiseBotTest do
  use ExUnit.Case
  doctest PromiseBot

  test "greets the world" do
    assert PromiseBot.hello() == :world
  end
end
