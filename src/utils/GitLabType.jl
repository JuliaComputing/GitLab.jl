##############
# GitLabType #
##############
# A `GitLabType` is a Julia type representation of a JSON object defined by the
# GitLab API. Generally:
#
# - The fields of these types should correspond to keys in the JSON object. In
#   the event the JSON object has a "type" key, the corresponding field name
#   used should be `typ` (since `type` is a reserved word in Julia).
#
# - The method `name` should be defined on every GitLabType. This method
#   returns the type's identity in the form used for URI construction. For
#   example, `name` called on an `Owner` will return the owner's login, while
#   `name` called on a `Commit` will return the commit's sha.
#
# - A GitLabType's field types should be Nullables of either concrete types, a
#   Vectors of concrete types, or Dicts.

abstract GitLabType

typealias GitLabString Compat.UTF8String

function @compat(Base.:(==))(a::GitLabType, b::GitLabType)
    if typeof(a) != typeof(b)
        return false
    end

    for field in fieldnames(a)
        aval, bval = getfield(a, field), getfield(b, field)
        if isnull(aval) == isnull(bval)
            if !(isnull(aval)) && get(aval) != get(bval)
                return false
            end
        else
            return false
        end
    end

    return true
end

# `namefield` is overloaded by various GitLabTypes to allow for more generic
# input to AP functions that require a name to construct URI paths via `name`
name(val) = val
name(g::GitLabType) = get(namefield(g))

########################################
# Converting JSON Dicts to GitLabTypes #
########################################

function extract_nullable{T}(data::Dict, key, ::Type{T})
    if haskey(data, key)
        val = data[key]
        if !(isa(val, Void))
            if T <: Vector
                V = eltype(T)
                return Nullable{T}(V[prune_gitlab_value(v, V) for v in val])
            else
                return Nullable{T}(prune_gitlab_value(val, T))
            end
        end
    end
    return Nullable{T}()
end

prune_gitlab_value{T}(val, ::Type{T}) = T(val)
prune_gitlab_value(val, ::Type{Dates.DateTime}) = Dates.DateTime(chopz(val))

# ISO 8601 allows for a trailing 'Z' to indicate that the given time is UTC.
# Julia's Dates.DateTime constructor doesn't support this, but GitLab's time
# strings can contain it. This method ensures that a string's trailing 'Z',
# if present, has been removed.
function chopz(str::AbstractString)
    if !(isempty(str)) && last(str) == 'Z'
        return chop(str)
    end
    return str
end

# Calling `json2gitlab(::Type{G<:GitLabType}, data::Dict)` will parse the given
# dictionary into the type `G` with the expectation that the fieldnames of
# `G` are keys of `data`, and the corresponding values can be converted to the
# given field types.
@generated function json2gitlab{G<:GitLabType}(::Type{G}, data::Dict)
    types = G.types
    fields = fieldnames(G)
    args = Vector{Expr}(length(fields))
    for i in eachindex(fields)
        field, T = fields[i], first(types[i].parameters)
        key = field == :typ ? "type" : string(field)
        args[i] = :(extract_nullable(data, $key, $T))
    end
    return :(G($(args...))::G)
end

#############################################
# Converting GitLabType Dicts to JSON Dicts #
#############################################

gitlab2json(val) = val
gitlab2json(uri::HttpCommon.URI) = string(uri)
gitlab2json(dt::Dates.DateTime) = string(dt) * "Z"
gitlab2json(v::Vector) = [gitlab2json(i) for i in v]

function gitlab2json(g::GitLabType)
    results = Dict()
    for field in fieldnames(g)
        val = getfield(g, field)
        if !(isnull(val))
            key = field == :typ ? "type" : string(field)
            results[key] = gitlab2json(get(val))
        end
    end
    return results
end

function gitlab2json{K}(data::Dict{K})
    results = Dict{K,Any}()
    for (key, val) in data
        results[key] = gitlab2json(val)
    end
    return results
end

###################
# Pretty Printing #
###################

function Base.show(io::IO, g::GitLabType)
    print(io, "$(typeof(g)) (all fields are Nullable):")
    for field in fieldnames(g)
        val = getfield(g, field)
        if !(isnull(val))
            gotval = get(val)
            println(io)
            print(io, "  $field: ")
            if isa(gotval, Vector)
                print(io, typeof(gotval))
            else
                showcompact(io, gotval)
            end
        end
    end
end

function Base.showcompact(io::IO, g::GitLabType)
    uri_id = namefield(g)
    if isnull(uri_id)
        print(io, typeof(g), "(…)")
    else
        print(io, typeof(g), "($(repr(get(uri_id))))")
    end
end
