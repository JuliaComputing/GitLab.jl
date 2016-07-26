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

merge_requests, page_data = GitLab.pull_requests(myrepo; params=options)
@show merge_requests

@show merge_requests[1]
merge_request = GitLab.pull_request(myrepo, merge_requests[1].id.value; params=options)
@show merge_request

println("Done !!!")


