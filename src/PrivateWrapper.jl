struct PrivateWrapper{T,PRIVATE}
    t::T
end

function Base.getproperty(wrapper::PrivateWrapper{T,PRIVATE}, p::Symbol) where {T,PRIVATE}
    t = wrapper.t
    if PRIVATE
        return getproperty_check_privacy(t, p)
    else
        return getproperty_direct(t, p)
    end
end
