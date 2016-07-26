import GitLab
myauth = GitLab.authenticate(ENV["GITLAB_AUTH"]) # don't hardcode your access tokens!
println("Authentication successful")
options = Dict("private_token" => myauth.token)
## @show options

repo_data = Dict{AbstractString, Any}()
repo_data["name"] = "TestProject1"
repo_data["project_id"] = 1

myrepo = GitLab.Repo(repo_data)
@show myrepo

#= REMOVE 
simple_repo = GitLab.Repo("SimpleRepo")
@show simple_repo

@show GitLab.namefield(simple_repo)

repo = GitLab.repo(myrepo; params=options)
@show repo

try ## remove this later 
forks = GitLab.forks(myrepo; params=options)
@show forks
end

repo_data = Dict{AbstractString, Any}()
repo_data["name"] = "admin-project"
repo_data["project_id"] = 4
yourrepo = GitLab.Repo(repo_data)
yourrepo = GitLab.repo(yourrepo; params=options)
@show yourrepo

forked_repo = GitLab.create_fork(yourrepo; headers=options)
@show forked_repo

repo = GitLab.delete_fork(forked_repo; headers=options)
@show repo

contributors = GitLab.contributors(myrepo, params=options)
@show contributors

collaborators = GitLab.collaborators(myrepo, params=options)
@show collaborators

collaborator = GitLab.iscollaborator(myrepo, "mdpradeep", params=options)
@show collaborator

non_collaborator = GitLab.iscollaborator(myrepo, "XXXXX", params=options)
@show non_collaborator
=#

user_data = Dict{AbstractString, Any}()
user_data["user_id"] = 3
user_data["access_level"] = 40
result = GitLab.add_collaborator(myrepo, "3", headers=options, params=user_data)
## result = GitLab.add_collaborator(myrepo, "", headers=options, params=user_data)
if result.status <= 204
    println("Successfully added collaborator $(UTF8String(result.data))")
else
    println("Failed to added collaborator $(UTF8String(result.data))")
end

no_user_data = Dict{AbstractString, Any}()
no_user_data["user_id"] = 999
no_user_data["access_level"] = 40
try
    result = GitLab.add_collaborator(myrepo, "999", headers=options, params=no_user_data)
    if result.status <= 204
        println("Successfully added collaborator $(UTF8String(result.data))")
    else
        println("Failed to added collaborator $(UTF8String(result.data))")
    end
catch e
    println("Failed to added collaborator $(e)")
    ## This is the expected behavior in this case
end

result = GitLab.remove_collaborator(myrepo, "3", headers=options, params=user_data)
@show result

try 
    result = GitLab.remove_collaborator(myrepo, "999", headers=options, params=user_data)
    @show result
catch 3
    println("Failed to remove collaborator $(e)")
    ## This is the expected behavior in this case
end

println("Done !!!")


