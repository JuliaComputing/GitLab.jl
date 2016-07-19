#############
# Repo Type #
#############

type Repo <: GitLabType
    #=
    full_name::Nullable{GitLabString}
    language::Nullable{GitLabString}
    default_branch::Nullable{GitLabString}
    owner::Nullable{Owner}
    parent::Nullable{Repo}
    source::Nullable{Repo}
    size::Nullable{Int}
    subscribers_count::Nullable{Int}
    forks_count::Nullable{Int}
    stargazers_count::Nullable{Int}
    watchers_count::Nullable{Int}
    open_issues_count::Nullable{Int}
    html_url::Nullable{HttpCommon.URI}
    pushed_at::Nullable{Dates.DateTime}
    created_at::Nullable{Dates.DateTime}
    updated_at::Nullable{Dates.DateTime}
    has_issues::Nullable{Bool}
    has_wiki::Nullable{Bool}
    has_downloads::Nullable{Bool}
    has_pages::Nullable{Bool}
    private::Nullable{Bool}
    fork::Nullable{Bool}
    permissions::Nullable{Dict}
    =#

    name::Nullable{GitLabString}
    visibility_level::Nullable{Int}
    homepage::Nullable{HttpCommon.URI}
    git_http_url::Nullable{HttpCommon.URI}
    ## url::Nullable{HttpCommon.URI}
    description::Nullable{GitLabString}
    ## git_ssh_url::Nullable{HttpCommon.URI}
    project_id::Nullable{Int}
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

function repo(repo_obj; options...)
    result = gh_get_json("/repos/$(name(repo_obj))"; options...)
    return Repo(result)
end

# forks #
#-------#

function forks(repo; options...)
    results, page_data = gh_get_paged_json("/repos/$(name(repo))/forks"; options...)
    return map(Repo, results), page_data
end

function create_fork(repo; options...)
    result = gh_post_json("/repos/$(name(repo))/forks"; options...)
    return Repo(result)
end

# contributors/collaborators #
#----------------------------#

function contributors(repo; options...)
    results, page_data = gh_get_paged_json("/repos/$(name(repo))/contributors"; options...)
    results = [Dict("contributor" => Owner(i), "contributions" => i["contributions"]) for i in results]
    return results, page_data
end

function collaborators(repo; options...)
    ## MDP results, page_data = gh_get_json("/repos/$(name(repo))/collaborators"; options...)
    ## http://104.197.141.88/api/v3/projects/:id/repository/contributors
    results = gh_get_json("/api/v3/projects/$(name(repo))/repository/contributors"; options...)
    @show results
    ## results, page_data = gh_get_json("/api/v3/projects/$(name(repo))/repository/contributors"; options...)
    ## return map(Owner, results), page_data
    return map(Owner, results)
end

function iscollaborator(repo, user; options...)
    ## MDP path = "/repos/$(name(repo))/collaborators/$(name(user))"
## @show repo
## @show user
    path = "/api/v3/projects/$(name(repo))/repository/contributors/$(name(user))"
    r = gh_get(path; handle_error = false, options...)
    @show r

## MDP Currently there seems to be no easy way to check this. We may need to compare email ids ?
## MDP For now return true !
return true
    r.status == 204 && return true
    r.status == 404 && return false
    handle_response_error(r)  # 404 is not an error in this case
    return false
end

function add_collaborator(repo, user; options...)
    ## MDP path = "/repos/$(name(repo))/collaborators/$(name(user))"
    path = "/api/v3/projects/$(repo.project_id.value)/repository/contributors/$(name(user))"
    return gh_put(path; options...)
end

function remove_collaborator(repo, user; options...)
    ## MDP path = "/repos/$(name(repo))/collaborators/$(name(user))"
    path = "/api/v3/projects/$(repo.project_id.value)/repository/contributors/$(name(user))"
    return gh_delete(path; options...)
end

# stats #
#-------#

function stats(repo, stat, attempts = 3; options...)
    ## MDP path = "/repos/$(name(repo))/stats/$(name(stat))"
    path = "/api/v3/projects/$(repo.project_id.value)/repository/stats/$(name(stat))"
    local r
    for a in 1:attempts
        r = gh_get(path; handle_error = false, options...)
        r.status == 200 && return r
        sleep(2.0)
    end
    return r
end
