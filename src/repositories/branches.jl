###############
# Branch Type #
###############

type Branch <: GitLabType
    name::Nullable{GitLabString}
    protected::Nullable{Bool}
    commit::Nullable{Commit}
#=
    label::Nullable{GitLabString}
    ref::Nullable{GitLabString}
    sha::Nullable{GitLabString}
    user::Nullable{Owner}
    repo::Nullable{Repo}
    _links::Nullable{Dict}
    protection::Nullable{Dict}
=#
end

Branch(data::Dict) = json2gitlab(Branch, data)
Branch(name::AbstractString) = Branch(Dict("name" => name))

## namefield(branch::Branch) = isnull(branch.name) ? branch.ref : branch.name
namefield(branch::Branch) = branch.name

###############
# API Methods #
###############

function branches(repo; options...)
    ## MDP results, page_data = gh_get_paged_json("/repos/$(name(repo))/branches"; options...)
    results, page_data = gh_get_paged_json("/api/v3/projects/$(get(repo.id))/repository/branches"; options...)
    return map(Branch, results), page_data
end

function branch(repo, branch; options...)
    ## result = gh_get_json("/repos/$(name(repo))/branches/$(name(branch))"; options...)
    result = gh_get_json("/api/v3/projects/$(get(repo.id))/repository/branches/$(name(branch))"; options...)
    return Branch(result)
end
