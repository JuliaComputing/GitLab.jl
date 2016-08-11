###############
# Commit Type #
###############

type Commit <: GitLabType
    id::Nullable{GitLabString}
    author_email::Nullable{GitLabString}
    title::Nullable{GitLabString}
    short_id::Nullable{GitLabString}
    message::Nullable{GitLabString}
    committer_name::Nullable{GitLabString}
    ## parents::Nullable{Vector{Commit}}
    parent_ids::Nullable{Vector{Any}}
    authored_date::Nullable{GitLabString}
    committer_email::Nullable{GitLabString}
    ## author_name::Nullable{Owner}
    author_name::Nullable{GitLabString}
    committed_date::Nullable{GitLabString}
    created_at::Nullable{GitLabString}
end

Commit(data::Dict) = json2gitlab(Commit, data)
Commit(id::AbstractString) = Commit(Dict("id" => id))

namefield(commit::Commit) = commit.id

###############
# API Methods #
###############

function commits(repo; options...)
    ## MDP results, page_data = gh_get_paged_json("/repos/$(name(repo))/commits"; options...)
    results, page_data = gh_get_paged_json("/api/v3/projects/$(get(repo.id))/repository/commits"; options...)
    return map(Commit, results), page_data
end

function commit(repo, sha; options...)
    ## MDP result = gh_get_json("/repos/$(name(repo))/commits/$(name(sha))"; options...)
    result = gh_get_json("/api/v3/projects/$(get(repo.id))/repository/commits/$(name(sha))"; options...)
    return Commit(result)
end
