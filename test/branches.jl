import GitLab
using Base.Test
myauth = GitLab.authenticate(ENV["GITLAB_AUTH"]) # don't hardcode your access tokens!
println("Authentication successful")
options = Dict("private_token" => myauth.token)

myrepo = GitLab.repo_by_name("TestProject1"; headers=options)

branches = first(GitLab.branches(myrepo; params=options))

@test GitLab.name(branches[1]) == "branch1"
## @show branches

println("Branches - Tests Done !!!")


