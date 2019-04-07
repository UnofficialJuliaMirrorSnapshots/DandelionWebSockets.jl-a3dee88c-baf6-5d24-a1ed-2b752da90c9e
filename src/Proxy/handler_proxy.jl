using DandelionWebSockets
using DandelionWebSockets: SocketState
using DandelionWebSockets: STATE_CONNECTING, STATE_OPEN, STATE_CLOSING, STATE_CLOSED
import DandelionWebSockets: on_text, on_binary
import DandelionWebSockets: state_connecting, state_open, state_closing, state_closed

export WebSocketsHandlerProxy

"""
WebSocketsHandlerProxy is a proxy object that calls the users WebSocketsHandler callbacks on a
dedicated task.
The purpose is to run the WebSockets client logic on a different task than the users code. This way,
the logic can keep handling control messages even when the users code is long running.
"""
struct WebSocketsHandlerProxy <: WebSocketHandler
    callbacks::Channel{Any}
    handler::WebSocketHandler

    function WebSocketsHandlerProxy(handler::WebSocketHandler)
        proxy = new(Channel{Any}(Inf), handler)
        @async handler_task(proxy)
        proxy
    end
end

function handler_task(w::WebSocketsHandlerProxy)
    for notification in w.callbacks
        handler_proxy(w, notification)
    end
end

handler_proxy(w::WebSocketsHandlerProxy, text::String) = on_text(w.handler, text)
handler_proxy(w::WebSocketsHandlerProxy, payload::AbstractVector{UInt8}) = on_binary(w.handler, payload)
handler_proxy(w::WebSocketsHandlerProxy, connection::WebSocketConnection) = state_connecting(w.handler, connection)
function handler_proxy(w::WebSocketsHandlerProxy, state::SocketState)
    if state == STATE_OPEN
        state_open(w.handler)
    elseif state == STATE_CLOSING
        state_closing(w.handler)
    elseif state == STATE_CLOSED
        state_closed(w.handler)
    end
end

notify!(w::WebSocketsHandlerProxy, notification::Any) = put!(w.callbacks, notification)

on_text(w::WebSocketsHandlerProxy, payload::String) = notify!(w, payload)
on_binary(w::WebSocketsHandlerProxy, payload::AbstractVector{UInt8}) = notify!(w, payload)
state_connecting(w::WebSocketsHandlerProxy, connection::WebSocketConnection) = notify!(w, connection)
state_open(w::WebSocketsHandlerProxy) = notify!(w, STATE_OPEN)
state_closing(w::WebSocketsHandlerProxy) = notify!(w, STATE_CLOSING)
state_closed(w::WebSocketsHandlerProxy) = notify!(w, STATE_CLOSED)
stopproxy(w::WebSocketsHandlerProxy) = close(w.callbacks)