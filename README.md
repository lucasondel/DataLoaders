# BasicDataLoaders [![Actions Status: test](https://github.com/iondel/DataLoaders/workflows/test/badge.svg)](https://github.com/iondel/DataLoaders/actions?query=workflow%3Atest)

Julia package providing simple data loaders to train machine learning
systems.

# Usage

This package provide a simple objectof: `VectorDataLoader` which
reads its data from a sequence-like object.

The data loaders are constructed as follows:
```jldoctest
dl = DataLoader(vectordata[, batchsize = 1, preprocess = (x) -> x])
```
The user can provide a preprocessing function with the keyword argument
`preprocess`. By default, the preprocessing function is simply
identity. Importantly, the data loader implements the iterating and
indexing interfaces, allowing it to be used in parallel loops with
`Distributed`.

Here is a complete example:
```jldoctest
julia> using BasicDataLoaders
julia> data = Array(1:10)

10-element Array{Int64,1}:
  1
  2
  3
  4
  5
  6
  7
  8
  9
 10

julia> dl = DataLoader(data, batchsize = 3)
VectorDataLoader{Array{Int64,1}}
  data: Array{Int64,1}
  batchsize: 3

julia> for batch in dl println(batch) end
[1, 2, 3]
[4, 5, 6]
[7, 8, 9]
[10]

julia> data = [1 2; 3 4; 5 6]
3×2 Array{Int64,2}:
 1  2
 3  4
 5  6

julia> dl = MatrixDataLoader(data, batchsize = 1, preprocess = x -> 10*x)
MatrixDataLoader{Array{Int64,2}}
  data: Array{Int64,2}
  batchsize: 1

julia> for batch in dl println(batch) end
[10; 30; 50]
[20; 40; 60]
```

Because it is very common for data loaders to load data from disk, the package also provide two convenience functions to  easily read and write files:
```julia
save("path/to/file[.bson]", obj)
obj = load("path/to/file[.bson]")
```
The files are stored in the [BSON format](http://bsonspec.org/) using the [BSON julia package](https://github.com/JuliaIO/BSON.jl). Note that both `save` or `load` will add the ".bson" extension to the path if it doesn't have it already.
