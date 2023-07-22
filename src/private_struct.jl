"""
    @private_struct ...

Annotates a struct with particular `@private` fields. These fields cannot be accessed
    directly with the dot-syntax (`a.b`) in normal use. Instead, the struct fields
    should be interacted with indirectly through `@private_method` methods
    which have privileged access to the fields of the struct.

Calling `getfield` on the struct directly is still functional, but by default `getproperty`
    will call a progammatically-generated `PrivateFields.jl` method which verifies
    field privacy. 

If you wish to overload the struct with a custom `getproperty` method while preserving 
    field privacy, you should instead implement [`getproperty_direct`](@ref) from `PrivateFields.jl`

# Usage

Prepend `@private` before field definitions of your struct to tag those fields as private. 
Private/public fields can be declared in any order.

See the example below.

# Example

```
@private_struct Foo{X,Y}
    @private x::X
    y::Y
end
```
"""
macro private_struct(ex)
    private_fields, struct_ex = find_private_fields(ex)
    struct_name = get_struct_info(struct_ex)

    private_flds = build_private_fields(struct_name, private_fields)
    gp = build_getproperty(struct_name)

    return esc(Expr(:block, struct_ex, private_flds, gp))
end

function find_private_fields(_ex)
    private_fields = Symbol[]
    out_ex = MacroTools.postwalk(_ex) do ex
        @capture(ex, (@private x_::X_) | (@private x_)) || return ex
        push!(private_fields, x)

        if isnothing(X)
            return :($x)
        else
            return :($x::$X)
        end
    end

    return Tuple(private_fields), out_ex
end

function get_struct_info(ex)
    sdef = MacroTools.splitstructdef(ex)
    return sdef[:name]
end

function build_private_fields(struct_name, private_fields)
    pfields = quote
        function PrivateFields.private_fieldnames(::Type{<:$struct_name})
            return $private_fields
        end
    end

    return pfields
end

function build_getproperty(struct_name)
    gp = quote
        function Base.getproperty(s::$struct_name, p::Symbol)
            return Base.getproperty(s, p, PrivateFields.PublicAccess())
        end
        function Base.getproperty(s::$struct_name, p::Symbol, ::PrivateFields.PublicAccess)
            if p in PrivateFields.private_fieldnames($struct_name)
                throw(PrivateFields.PrivacyError(s, p))
            else
                return getfield(s, p)
            end
        end
        function Base.getproperty(s::$struct_name, p::Symbol, ::PrivateFields.PrivateAccess)
            return getfield(s, p)
        end
    end

    return gp
end
