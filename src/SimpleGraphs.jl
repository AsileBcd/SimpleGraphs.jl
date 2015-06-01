# Module written by Ed Scheinerman, ers@jhu.edu
# distributed under terms of the MIT license

module SimpleGraphs
using DataStructures

abstract AbstractSimpleGraph
export AbstractSimpleGraph

include("simple_core.jl")
include("simple_ops.jl")
include("simple_constructors.jl")
include("platonic.jl")
include("simple_connect.jl")
include("simple_matrices.jl")
include("disjoint_sets_helper.jl")
include("simple_converters.jl")
include("simple_coloring.jl")
include("simple_euler.jl")

include("d_simple_core.jl")
include("d_simple_constructors.jl")
include("d_simple_matrices.jl")


end # module SimpleGraphs
