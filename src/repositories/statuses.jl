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
end

Status(data::Dict) = json2gitlab(Status, data)
Status(id::Real) = Status(Dict("id" => id))

namefield(status::Status) = status.id

###############
# API Methods #
###############

function create_status(repo, sha; options...)
    result = gh_post_json("/api/v3/projects/$(repo.project_id.value)/statuses/$(name(sha))"; options...)
    return Status(result)
end

function statuses(repo, ref; options...)
    results, page_data = gh_get_paged_json("/api/v3/projects/$(repo.project_id.value)/commits/$(name(ref))/statuses"; options...)
    return map(Status, results), page_data
end

function status(repo, ref; options...)
    result = gh_get_json("/api/v3/projects/$(repo.project_id.value)/commits/$(name(ref))/status"; options...)
    return Status(result)
end
