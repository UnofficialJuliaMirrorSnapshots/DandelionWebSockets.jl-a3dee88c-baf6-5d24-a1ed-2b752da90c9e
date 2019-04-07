using DandelionWebSockets
using DandelionWebSockets: STATE_OPEN, STATE_CONNECTING, STATE_CLOSING, STATE_CLOSED
using DandelionWebSockets: SocketState, AbstractPonger, SendTextFrame, FrameFromServer
using DandelionWebSockets: masking!
import DandelionWebSockets: write, pong_received, ping_sent
import Base: write, close
using Random
import Random: rand

"InvalidPrecondition signals that a precondition to running the test was not met."
struct InvalidPrecondition <: Exception
    message::String
end

#
# WebSocketHandlerStub
#

"WebSocketHandlerStub acts as a handler for the tests, storing state and incoming messages."
mutable struct WebSocketHandlerStub <: WebSocketHandler
    state::SocketState
    texts::Vector{String}
    binaries::Vector{Vector{UInt8}}
    statesequence::Vector{SocketState}

    WebSocketHandlerStub() = new(STATE_CONNECTING, Vector{String}(), Vector{Vector{UInt8}}(), [])
end

function state_closed(h::WebSocketHandlerStub)
    h.state = STATE_CLOSED
    push!(h.statesequence, STATE_CLOSED)
end

function state_closing(h::WebSocketHandlerStub)
    h.state = STATE_CLOSING
    push!(h.statesequence, STATE_CLOSING)
end

function state_connecting(h::WebSocketHandlerStub)
    h.state = STATE_CONNECTING
    push!(h.statesequence, STATE_CONNECTING)
end

function state_open(h::WebSocketHandlerStub)
    h.state = STATE_OPEN
    push!(h.statesequence, STATE_OPEN)
end

on_text(h::WebSocketHandlerStub, text::String) = push!(h.texts, text)
on_binary(h::WebSocketHandlerStub, binary::AbstractVector{UInt8}) = push!(h.binaries, binary)


function getsingletext(h::WebSocketHandlerStub)
    if length(h.texts) == 0
        throw(InvalidPrecondition("exactly one text was expected, but none were received"))
    end
    if length(h.texts) > 1
        throw(InvalidPrecondition("exactly one text was expected, but more than one was received: $(h.texts)"))
    end

    h.texts[1]
end

function gettextat(h::WebSocketHandlerStub, i::Int)
    if length(h.texts) < i
        throw(InvalidPrecondition(
            "require text at index $i, but only $(length(h.texts)) messages received"))
    end
    h.texts[i]
end

function getbinaryat(h::WebSocketHandlerStub, i::Int)
    if length(h.binaries) < i
        throw(InvalidPrecondition(
            "require binary at index $i, but only $(length(h.binaries)) messages received"))
    end
    h.binaries[i]
end

#
# WriterStub
#

mutable struct FrameIOStub <: IO
    frames::Vector{Frame}
    isopen::Bool

    FrameIOStub() = new(Vector{Frame}(), true)
end

write(w::FrameIOStub, frame::Frame) = push!(w.frames, frame)
close(w::FrameIOStub) = w.isopen = false

function getframe(w::FrameIOStub, i::Int)
    if length(w.frames) < i
        throw(InvalidPrecondition("required frame at index $i, but only has $(length(w.frames))"))
    end
    w.frames[i]
end

function getframeunmasked(w::FrameIOStub, i::Int, mask::AbstractVector{UInt8})
    frame = getframe(w, i)
    masking!(frame.payload, mask)
    frame
end

clearframeswritten(w::FrameIOStub) = w.frames = []
get_no_of_frames_written(w::FrameIOStub) = length(w.frames)

#
# Ponger stub
#

mutable struct PongerStub <: AbstractPonger
    no_of_pongs::Int
    no_of_pings_sent::Int

    PongerStub() = new(0, 0)
end

ping_sent(p::PongerStub) = p.no_of_pings_sent += 1
pong_received(p::PongerStub) = p.no_of_pongs += 1

#
# A fake RNG allows us to deterministically test functions that would otherwise behave
# pseudo-randomly.
#

mutable struct FakeRNG{T} <: AbstractRNG
   values::AbstractArray{T, 1}

   FakeRNG{T}(v::AbstractArray{T, 1}) where {T} = new{T}(copy(v))
end

FakeRNG(::Type{T}) where T = FakeRNG{T}(AbstractArray{T, 1}())

function rand(rng::FakeRNG, ::Type{T}, n::Int) where T
    if isempty(rng.values)
        throw(InvalidPrecondition("FakeRNG requires more random data"))
    end
    splice!(rng.values, 1:n)
end
