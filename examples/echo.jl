# Example of DandelionWebSocket.jl:
# Send some text and binary frames to ws://echo.websocket.org,
# which echoes them back.

using DandelionWebSockets

# Explicitly import the callback functions that we're going to add more methods for.
import DandelionWebSockets: on_text, on_binary,
                            state_connecting, state_open, state_closing, state_closed

# A simple WebSocketHandler which sends a few messages, receives echoes back, and then sends a stop
# signal via a channel when it's done.
mutable struct EchoHandler <: WebSocketHandler
    connection::Union{WebSocketConnection, Nothing}
    stop_channel::Channel{Any}

    EchoHandler(chan::Channel{Any}) = new(nothing, chan)
end

# These are called when you get text/binary frames, respectively.
on_text(::EchoHandler, s::String)  = println("Received text: $s")
on_binary(::EchoHandler, data::AbstractVector{UInt8}) = println("Received data: $(String(data))")

# These are called when the WebSocket state changes.

state_closing(::EchoHandler)    = println("State: CLOSING")
function state_connecting(e::EchoHandler, c::WebSocketConnection)
    println("State: CONNECTING")
    e.connection = c
end

# Called when the connection is open, and ready to send/receive messages.
function state_open(handler::EchoHandler)
    println("State: OPEN")

    # Send some text frames, and a binary frame.
    @async begin
        texts = ["Hello", "world", "!"]

        for text in texts
            println("Sending  text: $text")
            send_text(handler.connection, text)
            sleep(0.5)
        end

        send_binary(handler.connection, b"Hello, binary!")
        sleep(0.5)

        # Signal the script that we're done sending all messages.
        # The script will then close the connection.
        put!(stop_chan, true)
    end
end

function state_closed(::EchoHandler)
    println("State: CLOSED")

    # Signal the script that the connection is closed.
    put!(stop_chan, true)
end

stop_chan = Channel{Any}(3)

# Create a WSClient, which we can use to connect and send frames.
client = WSClient()

handler = EchoHandler(stop_chan)

if length(ARGS) == 0
    uri = "ws://echo.websocket.org"
elseif length(ARGS) == 1
    uri = ARGS[1]
else
    println("Expect zero or one arguments!")
    exit(1)
end

println("Connecting to $uri... ")

wsconnect(client, uri, handler)

println("Connected.")

# The first message on `stop_chan` indicates that all messages have been sent, and we should
# close the connection.
take!(stop_chan)

stop(handler.connection)

# The second message on `stop_chan` indicates that the connection is closed, so we can exit.
take!(stop_chan)
