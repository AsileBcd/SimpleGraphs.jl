# functions for building various standard types of graphs

export Complete, Path, Cycle, RandomGraph
export RandomTree, code_to_tree
export Grid, Wheel, Cube, BuckyBall
export Petersen, Kneser

# Create a complete graph
function Complete(n::Int)
    G = IntGraph(n)

    for k=1:n-1
        for j=k+1:n
            add!(G,j,k)
        end
    end
    return G
end

# Create a complete bipartite graph
function Complete(n::Int, m::Int)
    G = IntGraph(n+m)
    for u=1:n
        for v=n+1:n+m
            add!(G,u,v)
        end
    end
    return G
end

# Create the complete multipartite graph with given part sizes
function Complete(parts::Array{Int,1})
    # check all part sizes are positive
    for p in parts
        if p < 1
            error("All part sizes must be positive")
        end
    end

    n = sum(parts)
    G = IntGraph(n)

    np = length(parts)
    if np < 2
        return G
    end

    # create table of part ranges
    ranges = Array(Int,np,2)
    ranges[1,1] = 1
    ranges[1,2] = parts[1]
    for k = 2:np
        ranges[k,1] = ranges[k-1,2] + 1
        ranges[k,2] = ranges[k,1] + parts[k] - 1
    end

    # Add all edges between all parts
    for i=1:np-1
        for j=i+1:np
            for u=ranges[i,1]:ranges[i,2]
                for v=ranges[j,1]:ranges[j,2]
                    add!(G,u,v)
                end
            end
        end
    end

    return G
end

# Create a path graph on n vertices
function Path(n::Int)
    G = IntGraph(n)
    for v = 1:n-1
        add!(G,v,v+1)
    end
    return G
end

# Create a path graph from a list of vertices
function Path{T}(verts::Array{T})
    G = SimpleGraph{T}()
    n = length(verts)

    if n==1
        add!(G,verts[1])
    end
    for k = 1:n-1
        add!(G,verts[k],verts[k+1])
    end
    return G
end

# Create a cycle graph on n vertices
function Cycle(n::Int)
    if n<3
        error("Cycle requires 3 or more vertices")
    end
    G = Path(n)
    add!(G,1,n)
    return G
end

# Create the wheel graph on n vertices: a cycle on n-1 vertices plus
# an additional vertex adjacent to all the vertices on the wheel.
function Wheel(n::Int)
    if n < 4
        error("Wheel graphs must have at least 4 vertices")
    end
    G = Cycle(n-1)
    for k=1:n-1
        add!(G,k,n)
    end
    return G
end

# Create a grid graph
function Grid(n::Int, m::Int)
    G = SimpleGraph{(Int,Int)}()

    # add the vertices
    for u=1:n
        for v=1:m
            add!(G,(u,v))
        end
    end

    #horizontal edges
    for u=1:n
        for v=1:m-1
            add!(G,(u,v),(u,v+1))
        end
    end

    # vertical edges
    for v=1:m
        for u=1:n-1
            add!(G,(u,v),(u+1,v))
        end
    end
    return G
end

# Create an Erdos-Renyi random graph
function RandomGraph(n::Int, p::Real=0.5)
    G = IntGraph(n)
    
    # guess the size of the edge set to preallocate storage
    m = int(n*n*p)+1

    # generate the edges
    for v=1:n-1
        for w=v+1:n
            if (rand() < p)
                add!(G,v,w)
            end
        end
    end
    return G
end

# Generate a random tree on vertex set 1:n. All n^(n-2) trees are
# equally likely.
function RandomTree(n::Int)

    if n<0   # but we allow n==0 to give empty graph
        error("Number of vertices cannot be negative")
    end

    if n<2
        return IntGraph(n)
    end

    code = [ mod(rand(Int),n)+1 for _ in 1:n-2 ]
    return code_to_tree(code)
end

# This is a helper function for RandomTree that converts a Prufer code
# to a tree. No checks are done on the array fed into this function.
function code_to_tree(code::Array{Int,1})
    n = length(code)+2
    G = IntGraph(n)
    degree = ones(Int,n)  # initially all 1s

    #every time a vertex appears in code[], up its degree by 1
    for c in code
        degree[c]+=1
    end

    for u in code
        for v in 1:n
            if degree[v]==1
                add!(G,u,v)
                degree[u] -= 1
                degree[v] -= 1
                break
            end
        end
    end

    last = find(degree)
    add!(G,last[1],last[2])

    return G
end

# Create the Cube graph with 2^n vertices
function Cube(n::Integer)
    G = StringGraph()
    for u=0:2^n-1
        for shift=0:n-1
            v = (1<<shift) $ u
            add!(G,bin(u,n), bin(v,n))
        end
    end
    return G
end

# Create the BuckyBall graph
function BuckyBall()
    G = IntGraph()
    edges = [(1,3), (1,49), (1,60), (2,4), (2,10), (2,59),
	     (3,4), (3,37), (4,18), (5,7), (5,9), (5,13),
	     (6,8), (6,10), (6,17), (7,8), (7,21), (8,22),
	     (9,10), (9,57), (11,12), (11,13), (11,21), (12,28),
	     (12,48), (13,14), (14,47), (14,55), (15,16), (15,17),
	     (15,22), (16,26), (16,42), (17,18), (18,41), (19,20),
	     (19,21), (19,27), (20,22), (20,25), (23,24), (23,32),
	     (23,35), (24,26), (24,39), (25,26), (25,31), (27,28),
	     (27,31), (28,30), (29,30), (29,32), (29,36), (30,45),
	     (31,32), (33,35), (33,40), (33,51), (34,36), (34,46),
	     (34,52), (35,36), (37,38), (37,41), (38,40), (38,53),
	     (39,40), (39,42), (41,42), (43,44), (43,47), (43,56),
	     (44,46), (44,54), (45,46), (45,48), (47,48), (49,50),
	     (49,53), (50,54), (50,58), (51,52), (51,53), (52,54),
	     (55,56), (55,57), (56,58), (57,59), (58,60), (59,60),
	     ]
    for e in edges
        add!(G,e[1],e[2])
    end
    return G
end

# Create the set of all subsets of size k of a given set
function subsets{T}(A::Set{T}, k::Int)
    # create list of lists
    L = Base.combinations(collect(A),k)
    B = Set{Set{T}}()
    for x in L
        push!(B, array2set(x))
    end
    return B
end

# Unexposed helper function for subsets() function
function array2set{T}(A::Array{T,1})
    S = Set{T}()
    for a in A
        push!(S,a)
    end
    return S
end

# The Kneser graph Kneser(n,k) has C(n,k) vertices that are the
# k-element subsets of 1:n in which two vertices are adjacent if (as
# sets) they are disjoint. The Petersen graph is Kneser(5,2).
function Kneser(n::Int,k::Int)
    A = array2set(collect(1:n))
    vtcs = collect(subsets(A,k))
    G = SimpleGraph{Set{Int}}()

    for v in vtcs
        add!(G,v)
    end

    n = length(vtcs)
    for i=1:n-1
        u = vtcs[i]
        for j=i+1:n
            v = vtcs[j]
            if length(intersect(u,v))==0
                add!(G,u,v)
            end
        end
    end

    return G
end

# Create the Petersen graph.
Petersen() = Kneser(5,2)