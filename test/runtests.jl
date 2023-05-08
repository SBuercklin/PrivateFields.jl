using Test, PrivateFields
const PF = PrivateFields

@testset "Private Definitions" begin
    @private_struct struct Foo{X,Y}
        @private x::X
        y::Y
    end

    @test PF.private_fieldnames(Foo) == (:x,)

    @private_struct struct Bar
        x
        @private y
        z
        @private w
    end

    @test PF.private_fieldnames(Bar) == (:y, :w)
end

@testset "Direct Access Throws" begin
    f = Foo(1.0, 2.0)
    b = Bar(3.0, 4.0, 5.0, 6.0)

    @test_throws PF.PrivacyError f.x
    @test_nowarn f.y

    @test_nowarn b.x
    @test_throws PF.PrivacyError b.y
    @test_nowarn b.z
    @test_throws PF.PrivacyError b.w
end

@testset "Private Methods" begin
    @testset "Single Private Arg" begin
        foo = Foo(1.0, 2.0)

        @private_method f(f1::::Foo, f2::Foo) = f1.x + f2.y

        @test f(foo, foo) == 3.0
    end
    @testset "Multiple Private Args" begin
        foo = Foo(1.0, 2.0)
        bar = Bar(3.0, 4.0, 5.0, 6.0)

        @private_method g(f::::Foo, b::::Bar, f2) = f.x + b.y * b.z + f2.y

        @test g(foo, bar, foo) == 1.0 + 20.0 + 2.0
    end
    @testset "Non-private Definition Breaks" begin
        foo = Foo(1.0, 2.0)
        bar = Bar(3.0, 4.0, 5.0, 6.0)

        h(f, b, f2) = f.x + b.y * b.z + f2.y

        @test_throws PF.PrivacyError h(foo, bar, foo)
    end
end
