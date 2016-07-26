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

statuses = GitLab.statuses(myrepo, "5c35ae1de7f6d6bfadf0186e165f7af6537e7da8"; params=options)
@show statuses

status_data = Dict{AbstractString, Any}()
status_data["state"] = "running"
status = GitLab.create_status(myrepo, "5c35ae1de7f6d6bfadf0186e165f7af6537e7da8"; headers=options, params=status_data)
@show status

status_data["state"] = "invalid"
try
    status = GitLab.create_status(myrepo, "5c35ae1de7f6d6bfadf0186e165f7af6537e7da8"; headers=options, params=status_data)
catch e
    println("Failed to update status : $(e)")
end
println("Done !!!")


