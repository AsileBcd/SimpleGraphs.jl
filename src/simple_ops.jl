import Base.isequal
import Base.delete!, Base.union
import Base.complement, Base.complement!
import Base.join

export add!, delete!, contract!,  induce
export line_graph, complement, complement!, ctranspose
export cartesian, relabel, trim
export disjoint_union, union, join

# check for graph equality
function isequal(G::SimpleGraph, H::SimpleGraph)
    if G.V != H.V || NE(G) != NE(H)
        return false
    end
    try  # check vertex sets for sortability
        sort(collect(G.V))
        # sort(collect(H.V))
    catch  #if not sortable, resort to a slow method
        for e in G.E
            if ! has(H,e[1],e[2])
                return false
            end
        end
        return true
    end
    # otherwise faster to check edge sets this way
    return G.E==H.E
end

function ==(G::SimpleGraph, H::SimpleGraph)
    return isequal(G,H)
end

# adding vertices
"""
`add!(G,v)` adds a new vertex `v` to the graph.

`add!(G,v,w)` adds a new edge `(v,w)` to the graph. If one (or both)
of those vertices is not already in the graph, it is added to the
vertex set.
"""
function add!{T}(G::SimpleGraph{T}, v)
    if has(G,v)
        return false
    end
    push!(G.V, v)
    if G.Nflag
        G.N[v] = Set{T}()
    end
    return true
end

# adding edges
function add!{T}(G::SimpleGraph{T}, v, w)
    if v==w
        return false
    end

    try
        if v > w
            v,w = w,v
        end
    end

    if ~has(G,v)
        add!(G,v)
    end
    if ~has(G,w)
        add!(G,w)
    end
    if has(G,v,w)
        return false
    end
    push!(G.E, (v,w))
    if G.Nflag
        push!(G.N[v], w)
        push!(G.N[w], v)
    end
    return true
end

# edge deletion
"""
`delete!(G,v)` deletes vertex `v` (and any edges incident with `v`)
from the graph.

`delete!(G,v,w)` deletes the edge `(v,w)` from `G`.
"""
function delete!(G::SimpleGraph, v, w)
    flag = false
    if has(G,v,w)
        flag = true
        delete!(G.E,(v,w))
        delete!(G.E,(w,v))
        if G.Nflag
            delete!(G.N[v],w)
            delete!(G.N[w],v)
        end
    end
    return flag
end

# vertex deletion
function delete!(G::SimpleGraph, v)
    flag = false
    if has(G,v)
        flag = true
        Nv = G[v]
        for w in Nv
            delete!(G,v,w)
        end
        delete!(G.V, v)
        if G.Nflag
            delete!(G.N,v)
        end
    end
    return flag
end

# Contract an edge in a graph. If uv is an edge of G, we add all of
# v's neighbors to u's neighborhood and then delete v. This mutates
# the graph. Usually, vertices u and v are adjacent, but we don't
# require that. If either u or v is not a vertex of this graph, or if
# u==v, we return false. Otherwise we return true to indicate success.
"""
`contract!(G,u,v)` contracts the edge `(u,v)` in the graph. The merged
vertex is named `u` (hence `contract!(G,v,u)` results in a different,
albeit isomorphic, graph).

Note: The edge `(u,v)` need not be present in the graph. If missing,
this is equivalent to first adding the edge to the graph and then
contracting it.
"""
function contract!(G::SimpleGraph, u, v)
    if !has(G,u) || !has(G,v) || u==v
        return false
    end

    Nv = G[v]
    for x in Nv
        add!(G,u,x)
    end
    delete!(G,v)
    return true
end

# Given a simple graph G and a set of vertices A, form the induced
# subgraph G[A]. Note that A must be a subset of V(G).
"""
`induce(G,A)` creates the induced subgraph of `G` with vertices in the
set `A`.
"""
function induce{T}(G::SimpleGraph{T}, A::Set)
    # Check that A is a subset of V(G)
    for v in A
        if ~has(G,v)
            error("The set A must be a subset of V(G)")
        end
    end
    H = SimpleGraph{T}()  # place to hold the answer

    # add all the vertices in A to H
    for v in A
        add!(H,v)
    end

    # The method we choose depends on the size of A. For small A, best
    # to iterate over pairs of elements of A. For large A, best to
    # iterate over G.E
    a = length(A)

    if a<2
        return H
    end

    # case of small A, iterate over pairs from A
    if a*(a-1) < 2*NE(G)
        alist = collect(A)
        for i=1:a-1
            u = alist[i]
            for j=i+1:a
                v = alist[j]
                if has(G,u,v)
                    add!(H,u,v)
                end
            end
        end

    else  # case of large A, iterate over G.E
        for e in G.E
            if in(e[1],A) && in(e[2],A)
                add!(H,e[1],e[2])
            end
        end
    end
    return H
end

# Create the line graph of a given graph
"""
`line_graph(G)` creates the line graph of `G`.
"""
function line_graph{T}(G::SimpleGraph{T})
    H = SimpleGraph{Tuple{T,T}}()

    m = NE(G)
    E = elist(G)
    for e in E
        add!(H,e)
    end

    for i=1:m-1
        e = E[i]
        for j=i+1:m
            f = E[j]
            if e[1]==f[1] || e[2]==f[1] || e[1]==f[2] || e[2]==f[2]
                add!(H,e,f)
            end
        end
    end
    return H
end

# Create the complement of a graph.
"""
`complement(G)` creates (as a new graph) the complement of `G`.
Note that `G'` is a short cut for `complement(G)`.
"""
function complement{T}(G::SimpleGraph{T})
    H = SimpleGraph{T}()
    V = vlist(G)
    n = NV(G)

    for i=1:n
        add!(H,V[i])
    end

    for i=1:n-1
        v = V[i]
        for j=i+1:n
            w = V[j]
            if ~has(G,v,w)
                add!(H,v,w)
            end
        end
    end
    return H
end

# We can use G' to mean complement(G)
"""
`G'` is equivalent to `complement(G)`.
"""
ctranspose(G::SimpleGraph) = complement(G)

# complement in place. Returns None.
"""
`complement!(G)` replaces `G` with its complement.
"""
function complement!(G::SimpleGraph)
    n = NV(G)
    V = vlist(G)
    for i=1:n-1
        v = V[i]
        for j=i+1:n
            w = V[j]
            if has(G,v,w)
                delete!(G,v,w)
            else
                add!(G,v,w)
            end
        end
    end
    return None
end

# Create the cartesian product of two graphs
"""
`cartesian(G,H)` creates the Cartesian product of the two graphs.
This can be abbreviated as `G*H`. 
"""
function cartesian{S,T}(G::SimpleGraph{S}, H::SimpleGraph{T})
    K = SimpleGraph{Tuple{S,T}}()
    for v in G.V
        for w in H.V
            add!(K,(v,w))
        end
    end

    for e in G.E
        (u,v) = e
        for w in H.V
            add!(K, (u,w), (v,w))
        end
    end

    for e in H.E
        (u,v) = e
        for w in G.V
            add!(K, (w,u), (w,v))
        end
    end

    return K
end

# Use G*H for Cartesian product
"""
For `SimpleGraph`s: `G*H` is equivalent to `cartesian(G,H)`.
"""
function *{S,T}(G::SimpleGraph{S},H::SimpleGraph{T})
    return cartesian(G,H)
end

# The join of two graphs is formed by taking disjoint copies of the
# graphs and all possible edges between the two.

"""
`join(G,H)` is a new graph formed by taking disjoint copies of 
`G` and `H` together with all possible edges between those copies.
"""
function join{S,T}(G::SimpleGraph{S}, H::SimpleGraph{T})
    K = disjoint_union(G,H)
    for v in G.V
        for w in H.V
            add!(K, (v,1), (w,2) )
        end
    end
    return K
end

# Create the union of two graphs. If they have vertices or edges in
# common, that's OK.

"""
`union(G,H)` creates the union of the graphs `G` and `H`. The graphs
may (and typically do) have common vertices or edges.
"""
function union{S,T}(G::SimpleGraph{S}, H::SimpleGraph{T})
    if S==T
        K = SimpleGraph{S}()
    else
        K = SimpleGraph{Any}()
    end

    for v in G.V
        add!(K,v)
    end
    for v in H.V
        add!(K,v)
    end

    for e in G.E
        add!(K,e[1],e[2])
    end
    for e in H.E
        add!(K,e[1],e[2])
    end
    return K
end

# This is an unexposed helper function that takes a graph and creates
# a new graph in which the name of each vertex has an integer
# appended. For example, if the vertex type is String in the original
# graph, the new vertices are type (String, Int).
function label_append{S}(G::SimpleGraph{S}, a::Int)
    mapper = Dict{S,Tuple{S,Int}}()
    for v in G.V
        mapper[v] = (v,a)
    end
    return relabel(G,mapper)
end

# The disjoint_union of two graphs, G and H, is a new graph consisting of
# disjoint copies of G and H.

"""
`disjoint_union(G,H)` is a new graph formed by taking disjoint copies
of `G` and `H` (and no additional edges).
"""
function disjoint_union{S,T}(G::SimpleGraph{S}, H::SimpleGraph{T})
    GG = label_append(G,1)
    HH = label_append(H,2)
    if S==T
        K = SimpleGraph{Tuple{S,Int}}()
    else
        K = SimpleGraph{Any}()
    end

    for v in GG.V
        add!(K,v)
    end
    for v in HH.V
        add!(K,v)
    end

    for e in GG.E
        add!(K,e[1],e[2])
    end
    for e in HH.E
        add!(K,e[1],e[2])
    end
    return K
end

# Repeatedly remove vertices with the given degree or less until there
# are no such vertices remaining in the graph. The default trim(G)
# simply removes all isolated vertices.

"""
`trim(G)` returns a copy of `G` with all isolated vertices removed.

`trim(G,d)` returns a copy of `G` in which we iteratively remove all
vertices of degree `d` or smaller. For example, if `G` is a tree,
`trim(G,1)` will eventually remove all vertices.
"""
function trim(G::SimpleGraph, d::Int = 0)
    H = deepcopy(G)
    while NV(H) > 0 && minimum(deg(H)) <= d
        for v in H.V
            if deg(H,v) <= d
                delete!(H,v)
            end
        end
    end
    return H
end

# Relabel the vertics of a graph based on a dictionary mapping old
# vertex names to new

"""
`relabel(G)` returns a copy of `G` in which the vertices are renamed
`1:n`.

`relabel(G,d)` (where `d` is a `Dict`) returns a copy of `G` in which
vertex `v` is renamed `d[v]`.
"""
function relabel{S,T}(G::SimpleGraph{S}, label::Dict{S,T})
    H = SimpleGraph{T}()
    for v in G.V
        add!(H,label[v])
    end

    for e in G.E
        u = label[e[1]]
        v = label[e[2]]
        add!(H,u,v)
    end
    return H
end

# Relabel the vertices with the integers 1:n
function relabel{S}(G::SimpleGraph{S})
    verts = vlist(G)
    n = length(verts)
    label = Dict{S,Int}()
    sizehint!(label,n)

    for idx = 1:n
        label[verts[idx]] = idx
    end

    return relabel(G,label)
end
