# PrivateFields.jl

Disables the `A.x` syntax for fields marked `@private` when defining a struct. 

The only way to access these fields is through the (much less ergonomic) `getfield` function, or through a `getter` or `accessor` method you define.

Also allows privileged access to fields through another macro on method definitions. This lets us use the dot syntax, but only within the scope of that method and only for particular types we specially annotate

## Example 

```julia
# @private denotes the private fields
@private_struct struct Foo{X,Y}
    @private x::X
    y::Y
end

foo1 = Foo(3.0, 4.0)
foo2 = Foo(5, 6)

# 4-colon syntax denotes that only f1 should allow private access to fields
@private_method f(f1::::Foo, f2::Foo) = f1.x + f2.y
g(f1::Foo, f2::Foo) = f1.x + f2.y

f(foo1, foo2) # 9.0

g(foo1, foo2) # ERROR: PrivacyError: Attempted to directly access private field Foo.x outside private context
```

# Additional Reading/Thoughts

[JuliaLang #12064](https://github.com/JuliaLang/julia/issues/12064) discusses privacy of type fields

[This Discourse post](https://discourse.julialang.org/t/private-properties-in-julia-0-7/10785/5) discusses a similar approach to making private properties, although it uses a keyword argument. 
