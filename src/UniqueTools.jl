module UniqueTools

function uniqueidx(A) #change from uniqueidx2 into uniqueidx
    # C = unique(A); IA, IC = uniqueidx(A).
    # IA: the index of the first occurrece of each reperated value in A for C, eg.A[IA]=C
    # IC: the index in C for C, eg.C[IC]=A.
    # written by rmiyany on 20180827
    # uniqueset = Set{T}()
    uniqueset = Set{typeof(A[1,:])}()
    IA = Vector{Int64}()
    IC = Vector{Int64}()
    tempic= 0
    for i in eachindex(A[:,1])
        Ai = A[i,:]
        if !(Ai in uniqueset)
            push!(IA, i)
            push!(uniqueset, Ai)
            tempic = tempic + 1
        end
        push!(IC, tempic)
    end
    return IA, IC
end

function uniqueLast(matrixA)
    matchrow(r,M) = findlast(i->all(j->r[j] == M[i,j],1:size(M,2)),1:size(M,1))
    uniqueA = unique(matrixA,dims=1)
    loc = map(row->matchrow(uniqueA[row,:],matrixA),1:size(uniqueA,1))
    return uniqueA, loc
end

end
