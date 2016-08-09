#############
# Repo Type #
#############

type Repo <: GitLabType
    name::Nullable{GitLabString}
    visibility_level::Nullable{Int}
    homepage::Nullable{HttpCommon.URI}
    git_http_url::Nullable{HttpCommon.URI}
    description::Nullable{GitLabString}
    project_id::Nullable{Int}

    id::Nullable{Int}
    default_branch::Nullable{GitLabString}
    tag_list::Nullable{Vector{GitLabString}}
    public::Nullable{Bool}
    archived::Nullable{Bool}
    ## TODO FIX ssh_url_to_repo::Nullable{HttpCommon.URI}
    http_url_to_repo::Nullable{HttpCommon.URI}
    web_url::Nullable{HttpCommon.URI}
    owner::Nullable{Owner}
    name_with_namespace::Nullable{GitLabString}
    path::Nullable{GitLabString}
    path_with_namespace::Nullable{GitLabString}
    issues_enabled::Nullable{Bool}
    merge_requests_enabled::Nullable{Bool}
    wiki_enabled::Nullable{Bool}
    builds_enabled::Nullable{Bool}
    snippets_enabled::Nullable{Bool}
    container_registry_enabled::Nullable{Bool}
    created_at::Nullable{Dates.DateTime}
    last_activity_at::Nullable{Dates.DateTime}
    shared_runners_enabled::Nullable{Bool}
    creator_id::Nullable{Int}
    ## TODO FIX namespace::Nullable{Namespace}
    ## \"namespace\":{\"id\":2,\"name\":\"mdpradeep\",\"path\":\"mdpradeep\",\"owner_id\":2,\"created_at\":\"2016-06-17T07:09:56.494Z\",\"updated_at\":\"2016-06-17T07:09:56.494Z\",\"description\":\"\",\"avatar\":null,\"share_with_group_lock\":false,\"visibility_level\":20}
    avatar_url::Nullable{HttpCommon.URI}
    star_count::Nullable{Int}
    forks_count::Nullable{Int}
    open_issues_count::Nullable{Int}
    runners_token::Nullable{GitLabString}
    public_builds::Nullable{Bool}
    ## TODO permissions::Nullable{Permissions}
    ## \"permissions\":{\"project_access\":{\"access_level\":40,\"notification_level\":3},\"group_access\":null}
end

Repo(data::Dict) = json2gitlab(Repo, data)
## MDP Repo(full_name::AbstractString) = Repo(Dict("full_name" => full_name))
Repo(full_name::AbstractString) = Repo(Dict("name" => full_name))

## MDP namefield(repo::Repo) = repo.full_name
namefield(repo::Repo) = repo.name

###############
# API Methods #
###############

# repos #
#-------#

function repo_by_name(repo_name; options...)
    result = gh_get_json("/api/v3/projects/search/$(repo_name)"; options...)
    return Repo(result[1])
end

function repo(id; options...)
    ## result = gh_get_json("/repos/$(name(repo_obj))"; options...)
    result = gh_get_json("/api/v3/projects/$(id)"; options...)
    return Repo(result)
end

# forks #
#-------#

function forks(repo; options...)
    error("Not implemented yet !!")
    ## TODO
    ## results, page_data = gh_get_paged_json("/repos/$(name(repo))/forks"; options...)
    results, page_data = gh_get_paged_json("/api/v3/projects/$(get(repo.id))/forks"; options...)
    return map(Repo, results), page_data
end

function create_fork(repo; options...)
    ## result = gh_post_json("/repos/$(name(repo))/forks"; options...)
    result = gh_post_json("/api/v3/projects/fork/$(get(repo.id))"; options...)
    return Repo(result)
end

function delete_fork(repo; options...)
    ## /projects/:id/fork
    result = gh_delete_json("/api/v3/projects/$(get(repo.id))/fork"; options...)
    return Repo(result)
end

# contributors/collaborators #
#----------------------------#

function contributors(repo; options...)
    ## results, page_data = gh_get_paged_json("/repos/$(name(repo))/contributors"; options...)
    results, page_data = gh_get_paged_json("/api/v3/projects/$(get(repo.id))/repository/contributors"; options...)
    results = [Dict("contributor" => Owner(i), "contributions" => i["commits"]) for i in results]
    return results, page_data
end

function collaborators(repo; options...)
    ## MDP results, page_data = gh_get_json("/repos/$(name(repo))/collaborators"; options...)
    ## MDP results, page_data = gh_get_json("/api/v3/projects/$(get(repo.id))/repository/contributors"; options...)
    ## results, page_data = gh_get_paged_json("/api/v3/projects/$(get(repo.id))/members"; options...)
    results = gh_get_json("/api/v3/projects/$(get(repo.id))/members"; options...)
    return map(Owner, results)
end

function iscollaborator(repo, user; options...)
    collaborators = GitLab.collaborators(repo; options...)
    for c in collaborators
        if get(c.username) == user
            return true
        end
    end

    return false
end

function add_collaborator(repo, user; options...)
    ## MDP path = "/repos/$(name(repo))/collaborators/$(name(user))"
    ## path = "/api/v3/projects/$(get(repo.id))/members/$(user)"
    ## return gh_put(path; options...)
    path = "/api/v3/projects/$(get(repo.id))/members"
    return gh_post(path; options...)
end

function remove_collaborator(repo, user; options...)
    ## MDP path = "/repos/$(name(repo))/collaborators/$(name(user))"
    ## path = "/api/v3/projects/$(get(repo.id))/repository/contributors/$(name(user))"
    path = "/api/v3/projects/$(get(repo.id))/members/$(user)"
    return gh_delete(path; options...)
end

# stats #
#-------#

## TODO Check how to enable sidekiq stats !
function stats(repo, stat, attempts = 3; options...)
    ## MDP path = "/repos/$(name(repo))/stats/$(name(stat))"
    ## path = "/api/v3/projects/$(get(repo.id))/repository/stats/$(name(stat))"
    path = "/api/v3/projects/sidekiq/$(name(stat))"
    local r
    for a in 1:attempts
        r = gh_get(path; handle_error = false, options...)
        r.status == 200 && return r
        sleep(2.0)
    end
    return r
end
