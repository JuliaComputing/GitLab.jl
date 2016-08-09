import GitLab
using Base.Test

myauth = GitLab.authenticate(ENV["GITLAB_AUTH"]) # don't hardcode your access tokens!
println("Authentication successful")
options = Dict("private_token" => myauth.token)

myrepo = GitLab.repo_by_name("TestProject1"; headers=options)

## Create new owner:
user_info = Dict{AbstractString, Any}()
user_info["name"] = "Test User"
user_info["username"] = "testuser"
own = GitLab.Owner(user_info)
## @show own

name = GitLab.namefield(own)
@test get(name) == user_info["username"] 

setindex!(options, "mdpradeep", "username")

new_owner = GitLab.owner("mdpradeep", false; headers = options)
## @show new_owner

users, page_data = GitLab.users(; params = options)
## @show users, page_data
@test GitLab.name(first(users)) == "mdpradeep"

orgs, page_data = GitLab.orgs(own; params=options)
@test GitLab.name(last(orgs)) == "TestProject1"
## @show orgs, page_data

#=
followers, page_data  = GitLab.followers(own; params=options)
@show followers, page_data

following, page_data  = GitLab.following(own; params=options)
@show following, page_data
=#

repos, page_data  = GitLab.repos(own; params=options)
@test GitLab.name(last(repos)) == "TestProject1"
## @show repos, page_data

println("Owner Tests Done !!!")
