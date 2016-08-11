##############
# Issue type #
##############

type Issue <: GitLabType
    id::Nullable{Int}
    iid::Nullable{Int}
    project_id::Nullable{Int}
    title::Nullable{GitLabString}
    description::Nullable{GitLabString}
    state::Nullable{GitLabString}
    created_at::Nullable{Dates.DateTime}
    updated_at::Nullable{Dates.DateTime}
    ## labels::Nullable{Vector{Dict}}
    labels::Nullable{Vector{GitLabString}}
    milestone::Nullable{GitLabString}
    assignee::Nullable{Owner}
    author::Nullable{Owner}
    subscribed::Nullable{Bool}
    user_notes_count::Nullable{Int}

#=
    closed_by::Nullable{Owner}
    closed_at::Nullable{Dates.DateTime}
    pull_request::Nullable{PullRequest}
    url::Nullable{HttpCommon.URI}
    html_url::Nullable{HttpCommon.URI}
    labels_url::Nullable{HttpCommon.URI}
    comments_url::Nullable{HttpCommon.URI}
    events_url::Nullable{HttpCommon.URI}
    locked::Nullable{Bool}
=#
end

Issue(data::Dict) = json2gitlab(Issue, data)
Issue(id::Int) = Issue(Dict("id" => id))

namefield(issue::Issue) = issue.id

###############
# API Methods #
###############

function issue(repo::Repo, issue::Int; options...)
    result = gh_get_json("/api/v3/projects/$(get(repo.id))/issues/$(issue)"; options...)
    return Issue(result)
end

function issues(repo::Repo; options...)
    results, page_data = gh_get_paged_json("/api/v3/projects/$(get(repo.id))/issues"; options...)
    return map(Issue, results), page_data
end

function create_issue(repo::Repo; options...)
    result = gh_post_json("/api/v3/projects/$(get(repo.id))/issues"; options...)
    return Issue(result)
end

function edit_issue(repo::Repo, issue::Int; options...)
    result = gh_put_json("/api/v3/projects/$(get(repo.id))/issues/$(issue)"; options...)
    return Issue(result)
end

function delete_issue(repo::Repo, issue::Int; options...)
    result = gh_delete_json("/api/v3/projects/$(get(repo.id))/issues/$(issue)"; options...)
    return Issue(result)
end
