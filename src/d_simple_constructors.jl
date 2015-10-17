export DirectedPath, DirectedCycle, DirectedComplete
export RandomDigraph, RandomTournament

"""
`DirectedPath(n)` creates a directed cycles with vertices `1:n`.
"""
function DirectedPath(n::Int)
    if n < 1
        error("n must be positive")
    end
    G = IntDigraph(n)
    for u=1:(n-1)
        add!(G,u,u+1)
    end
    return G
end

"""
`DirectedCycle(n)` creates a directed cycles with vertices `1:n`.
"""
function DirectedCycle(n::Int)
    G = DirectedPath(n)
    add!(G,n,1)
    return G
end

# Create a complete digraph (all possible edges)
"""
`DirectedComplete(n)` creates a directed complete graph with
all possible edges (including a loop at each vertex). Use
`DirectedComplete(n,false)` to supress the creation of loops.
"""
function DirectedComplete(n::Int, with_loops::Bool=true)
    G = IntDigraph(n)
    if !with_loops
        forbid_loops!(G)
    end
    for u=1:n
        for v=1:n
            add!(G,u,v)
        end
    end
    return G
end

# Create a random digraph (Erdos-Renyi style)
"""
`RandomDigraph(n,p)` creates an Erdos-Renyi style random directed
graph with vertices `1:n` and edge probability `p` (equal to 0.5 by
default). The possible edges `(u,v)` and `(v,u)` are independent. No
loops are created. To also create loops (each with probability `p`)
use `RandomDigraph(n,p,true)`.
"""
function RandomDigraph(n::Int, p::Real=0.5, with_loops=false)
    G = IntDigraph(n)
    if !with_loops
        forbid_loops!(G)
    end
    for u=1:n
        for v=1:n
            if rand() < p
                add!(G,u,v)
            end
        end
    end
    return G
end

# Create a random tournament (no loops!)

"""
`RandomTournament(n)` creates a random tournament with vertex set
`1:n`.  This is equivalent to randomly assigning a direction to every
edge of a simple complete graph.
"""
function RandomTournament(n::Int)
    G = IntDigraph()
    for u=1:n-1
        for v=u+1:n
            if rand() < 0.5
                add!(G,u,v)
            else
                add!(G,v,u)
            end
        end
    end
    return G
end
