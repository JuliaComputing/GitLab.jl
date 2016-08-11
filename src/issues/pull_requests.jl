####################
# PullRequest Type #
####################

type PullRequest <: GitLabType
    id::Nullable{Int}
    iid::Nullable{Int}
    project_id::Nullable{Int}
    title::Nullable{GitLabString}
    description::Nullable{GitLabString}
    state::Nullable{GitLabString}
    created_at::Nullable{Dates.DateTime}
    updated_at::Nullable{Dates.DateTime}
    target_branch::Nullable{GitLabString}
    source_branch::Nullable{GitLabString}
    upvotes::Nullable{Int}
    downvotes::Nullable{Int}
    author::Nullable{Owner}
    assignee::Nullable{Owner}
    source_project_id::Nullable{Int}
    target_project_id::Nullable{Int}
    labels::Nullable{Vector{GitLabString}}
    work_in_progress::Nullable{Bool}
    milestone::Nullable{GitLabString}
    merge_when_build_succeeds::Nullable{Bool}
    merge_status::Nullable{GitLabString}
    subscribed::Nullable{Bool}
    user_notes_count::Nullable{Int}


#=
    base::Nullable{Branch}
    head::Nullable{Branch}
    number::Nullable{Int}
    comments::Nullable{Int}
    commits::Nullable{Int}
    additions::Nullable{Int}
    deletions::Nullable{Int}
    changed_files::Nullable{Int}
    merge_commit_sha::Nullable{GitLabString}
    closed_at::Nullable{Dates.DateTime}
    merged_at::Nullable{Dates.DateTime}
    url::Nullable{HttpCommon.URI}
    html_url::Nullable{HttpCommon.URI}
    merged_by::Nullable{Owner}
    _links::Nullable{Dict}
    mergeable::Nullable{Bool}
    merged::Nullable{Bool}
    locked::Nullable{Bool}
=#
end

PullRequest(data::Dict) = json2gitlab(PullRequest, data)
PullRequest(id::Int) = PullRequest(Dict("id" => id))

namefield(pr::PullRequest) = pr.id

###############
# API Methods #
###############

function pull_requests(repo::Repo; options...)
    results, page_data = gh_get_paged_json("/api/v3/projects/$(get(repo.id))/merge_requests"; options...)
    return map(PullRequest, results), page_data
end

function pull_request(repo::Repo, pr::Int; options...)
    result = gh_get_json("/api/v3/projects/$(get(repo.id))/merge_requests/$(pr)"; options...)
    return PullRequest(result)
end
