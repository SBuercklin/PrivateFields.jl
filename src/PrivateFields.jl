module PrivateFields

using MacroTools
using Infiltrator

macro private_struct(ex)
    private_fields, struct_ex = find_private_fields(ex)
    struct_name, all_fields = get_struct_info(struct_ex)

    @show struct_name, all_fields, private_fields

    getter = build_getter(struct_name, all_fields, private_fields)
    return esc(Expr(:block, struct_name, getter))
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

    return private_fields, out_ex
end

function get_struct_info(_ex)
    all_fields = Symbol[]
    sname, fields = MacroTools.postwalk(_ex) do ex
        @capture(ex, (struct ((sname_{X__}) | (sname_))
            fields__
        end)) || return ex
        return sname, fields
    end
    return sname,
    map(fields) do ex
        ex isa Symbol ? ex : first(ex.args)
    end
end

function build_getter(struct_name, all_fields, private_fields)
    public_fields = Tuple(setdiff(all_fields, private_fields))
    gtr = quote
        function Base.getproperty(s::$struct_name, f::Symbol)
            return if f in $public_fields
                Base.getfield(s, f)
            else
                error("Attempted to access private field")
            end
        end
    end

    return gtr
end

export @private_struct

end # module PrivateFields
