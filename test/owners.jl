import GitLab
myauth = GitLab.authenticate(ENV["GITLAB_AUTH"]) # don't hardcode your access tokens!
println("Authentication successful")
options = Dict("private_token" => myauth.token)
## @show options

repo_data = Dict{AbstractString, Any}()
repo_data["name"] = "TestProject1"
repo_data["project_id"] = 1

## myrepo = GitLab.Repo("TestProject1")
myrepo = GitLab.Repo(repo_data)

@show myrepo



## Create new owner:

user_info = Dict{AbstractString, Any}()
user_info["name"] = "Test User"
user_info["username"] = "testuser"
own = GitLab.Owner(user_info)
@show own

name = GitLab.namefield(own)
@show name

push!(options, "username", "mdpradeep")

new_owner = GitLab.owner("mdpradeep", false; headers = options)
@show new_owner

users, page_data = GitLab.users(; params = options)
@show users, page_data

orgs, page_data = GitLab.orgs(own; params=options)
@show orgs, page_data

#=
followers, page_data  = GitLab.followers(own; params=options)
@show followers, page_data

following, page_data  = GitLab.following(own; params=options)
@show following, page_data
=#

repos, page_data  = GitLab.repos(own; params=options)
@show repos, page_data

println("Done !!!")
