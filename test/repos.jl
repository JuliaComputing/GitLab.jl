import GitLab
using Base.Test

myauth = GitLab.authenticate(ENV["GITLAB_AUTH"]) # don't hardcode your access tokens!
println("Authentication successful")
options = Dict("private_token" => myauth.token)

myrepo = GitLab.repo_by_name("TestProject1"; headers=options)
## @show myrepo

@test get(GitLab.namefield(myrepo)) == "TestProject1"


try ## remove this later 
    forks = GitLab.forks(myrepo; params=options)
    @show forks
end

yourrepo = GitLab.repo_by_name("admin-project"; headers=options)
## @show yourrepo

try ## This may fail if the fork already exists
    forked_repo = GitLab.create_fork(yourrepo; headers=options)
    @show forked_repo

    repo = GitLab.delete_fork(forked_repo; headers=options)
    @show repo
end

contributors = GitLab.contributors(myrepo, params=options)
@test GitLab.name(first(contributors)[1]["contributor"]) == "Pradeep Mudlapur"
## @show contributors

collaborators = GitLab.collaborators(myrepo, params=options)
@test GitLab.name(first(collaborators)) == "mdpradeep"
## @show collaborators

collaborator = GitLab.iscollaborator(myrepo, "mdpradeep", params=options)
@test collaborator == true
## @show collaborator

non_collaborator = GitLab.iscollaborator(myrepo, "XXXXX", params=options)
@test non_collaborator == false
## @show non_collaborator

user_data = Dict{AbstractString, Any}()
user_data["user_id"] = 3
user_data["access_level"] = 40
result = GitLab.add_collaborator(myrepo, "3", headers=options, params=user_data)
## result = GitLab.add_collaborator(myrepo, "", headers=options, params=user_data)
@test result.status <= 204

no_user_data = Dict{AbstractString, Any}()
no_user_data["user_id"] = 999
no_user_data["access_level"] = 40
try
    result = GitLab.add_collaborator(myrepo, "999", headers=options, params=no_user_data)
    @test result.status <= 204
catch e
    println("Failed (expected) to added collaborator $(e)")
    ## This is the expected behavior in this case
end

result = GitLab.remove_collaborator(myrepo, "3", headers=options, params=user_data)
@test result.status == 200
## @show result

try 
    result = GitLab.remove_collaborator(myrepo, "999", headers=options, params=user_data)
    @test result.status == 200
    ## @show result
catch e
    println("Failed (expected) to remove collaborator $(e)")
    ## This is the expected behavior in this case
end

println("Repos Tests Done !!!")


