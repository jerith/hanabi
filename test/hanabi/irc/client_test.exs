defmodule HanabiTest.IRC.Client do
  defmodule State do
    defstruct host: "localhost",
              port: Application.get_env(:hanabi, :port),
              pass: "",
              nick: "lambda",
              user: "lambda",
              name: "Lamb Da",
              client: nil,
              handlers: []
  end

  use ExUnit.Case

  setup_all do
    {:ok, _pid} = ExIrc.start!

    :ok
  end

  setup do
    {:ok, client}  = ExIrc.start_link!()
    state = struct(State, client: client)
    ExIrc.Client.add_handler state.client, self()

    [state: state]
  end

  ###

  def wait_for(message_type) do
    received = receive do
      msg -> msg
    after
      1_000 -> :timeout
    end

    cond do
      is_tuple(received) && (elem(received, 0) == message_type) -> received
      received == message_type -> received
      received == :timeout -> :timeout
      true -> wait_for(message_type)
    end
  end

  defp connect(state) do
    ExIrc.Client.connect! state.client, state.host, state.port
    state
  end

  defp logon(state) do
    ExIrc.Client.logon state.client, state.pass, state.nick, state.user, state.name
    state
  end

  ###

  #test "IRC TCP socket" do
  #  server = String.to_charlist("127.0.0.1")
  #  port = Application.get_env :hanabi, :port
  #  {status, _socket} = :gen_tcp.connect(server, port, [:binary])
  #
  #  assert status == :ok
  #end

  test "IRC client connection (TCP socket)", context do
    state = context[:state]

    state |> connect()
    tuple = wait_for(:connected)

    assert tuple == {:connected, state.host, state.port}
  end

  @tag :todo # RLC_WELCOME required but not yet present in RFC1459
  test "IRC client login", context do
    state = context[:state]

    state |> connect()
          |> logon()
    tuple = wait_for(:logged_in)

    assert tuple == :logged_in
  end

  @tag :todo
  test "IRC client logout"
  @tag :todo
  test "IRC client PING"

  @tag :todo
  test "IRC client JOIN"
  @tag :todo
  test "IRC client PART"
  @tag :todo
  test "IRC client TOPIC"

  @tag :todo
  test "IRC client send PRIVMSG"
  @tag :todo
  test "IRC client receive PRIVMSG"
end
