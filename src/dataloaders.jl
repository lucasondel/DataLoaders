# DataLoaders - Concrete subtypes of AbstractDataLoader
#
# Lucas Ondel 2020

function Base.show(io::IO, dl::AbstractDataLoader)
    println(io, "$(typeof(dl))")
    println(io, "  data: $(typeof(dl.data))")
    print(io, "  batchsize: $(dl.batchsize)")
end

#######################################################################
# VectorDataLoader

"""
    struct VectorDataLoader <: AbstractDataLoader
        data::AbstractVector
        batchsize
    end

Data loader for data stored as a matrix.
"""
struct VectorDataLoader{T<:AbstractVector}  <: AbstractDataLoader{T}
    data::T
    batchsize::UInt
    f::Function

    function VectorDataLoader(data::AbstractVector; batchsize = 1,
                              preprocess = x -> x)
        length(data) > 0 || throw(ArgumentError("cannot create a VectorDataLoader from an empty collection"))
        batchsize >= 1 || throw(ArgumentError("`batchsize = $batchsize` should greater or equal to 1"))
        new{typeof(data)}(data, batchsize, preprocess)
    end
end

function Base.iterate(dl::VectorDataLoader, state = 1)
    if state > size(dl.data, 1)
        return nothing
    end
    offset = min(state+dl.batchsize-1, size(dl.data,1))
    dl.f(dl.data[state:offset]), offset+1
end
Base.length(dl::VectorDataLoader) = UInt(ceil(size(dl.data, 1)/dl.batchsize))
Base.eltype(dl::VectorDataLoader) = eltype(dl.data)

function Base.getindex(dl::VectorDataLoader, i)
    1 <= i <= length(dl) || throw(BoundsError(dl, i))
    start = (i-1) * dl.batchsize + 1
    offset = min(start + dl.batchsize - 1, size(dl.data,1))
    dl.f(dl.data[start:offset])
end
Base.firstindex(dl::VectorDataLoader) = 1
Base.lastindex(dl::VectorDataLoader) = length(dl)

#######################################################################
# MatrixDataLoader

"""
    struct MatrixDataLoader <: AbstractDataLoader
        data::AbstractMatrix
        batchsize
    end

Data loader for data stored as a matrix.
"""
struct MatrixDataLoader{T<:AbstractMatrix} <: AbstractDataLoader{T}
    data::T
    batchsize::UInt
    f::Function

    function MatrixDataLoader(data::AbstractMatrix; batchsize = 1,
                              preprocess = x -> x)
        size(data, 1) > 0 && size(data, 2) > 0 || throw(ArgumentError("cannot create a MatrixDataLoader from an empty collection"))
        batchsize >= 1 || throw(ArgumentError("`batchsize = $batchsize` should greater or equal to 1"))

        new{typeof(data)}(data, batchsize, preprocess)
    end
end

function Base.iterate(dl::MatrixDataLoader, state = 1)
    if state > size(dl.data, 2)
        return nothing
    end
    offset = min(state+dl.batchsize-1, size(dl.data,2))
    dl.f(dl.data[:,state:offset]), offset+1
end
Base.length(dl::MatrixDataLoader) = UInt(ceil(size(dl.data, 2)/dl.batchsize))
Base.eltype(dl::MatrixDataLoader{T}) where T = T

function Base.getindex(dl::MatrixDataLoader, i)
    1 <= i <= length(dl) || throw(BoundsError(dl, i))
    start = (i-1) * dl.batchsize + 1
    offset = min(start + dl.batchsize - 1, size(dl.data,2))
    dl.f(dl.data[:, start:offset])
end
Base.firstindex(dl::MatrixDataLoader) = 1
Base.lastindex(dl::MatrixDataLoader) = length(dl)

