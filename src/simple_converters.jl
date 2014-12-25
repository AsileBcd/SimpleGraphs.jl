# These are functions to convert SimpleGraph's to formats in Julia's
# Graphs module.

# Convert a graph or digraph into a "simple_graph".
#
# We return a triple: the simple_graph H with vertex set 1:n, a
# dictionary d mapping the vertices of G to the vertices of H, and the
# inverse dictionary dinv from V(H) to V(G).

import Graphs.simple_graph, Graphs.add_edge!
export convert_simple

function convert_simple(G::AbstractSimpleGraph)
    T = vertex_type(G)
    n = NV(G)
    has_dir = isa(G,SimpleDigraph)


    d = vertex2idx(G)
    dinv = Dict{Int,T}()
    for k in keys(d)
        v = d[k]
        dinv[v] = k
    end

    H = simple_graph(n,is_directed=has_dir)

    EE = elist(G)
    for e in EE
        u = d[e[1]]
        v = d[e[2]]
        add_edge!(H,u,v)
    end
    return (H,d,dinv)
end




