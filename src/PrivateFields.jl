module PrivateFields

using MacroTools

include("./private_struct.jl")
include("./private_method.jl")
include("./functions.jl")
include("./PrivacyError.jl")

export @private_struct, @private_method, private_fieldnames, getproperty_direct

end # module PrivateFields
