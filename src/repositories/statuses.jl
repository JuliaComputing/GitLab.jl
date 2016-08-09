###############
# Status type #
###############

type Status <: GitLabType
    id::Nullable{Int}
    total_count::Nullable{Int}
    state::Nullable{GitLabString}
    description::Nullable{GitLabString}
    context::Nullable{GitLabString}
    sha::Nullable{GitLabString}
    url::Nullable{HttpCommon.URI}
    target_url::Nullable{HttpCommon.URI}
    created_at::Nullable{Dates.DateTime}
    updated_at::Nullable{Dates.DateTime}
    creator::Nullable{Owner}
    repository::Nullable{Repo} 
    statuses::Nullable{Vector{Status}}

    ## For commit status
    status::Nullable{GitLabString}
    name::Nullable{GitLabString}
    author::Nullable{Owner}
    ref::Nullable{GitLabString}
    started_at::Nullable{Dates.DateTime}
    finished_at::Nullable{Dates.DateTime}
    allow_failure::Nullable{Bool}
end

Status(data::Dict) = json2gitlab(Status, data)
Status(id::Real) = Status(Dict("id" => id))

namefield(status::Status) = status.id

###############
# API Methods #
###############

function create_status(repo, sha; options...)
    result = gh_post_json("/api/v3/projects/$(get(repo.id))/statuses/$(name(sha))"; options...)
    return Status(result)
end

function statuses(repo, ref; options...)
    results, page_data = gh_get_paged_json("/api/v3/projects/$(get(repo.id))/repository/commits/$(name(ref))/statuses"; options...)
    return map(Status, results), page_data
end

#= TODO: no equivalent API
function status(repo, ref; options...)
    result = gh_get_json("/api/v3/projects/$(get(repo.id))/commits/$(name(ref))/status"; options...)
    return Status(result)
end
=#
