"""
    private_fieldnames(::Type{T}) where {T}

Returns the private fields of the type `T`, as denoted by [`@private_struct`](@ref).

Defaults to `()`
"""
private_fieldnames(::Type{<:T}) where {T} = ()

"""
    getproperty_check_privacy(s::T, p::Symbol)

If `p` is a private field of `T`, as denoted by as denoted by [`@private_struct`](@ref),
    throws an error. Otherwise, 

"""
function getproperty_check_privacy(s::T, p::Symbol) where {T}
    if p in private_fieldnames(T)
        throw(PrivacyError(s, p))
    else
        return getproperty_direct(s, p)
    end
end

"""
    getproperty_direct(s::T, p::Symbol)

Fallback `getproperty` implementation for types with private fields, as denoted by
    [`@private_struct`](@ref). 

By default, `getproperty_direct` wraps `getfield`. If you need special properties for your type
    but also want the type to contain private fields, you can implement `getproperty_direct`. 
    For any property names which do not coincide with `T`'s private fields, this method
    will be used. 

If you are inside of a method which is tagged `@private_method`, the arguments which are annotated
    as having private access will also call `getproperty_direct` directly. This means 
    `getproperty_direct` should also support accessing private fields directly.
"""
getproperty_direct(s, p) = getfield(s, p)
