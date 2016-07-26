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

r = GitLab.star(myrepo; params=options)
## @show r
## r.status of 201 means a new star and a response of 304 means that it was already present
if r.status == 201 || r.status == 304
    println("Star Test successful")
else
    println("Star Test failed")
end

r = GitLab.unstar(myrepo; params=options)
## @show r
if r.status == 200
    println("Unstar Test successful")
else
    println("Unstar Test failed")
end

println("Done !!!")


