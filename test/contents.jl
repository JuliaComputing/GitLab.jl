import GitLab
using Base.Test
myauth = GitLab.authenticate(ENV["GITLAB_AUTH"]) # don't hardcode your access tokens!
println("Authentication successful")
options = Dict("private_token" => myauth.token)

myrepo = GitLab.repo_by_name("TestProject1"; headers=options)

file = GitLab.file(myrepo, "src/file1", "master"; headers=options)
@test get(file.file_path) == "src/file1"

println("Content Tests Done !!!")


