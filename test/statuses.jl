import GitLab
using Base.Test

myauth = GitLab.authenticate(ENV["GITLAB_AUTH"]) # don't hardcode your access tokens!
println("Authentication successful")
options = Dict("private_token" => myauth.token)

myrepo = GitLab.repo_by_name("TestProject1"; headers=options)
## @show myrepo

statuses = GitLab.statuses(myrepo, "5c35ae1de7f6d6bfadf0186e165f7af6537e7da8"; params=options)
@test get(first(statuses)[1].sha) == "5c35ae1de7f6d6bfadf0186e165f7af6537e7da8"
## @show statuses

status_data = Dict{AbstractString, Any}()
status_data["state"] = "running"
status = GitLab.create_status(myrepo, "5c35ae1de7f6d6bfadf0186e165f7af6537e7da8"; headers=options, params=status_data)
@test get(status.sha) == "5c35ae1de7f6d6bfadf0186e165f7af6537e7da8"
## @show status

status_data["state"] = "invalid"
try
    status = GitLab.create_status(myrepo, "5c35ae1de7f6d6bfadf0186e165f7af6537e7da8"; headers=options, params=status_data)
    @test 1 == 0
catch e
    println("Failed (Expected)  to update status : $(e)")
end
println("Statuses Tests Done !!!")


