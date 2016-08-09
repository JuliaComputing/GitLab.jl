import GitLab
using Base.Test
myauth = GitLab.authenticate(ENV["GITLAB_AUTH"]) # don't hardcode your access tokens!
println("Authentication successful")
options = Dict("private_token" => myauth.token)

myrepo = GitLab.repo_by_name("TestProject1"; headers=options)
## @show myrepo

r = GitLab.star(myrepo; params=options)
## @show r
## r.status of 201 means a new star and a response of 304 means that it was already present
@test  r.status == 201 || r.status == 304

r = GitLab.unstar(myrepo; params=options)
## @show r
@test r.status == 200

println("Activity Tests Done !!!")


