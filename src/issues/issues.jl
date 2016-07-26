##############
# Issue type #
##############

type Issue <: GitLabType
## {\"id\":3,\"iid\":3,\"project_id\":1,\"title\":\"Test Issue ...\",\"description\":\"fix XYZ\",\"state\":\"opened\",\"created_at\":\"2016-07-21T12:07:26.632Z\",\"updated_at\":\"2016-07-21T12:08:42.755Z\",\"labels\":[],\"milestone\":null,\"assignee\":null,\"author\":{\"name\":\"Pradeep\",\"username\":\"mdpradeep\",\"id\":2,\"state\":\"active\",\"avatar_url\":\"http://www.gravatar.com/avatar/a3918c0a2d98a6606bd787c54e6e5268?s=80\\u0026d=identicon\",\"web_url\":\"http://104.197.141.88/u/mdpradeep\"},\"subscribed\":true,\"user_notes_count\":2}

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

namefield(issue::Issue) = issue.number

###############
# API Methods #
###############

function issue(repo::Repo, issue_id::Int; options...)
    result = gh_get_json("/api/v3/projects/$(repo.project_id.value)/issues/$(issue_id)"; options...)
    return Issue(result)
end

function issues(repo::Repo; options...)
    results, page_data = gh_get_paged_json("/api/v3/projects/$(repo.project_id.value)/issues"; options...)
    return map(Issue, results), page_data
end

function create_issue(repo::Repo; options...)
    result = gh_post_json("/api/v3/projects/$(repo.project_id.value)/issues"; options...)
    return Issue(result)
end

function edit_issue(repo::Repo, issue_id::Int; options...)
    result = gh_put_json("/api/v3/projects/$(repo.project_id.value)/issues/$(issue_id)"; options...)
    return Issue(result)
end

function delete_issue(repo::Repo, issue_id::Int; options...)
    result = gh_delete_json("/api/v3/projects/$(repo.project_id.value)/issues/$(issue_id)"; options...)
    return Issue(result)
end
