"""
    @private_method ...

Tags the method which follows the macro as having privileged access to particular 
    fields for annotated types. This allows interacting with the type through
    the traditional dot-syntax, `a.b`, rather than throwing an error.

Note that this replaces `a.b` with `PrivateFields.getproperty_direct(a, :b)`, so
    property or field-retrieval should be handled there.

# Usage

Annotate the arguments in a method signature you wish to have privileged access to 
    with four colons: `::::`

See the definition of `f` in the example below


# Example

```@example
@private_struct struct Foo{X,Y}
    @private x::X
    y::Y
end

@private_method f(a::::Foo, b::Foo) = a.x + b.y

foo = Foo(1.0, 2.0)

@assert f(foo, foo) == 3.0

foo.x + foo.y # throws an error
```
"""
macro private_method(_ex)
    ex = MacroTools.longdef(_ex)

    def = MacroTools.splitdef(ex)
    rebuilt_args, private_args = find_private_args(def[:args])

    def[:args] = rebuilt_args

    return_ex = MacroTools.combinedef(def)

    foreach(private_args) do arg
        return_ex = make_private_calls(return_ex, arg)
    end

    return esc(return_ex)
end

function find_private_args(argvec)
    results = map(argvec) do arg
        @capture(arg, (x_::::Tpriv_) | (x_::Tnorm_))
        T = something(Tpriv, Tnorm)
        private_var = !isnothing(Tpriv) ? Tpriv : nothing

        return (x, :($x::$T), private_var)
    end

    return getindex.(results, 2), first.(filter(!isnothing ∘ last, results))
end

function make_private_calls(_ex, sym)
    out_ex = MacroTools.postwalk(_ex) do ex
        @capture(ex, ($(sym).fld_)) || return ex

        q = Meta.quot(fld)
        return :(PrivateFields.getproperty_direct($sym, $q))
    end

    return out_ex
end
