module ArrayTools

using LinearAlgebra

"""
highest_indexin(a::Array, b::Array)

Returns a vector containing the highest index in b for each value in a that is a member of b . The output
vector contains 0 wherever a is not a member of b.

This works identical to indexin(a, b) in julia 0.6

# Examples

```julia-repl
julia> a = ['a', 'b', 'c', 'b', 'd', 'a'];

julia> b = ['a','b','c'];

julia> highest_indexin(a,b)
6-element Array{Int64,1}:

1
2
3
2
0
1

julia> highest_indexin(b,a)
3-element Array{Int64,1}:
6
4
3
```

Author: Tiankai, early 2019
# Remark Only used to facilitate translation from Julia-0.6.2 to
Julia-1.0.3. Please re-write code to drop this function
"""
function highest_indexin(a::AbstractArray, b::AbstractArray)
    ids = []
    for val in a
        found = false
        for i = reverse(1:length(b))
            if b[i] == val
                push!(ids, i)
                found = true
                break
            end
        end
        if !found
            push!(ids, 0)
        end
    end
    return ids
end

"""
intersect_index(A::Array{Float, 1}, B::Array{Float, 1})

Set intersection of two arrays

[C, ia, ib] returns
 C, the array of elements common to A and B without repetitions
 ia and ib, the index vectors s.t C = A[ia] and C = B[ib]

# Example
```julia-repl
julia> A = [7,1,7,7,4]; B = [7,0,4,4,0];
julia> C, ia, ib = intersect_index(A,B)
([4,7], [5.0, 1.0], [3.0, 1.0])

```
"""
function intersect_index(A::Array, B::Array)
    C = sort(unique(A[findall(highest_indexin(A,B) .!= 0)]))
    ia = fill(NaN, length(C))
    ib = fill(NaN, length(C))
    for iC = 1:length(C)
        for iA = 1:length(A)
            if C[iC] == A[iA]
                ia[iC] = Int(iA)
                break
            end
        end
    end


    for iC = 1:length(C)
        for iB = 1:length(B)
            if C[iC] == B[iB]
                ib[iC] = Int(iB)
                break
            end
        end
    end

    return C, ia, ib
end

function intersectML(ms::Array...)
  #find common elements by rows and return the location of each inputs array.
  t = map(x->Dict(x[2][i,:]=>(x[1],i) for i=1:size(x[2],1)),enumerate(ms))
  u = intersect(map(keys,t)...)
  return (u,map(x->[x[r][2] for r in u],t)...)
end


function regress_rmse_v011(y::Array{Float64,1}, X::Array{Float64,2})
    #X should include a column of ones so that the model contains a constant term.
    #both y and X should be removed missing value.
    # Return the minimum Root mean square error using Multiple linear regression

    n, ncolX = size(X)

    if length(y) != n
        error("X is a $n by $ncol matrix but y is a $(length(y)) by 1 vector")
    end


    "Use the rank-revealing QR to remove dependent columns of X."
    F = qr(X, Val(true))
    Q = F.Q
    Q = Q[:,1:ncolX]; # This makes a 'economic' version of Q just like in Matlab
    R = F.R
    perm = F.P
    perm = collect(1:ncolX) # Convert perm to a permutation index array
    p =sum(abs.(diag(R)) .> max(n,ncolX)*eps(R[1]))


    if p < ncolX

        R = R[1:p,1:p];
        Q = Q[:,1:p];
        perm = perm[1:p];
    end

    b = zeros(ncolX,1);
    b[perm] = R \ (Q'*y);
    nu = max(0,n-p);                # Residual degrees of freedom
    yhat = X*b;                    # Predicted responses at each data point.
    r = y-yhat;
    normr = norm(r);

    if nu != 0
        rmse = normr/sqrt(nu);    # Root mean square error.
    else
        rmse = NaN;
    end


    s2 = rmse^2;

    return s2

end

end