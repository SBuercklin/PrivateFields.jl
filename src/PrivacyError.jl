struct PrivacyError{T} <: Exception
    s::T
    p::Symbol
end

function Base.showerror(io::IO, e::PrivacyError{T}) where {T}
    basename = nameof(T)
    p = e.p
    print(
        io,
        "PrivacyError: Attempted to directly access private field $basename.$p outside private context",
    )

    return nothing
end
