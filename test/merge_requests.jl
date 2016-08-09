import GitLab
using Base.Test

myauth = GitLab.authenticate(ENV["GITLAB_AUTH"]) # don't hardcode your access tokens!
println("Authentication successful")
options = Dict("private_token" => myauth.token)

myrepo = GitLab.repo_by_name("TestProject1"; headers=options)

merge_requests, page_data = GitLab.pull_requests(myrepo; params=options)
## @show merge_requests

merge_request = GitLab.pull_request(myrepo, get(merge_requests[1].id); params=options)
## @show merge_request
@test get(merge_request.title) == "test"

println("Merge Request Tests Done !!!")


