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

branches = GitLab.branches(myrepo; params=options)
@show branches

println("Done !!!")


