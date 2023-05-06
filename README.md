# PrivateFields.jl

Disables the `A.x` syntax for fields marked `@private` when defining a struct. 

The only way to access these fields is through the (much less ergonomic) `getfield` function, or through a `getter` or `accessor` method you define.

## Example 

```julia
@private_struct Foo{X,Y}
    x::X
    @private y::Y
end
```

# TODO

- [ ] Doesn't support subtyping (i.e. `struct Bar <: AbstractFoo`) 
- [ ] Automate getters for private fields
- [ ] Hide private fields from `propertynames(::T, private=false)`
- [ ] `setproperty!` implementation for mutable structs
- [ ] Some overload that allows us to integrate with manual `getproperty`

# Additional Reading/Thoughts

[JuliaLang #12064](https://github.com/JuliaLang/julia/issues/12064) discusses privacy of type fields

[This Discourse post](https://discourse.julialang.org/t/private-properties-in-julia-0-7/10785/5) discusses a similar approach to making private properties, although it uses a keyword argument. 

We can also use a `Val`-type and a 3-argument `getproperty` with a default third argument to control whether we use private fields or treat all fields as public.
