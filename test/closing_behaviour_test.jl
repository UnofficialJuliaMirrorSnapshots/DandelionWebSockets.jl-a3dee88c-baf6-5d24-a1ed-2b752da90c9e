using Test
using DandelionWebSockets: AbstractFrameWriter, CloseStatus
using DandelionWebSockets: FailTheConnectionBehaviour, closetheconnection, ClientInitiatedCloseBehaviour
using DandelionWebSockets: CLOSE_STATUS_PROTOCOL_ERROR, CLOSE_STATUS_NORMAL
using DandelionWebSockets: FrameFromServer, clientprotocolinput, ClientProtocolInput, protocolstate
using DandelionWebSockets: AbnormalNoCloseResponseReceived, ServerInitiatedCloseBehaviour
using DandelionWebSockets: CLOSE_STATUS_ABNORMAL_CLOSE, closestatusandreason
import DandelionWebSockets: closesocket, AbnormalSocketNotClosedByServer, isclosedcleanly

mutable struct FakeFrameWriter <: AbstractFrameWriter
    issocketclosed::Bool
    closestatuses::Vector{CloseStatus}
    closereasons::Vector{String}

    FakeFrameWriter() = new(false, [], [])
end

closesocket(w::FakeFrameWriter) = w.issocketclosed = true

send(w::FakeFrameWriter, isfinal::Bool, opcode::Opcode, payload::Vector{UInt8}) = nothing

function sendcloseframe(w::FakeFrameWriter, status::CloseStatus; reason::String="")
    push!(w.closestatuses, status)
    push!(w.closereasons, reason)
end

# A fake ClientProtocolInput, used to prove that the ClosingBehaviour can handle any input.
struct FakeClientProtocolInput <: ClientProtocolInput end

# Requirement
# @7_1_4-3 Unclean close
# @7_1_5-1 WebSocket Connection Close Code sent by Close frame
# @7_1_5-2 WebSocket Connection Close Code sent by Close frame with no status code
# @7_1_5-3 WebSocket Connection Close Code with no Close frame
# @7_1_6-1 WebSocket Connection Close Reason with reason
# @7_1_6-2 WebSocket Connection Close Reason without reason

@testset "Fail the Connection    " begin
    @testset "Closes the socket" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        fail = FailTheConnectionBehaviour(framewriter, handler, CLOSE_STATUS_PROTOCOL_ERROR)

        closetheconnection(fail)

        @test framewriter.issocketclosed == true
    end

    @testset "Sends a frame if the socket is probably up" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        fail = FailTheConnectionBehaviour(framewriter, handler, CLOSE_STATUS_PROTOCOL_ERROR)

        closetheconnection(fail)

        @test framewriter.closestatuses[1] == CLOSE_STATUS_PROTOCOL_ERROR
    end

    @testset "Does not send a frame if the socket is probably down" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        fail = FailTheConnectionBehaviour(framewriter, handler, CLOSE_STATUS_PROTOCOL_ERROR;
                                          issocketprobablyup=false)

        closetheconnection(fail)

        @test framewriter.closestatuses == []
    end

    @testset "A reason is provided; The reason is present in the Close frame" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        fail = FailTheConnectionBehaviour(framewriter, handler, CLOSE_STATUS_PROTOCOL_ERROR;
                                          reason="Some reason")

        closetheconnection(fail)

        @test framewriter.closereasons[1] == "Some reason"
    end

    @testset "The state transitions to CLOSED" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        fail = FailTheConnectionBehaviour(framewriter, handler, CLOSE_STATUS_PROTOCOL_ERROR)

        closetheconnection(fail)

        @test handler.state == STATE_CLOSED
    end

    @testset "Close frame is received; No Close frame is sent in response" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        fail = FailTheConnectionBehaviour(framewriter, handler, CLOSE_STATUS_PROTOCOL_ERROR)

        closeframe = Frame(true, OPCODE_CLOSE, false, 0, 0, b"", b"")
        clientprotocolinput(fail, FrameFromServer(closeframe))

        @test length(framewriter.closestatuses) == 0
    end

    @testset "Can handle any type of ClientProtocolInput" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        fail = FailTheConnectionBehaviour(framewriter, handler, CLOSE_STATUS_PROTOCOL_ERROR)

        clientprotocolinput(fail, FakeClientProtocolInput())
    end

    @testset "The state is STATE_CLOSED" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        fail = FailTheConnectionBehaviour(framewriter, handler, CLOSE_STATUS_PROTOCOL_ERROR)

        closetheconnection(fail)

        @test protocolstate(fail) == STATE_CLOSED
    end

    @testset "A failed connection is never closed cleanly" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        fail = FailTheConnectionBehaviour(framewriter, handler, CLOSE_STATUS_PROTOCOL_ERROR)

        closetheconnection(fail)

        @test isclosedcleanly(fail) == false
    end

    @testset "WebSocket Connection Close Code is 1006 (Abnormal Close)" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        fail = FailTheConnectionBehaviour(framewriter, handler, CLOSE_STATUS_PROTOCOL_ERROR)

        closetheconnection(fail)

        @test closestatusandreason(fail).status == CLOSE_STATUS_ABNORMAL_CLOSE
    end

    @testset "WebSocket Connection Close Reason is the empty string" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        fail = FailTheConnectionBehaviour(framewriter, handler, CLOSE_STATUS_PROTOCOL_ERROR)

        closetheconnection(fail)

        @test closestatusandreason(fail).reason == ""
    end
end

@testset "Client initiated close " begin
    @testset "Close status code is by default CLOSE_STATUS_NORMAL" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        closetheconnection(normal)

        @test framewriter.closestatuses[1] == CLOSE_STATUS_NORMAL
    end

    @testset "An optional close status can be specified" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler; status=CLOSE_STATUS_GOING_AWAY)

        closetheconnection(normal)

        @test framewriter.closestatuses[1] == CLOSE_STATUS_GOING_AWAY
    end

    @testset "An optional reason can be specified" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler; reason="Some reason")

        closetheconnection(normal)

        @test framewriter.closereasons[1] == "Some reason"
    end

    @testset "After a Close frame has been sent, the user is notified that the state is CLOSING" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        closetheconnection(normal)

        @test handler.state == STATE_CLOSING
    end

    @testset "After a Close frame has been sent, the client state is CLOSING" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        closetheconnection(normal)

        @test protocolstate(normal) == STATE_CLOSING
    end

    @testset "A Close frame response is received, the client state is still CLOSING" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        closetheconnection(normal)
        closeframe = Frame(true, OPCODE_CLOSE, false, 0, 0, b"", b"")
        clientprotocolinput(normal, FrameFromServer(closeframe))

        @test protocolstate(normal) == STATE_CLOSING
    end

    @testset "A Close frame response is received, and socket is closed; the handler is notified of state CLOSED" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        closetheconnection(normal)
        closeframe = Frame(true, OPCODE_CLOSE, false, 0, 0, b"", b"")
        clientprotocolinput(normal, FrameFromServer(closeframe))
        clientprotocolinput(normal, SocketClosed())

        @test handler.state == STATE_CLOSED
    end

    @testset "A second Close frame is received in state CLOSED; the handler is not notified" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        closetheconnection(normal)
        closeframe = Frame(true, OPCODE_CLOSE, false, 0, 0, b"", b"")
        clientprotocolinput(normal, FrameFromServer(closeframe))
        clientprotocolinput(normal, SocketClosed())
        # Reset the handler state to a known value, to ensure that it is not overwritten
        handler.state = SocketState(:closednotcalledagain)

        # Send a second Close frame
        clientprotocolinput(normal, FrameFromServer(closeframe))

        @test handler.state == SocketState(:closednotcalledagain)
    end

    @testset "The socket is not closed by the client after a normal close" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        closetheconnection(normal)
        closeframe = Frame(true, OPCODE_CLOSE, false, 0, 0, b"", b"")
        clientprotocolinput(normal, FrameFromServer(closeframe))
        clientprotocolinput(normal, SocketClosed())

        @test framewriter.issocketclosed == false
    end

    @testset "The socket _is_ closed by the client after no close response was received" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        closetheconnection(normal)
        closeframe = Frame(true, OPCODE_CLOSE, false, 0, 0, b"", b"")
        clientprotocolinput(normal, SocketClosed())
        clientprotocolinput(normal, AbnormalNoCloseResponseReceived())

        @test framewriter.issocketclosed == true
    end

    @testset "The behaviour may receive any client protocol input" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        clientprotocolinput(normal, FakeClientProtocolInput())
    end

    @testset "A non-Close frame is receiving during state CLOSING; state is not closed" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        closetheconnection(normal)
        textframe = Frame(true, OPCODE_TEXT, false, 0, 0, b"", b"")
        clientprotocolinput(normal, FrameFromServer(textframe))

        @test protocolstate(normal) == STATE_CLOSING
        @test handler.state == STATE_CLOSING
    end

    @testset "Close sent and received, and socket is closed; Close was done cleanly" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        closetheconnection(normal)
        closeframe = Frame(true, OPCODE_CLOSE, false, 0, 0, b"", b"")
        clientprotocolinput(normal, FrameFromServer(closeframe))
        clientprotocolinput(normal, SocketClosed())

        @test isclosedcleanly(normal)
    end

    @testset "Close sent but not received, and socket is closed; Close was _NOT_ done cleanly" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        closetheconnection(normal)
        clientprotocolinput(normal, SocketClosed())

        @test isclosedcleanly(normal) == false
    end

    @testset "Close sent and received, socket is not yet closed; Close was _NOT_ done cleanly" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        closetheconnection(normal)
        closeframe = Frame(true, OPCODE_CLOSE, false, 0, 0, b"", b"")
        clientprotocolinput(normal, FrameFromServer(closeframe))

        @test isclosedcleanly(normal) == false
    end

    @testset "First Close frame contains no status code; Connection Close Code is 1005 (No Status)" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        closetheconnection(normal)
        closeframe = Frame(true, OPCODE_CLOSE, false, 0, 0, b"", b"")
        clientprotocolinput(normal, FrameFromServer(closeframe))
        clientprotocolinput(normal, SocketClosed())

        @test closestatusandreason(normal).status == CLOSE_STATUS_NO_STATUS
    end

    @testset "First Close frame contains no status code; Connection Close Reason is empty string" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        closetheconnection(normal)
        closeframe = Frame(true, OPCODE_CLOSE, false, 0, 0, b"", b"")
        clientprotocolinput(normal, FrameFromServer(closeframe))
        clientprotocolinput(normal, SocketClosed())

        @test closestatusandreason(normal).reason == ""
    end

    @testset "First Close frame has status Going Away; Connection Close Code is Going Away" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        payload = closeframepayload(CLOSE_STATUS_GOING_AWAY)
        closetheconnection(normal)
        closeframe = Frame(true, OPCODE_CLOSE, false, length(payload), 0, b"", payload)
        clientprotocolinput(normal, FrameFromServer(closeframe))
        clientprotocolinput(normal, SocketClosed())

        @test closestatusandreason(normal).status == CLOSE_STATUS_GOING_AWAY
    end

    @testset "First Close frame has status Normal; Connection Close Code is Normal" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        payload = closeframepayload(CLOSE_STATUS_NORMAL)
        closetheconnection(normal)
        closeframe = Frame(true, OPCODE_CLOSE, false, length(payload), 0, b"", payload)
        clientprotocolinput(normal, FrameFromServer(closeframe))
        clientprotocolinput(normal, SocketClosed())

        @test closestatusandreason(normal).status == CLOSE_STATUS_NORMAL
    end

    @testset "First Close Frame has reason 'Hello'; Connection Close Reason is 'Hello'" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        payload = closeframepayload(CLOSE_STATUS_NORMAL; reason = "Hello")
        closetheconnection(normal)
        closeframe = Frame(true, OPCODE_CLOSE, false, length(payload), 0, b"", payload)
        clientprotocolinput(normal, FrameFromServer(closeframe))
        clientprotocolinput(normal, SocketClosed())

        @test closestatusandreason(normal).reason == "Hello"
    end

    @testset "First Close frame has status NORMAL, second has GOING AWAY; Close status is the first" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        closetheconnection(normal)

        # First frame has status Normal
        payload = closeframepayload(CLOSE_STATUS_NORMAL)
        closeframe = Frame(true, OPCODE_CLOSE, false, length(payload), 0, b"", payload)
        clientprotocolinput(normal, FrameFromServer(closeframe))

        # Second has status Going Away
        payload = closeframepayload(CLOSE_STATUS_GOING_AWAY)
        closeframe = Frame(true, OPCODE_CLOSE, false, length(payload), 0, b"", payload)
        clientprotocolinput(normal, FrameFromServer(closeframe))

        clientprotocolinput(normal, SocketClosed())

        @test closestatusandreason(normal).status == CLOSE_STATUS_NORMAL
    end

    @testset "No Close frame received; Close status is Abnormal Close" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        payload = closeframepayload(CLOSE_STATUS_NORMAL; reason = "Hello")
        closetheconnection(normal)
        clientprotocolinput(normal, SocketClosed())

        @test closestatusandreason(normal).status == CLOSE_STATUS_ABNORMAL_CLOSE
    end

    @testset "No Close frame received; Close reason is empty string" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        normal = ClientInitiatedCloseBehaviour(framewriter, handler)

        payload = closeframepayload(CLOSE_STATUS_NORMAL; reason = "Hello")
        closetheconnection(normal)
        clientprotocolinput(normal, SocketClosed())

        @test closestatusandreason(normal).reason == ""
    end
end

@testset "Server initiated close " begin
    @testset "The handler is notified of state CLOSING" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL))

        closetheconnection(behaviour)

        @test handler.state == STATE_CLOSING
    end

    @testset "The protocol state is CLOSING before socket is closed" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL))

        closetheconnection(behaviour)

        @test protocolstate(behaviour) == STATE_CLOSING
    end

    # Requirement
    # @5_5_1-5 Respond to Close frame
    # @5_5_1-6 Response time for Close frame

    @testset "The client responds with a Close frame with the same status as the received Close" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL))

        closetheconnection(behaviour)

        @test framewriter.closestatuses[1] == CLOSE_STATUS_NORMAL
    end

    @testset "The client responds with a Close frame with the same status as the received Close, 2" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_GOING_AWAY))

        closetheconnection(behaviour)

        @test framewriter.closestatuses[1] == CLOSE_STATUS_GOING_AWAY
    end

    @testset "The client responds with empty reason" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL))

        closetheconnection(behaviour)

        @test framewriter.closereasons[1] == ""
    end

    @testset "When the socket is closed, the connection has state CLOSED" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL))

        closetheconnection(behaviour)
        clientprotocolinput(behaviour, SocketClosed())

        @test protocolstate(behaviour) == STATE_CLOSED
    end

    @testset "When the socket is closed, the handler is notified of state CLOSED" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL))

        closetheconnection(behaviour)
        clientprotocolinput(behaviour, SocketClosed())

        @test handler.state == STATE_CLOSED
    end

    @testset "The behaviour can take any ClientProtocolInput" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL))

        clientprotocolinput(behaviour, FakeClientProtocolInput())
    end

    @testset "The socket is not closed by the behaviour, under normal circumstances" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL))

        closetheconnection(behaviour)

        @test framewriter.issocketclosed == false
    end

    @testset "The socket is closed abnormally when the server has not closed it" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL))

        closetheconnection(behaviour)
        clientprotocolinput(behaviour, AbnormalSocketNotClosedByServer())

        @test framewriter.issocketclosed
    end

    @testset "The socket wasn't closed properly by the server; state is still CLOSED" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL))

        closetheconnection(behaviour)
        clientprotocolinput(behaviour, AbnormalSocketNotClosedByServer())

        @test protocolstate(behaviour) == STATE_CLOSED
    end

    @testset "The socket wasn't closed properly by the server; handler is notified of state CLOSED" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL))

        closetheconnection(behaviour)
        clientprotocolinput(behaviour, AbnormalSocketNotClosedByServer())

        @test handler.state == STATE_CLOSED
    end

    @testset "The socket wasn't closed properly by the server; Close is not clean" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL))

        closetheconnection(behaviour)
        clientprotocolinput(behaviour, AbnormalSocketNotClosedByServer())

        @test isclosedcleanly(behaviour) == false
    end

    @testset "Close sent and socket is closed; Close is done cleanly" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL))

        closetheconnection(behaviour)
        clientprotocolinput(behaviour, SocketClosed())

        @test isclosedcleanly(behaviour)
    end

    @testset "Close sent but socket not closed yet; Close is _NOT_ done cleanly" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL))

        closetheconnection(behaviour)

        @test isclosedcleanly(behaviour) == false
    end

    @testset "First Close frame has status Normal; Connection Close Code is Normal" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL))

        closetheconnection(behaviour)
        clientprotocolinput(behaviour, SocketClosed())

        @test closestatusandreason(behaviour).status == CLOSE_STATUS_NORMAL
    end

    @testset "First close frame has status Going Away; Connection Close Code is Going Away" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_GOING_AWAY))

        closetheconnection(behaviour)
        clientprotocolinput(behaviour, SocketClosed())

        @test closestatusandreason(behaviour).status == CLOSE_STATUS_GOING_AWAY
    end

    @testset "First Close frame has no reason; Connection Close Reason is empty" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL))

        closetheconnection(behaviour)
        clientprotocolinput(behaviour, SocketClosed())

        @test closestatusandreason(behaviour).reason == ""
    end

    @testset "First Close frame has reason Hello; Connection Close Reason is Hello" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL; reason = "Hello"))

        closetheconnection(behaviour)
        clientprotocolinput(behaviour, SocketClosed())

        @test closestatusandreason(behaviour).reason == "Hello"
    end

    @testset "First Close frame has status Normal, second has status Going Away; Connection Close Status it the first" begin
        framewriter = FakeFrameWriter()
        handler = WebSocketHandlerStub()
        behaviour = ServerInitiatedCloseBehaviour(framewriter, handler, servercloseframe(CLOSE_STATUS_NORMAL))

        closetheconnection(behaviour)
        clientprotocolinput(behaviour, FrameFromServer(servercloseframe(CLOSE_STATUS_GOING_AWAY)))
        clientprotocolinput(behaviour, SocketClosed())

        @test closestatusandreason(behaviour).status == CLOSE_STATUS_NORMAL
    end
end