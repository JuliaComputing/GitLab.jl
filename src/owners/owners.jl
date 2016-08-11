##############
# Owner Type #
##############


type Owner <: GitLabType
    name::Nullable{GitLabString}
    username::Nullable{GitLabString}
    id::Nullable{Int}
    state::Nullable{GitLabString}
    avatar_url::Nullable{HttpCommon.URI}
    web_url::Nullable{HttpCommon.URI}
    ownership_type::Nullable{GitLabString} 

#=
    email::Nullable{GitLabString}
    bio::Nullable{GitLabString}
    company::Nullable{GitLabString}
    location::Nullable{GitLabString}
    gravatar_id::Nullable{GitLabString}
    public_repos::Nullable{Int}
    owned_private_repos::Nullable{Int}
    total_private_repos::Nullable{Int}
    public_gists::Nullable{Int}
    private_gists::Nullable{Int}
    followers::Nullable{Int}
    following::Nullable{Int}
    collaborators::Nullable{Int}
    html_url::Nullable{HttpCommon.URI}
    updated_at::Nullable{Dates.DateTime}
    created_at::Nullable{Dates.DateTime}
    date::Nullable{Dates.DateTime}
    hireable::Nullable{Bool}
    site_admin::Nullable{Bool}
=#
end

function Owner(data::Dict) 
    o = json2gitlab(Owner, data)
    isnull(o.username) ? o.ownership_type = Nullable("Organization") : o.ownership_type = Nullable("User")
    o
end

Owner(username::AbstractString, isorg = false) = Owner(
    Dict("username" => isorg ? "" : username, 
         "name" => isorg ? username : "",
         "ownership_type" => isorg ? "Organization" : "User"))
## Owner(username::AbstractString) = Owner(Dict("username" => username))

## namefield(owner::Owner) = owner.ownership_type == "Organization" ? owner.name : owner.username
namefield(owner::Owner) = isorg(owner) ? owner.name : owner.username

## typprefix(isorg) = isorg ? "orgs" : "users"
typprefix(isorg) = isorg ? "projects" : "users"

#############
# Owner API #
#############

isorg(owner::Owner) = isnull(owner.ownership_type) ? true : get(owner.ownership_type, "") == "Organization"

owner(owner_obj::Owner; options...) = owner(name(owner_obj), isorg(owner_obj); options...)

function owner(owner_obj, isorg = false; options...)
    ## TODO Need to look for a cleaner way of doing this ! Returns an array even while requesting a specific user
    if isorg
        result = gh_get_json("/api/v3/projects/search/$(owner_obj)"; options...)
        return Owner(result[1]["owner"])
    else
        result = gh_get_json("/api/v3/users?username=$(owner_obj)"; options...)
        return Owner(result[1])
    end
end

function users(; options...)
    results, page_data = gh_get_paged_json("/api/v3/users"; options...)
    return map(Owner, results), page_data
end

function orgs(owner; options...)
    ## results, page_data = gh_get_paged_json("/api/v3/users/$(name(owner))/projects"; options...)
    results, page_data = gh_get_paged_json("/api/v3/projects"; options...)
    return map(Owner, results), page_data
end

#= TODO: There seems to be no equivalent for these APIs 
function followers(owner; options...)
    results, page_data = gh_get_paged_json("/api/v3/users/$(name(owner))/followers"; options...)
    return map(Owner, results), page_data
end

function following(owner; options...)
    results, page_data = gh_get_paged_json("/api/v3/users/$(name(owner))/following"; options...)
    return map(Owner, results), page_data
end
=#

repos(owner::Owner; options...) = repos(name(owner), isorg(owner); options...)

function repos(owner, isorg = false; options...)
    ## results, page_data = gh_get_paged_json("/api/v3/$(typprefix(isorg))/$(name(owner))/repos"; options...)
    results, page_data = gh_get_paged_json("/api/v3/projects/owned"; options...)
    return map(Repo, results), page_data
end
