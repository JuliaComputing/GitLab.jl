############
# Starring #
############

#= Seems like there is no equivalent of this method to get the watchers of repos
function stargazers(repo; options...)
    ## results, page_data = gh_get_paged_json("/repos/$(name(repo))/stargazers"; options...)
    results, page_data = gh_get_paged_json("/api/v3/projects/$(get(repo.id))/star"; options...)
    return map(Owner, results), page_data
end
=#

function starred(user; options...)
    ## results, page_data = gh_get_paged_json("/api/v3/users/$(name(user))/starred"; options...)
    results, page_data = gh_get_paged_json("/api/v3/projects/starred"; options...)
    return map(Repo, results), page_data
end

## star(repo; options...) = gh_put("/user/starred/$(name(repo))"; options...)
star(repo; options...) = gh_post("/api/v3/projects/$(get(repo.id))/star"; options...)

## unstar(repo; options...) = gh_delete("/user/starred/$(name(repo))"; options...)
unstar(repo; options...) = gh_delete("/api/v3/projects/$(get(repo.id))/star"; options...)

############
# Watching #
############

#= Seems like there is no equivalent of these methods
function watchers(repo; options...)
    ## results, page_data = gh_get_paged_json("/repos/$(name(repo))/subscribers"; options...)
    results, page_data = gh_get_paged_json("/api/v3/projects/$(get(repo.id))/subscribers"; options...)
    return map(Owner, results), page_data
end

function watched(owner; options...)
    results, page_data = gh_get_paged_json("/api/v3/users/$(name(owner))/subscriptions"; options...)
    return map(Repo, results), page_data
end

## watch(repo; options...) = gh_put("/repos/$(name(repo))/subscription"; options...)
watch(repo; options...) = gh_put("/api/v3/projects/$(get(repo.id))/subscription"; options...)

## unwatch(repo; options...) = gh_delete("/repos/$(name(repo))/subscription"; options...)
unwatch(repo; options...) = gh_delete("/api/v3/projects/$(get(repo.id))/subscription"; options...)
=#
