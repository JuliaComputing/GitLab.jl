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

issues, page_data = GitLab.issues(myrepo; params=options)
@show issues

## get specific issues:
## state        string  no  Return all issues or just those that are opened or closed
## labels       string  no  Comma-separated list of label names, issues with any of the labels will be returned
## order_by     string  no  Return requests ordered by created_at or updated_at fields. Default is created_at
## sort         string  no  Return requests sorted in asc or desc order. Default is desc
options["labels"] = "MyLabel"
issues = GitLab.issues(myrepo; params=options)
@show issues

issue = issues[1]

options["labels"] = "wronglabel"
issues, page_data = GitLab.issues(myrepo; params=options)
@show issues
if sizeof(issues) == 0
    println("Test passed")
else
    println("Test failed")
end
if haskey(options, "labels")
    delete!(options, "labels")
end

issue = GitLab.issue(myrepo, get(issue[1].id); params=options)
@show issue

issue_data = Dict{AbstractString, Any}()
issue_data["title"] = "This is a test"
issue_data["description"] = "This is some description"
issue = GitLab.create_issue(myrepo; params=issue_data, headers=options)
@show issue

issue_data["title"] = "This is a test - edit"
issue_data["description"] = "This is some description - edit"
issue = GitLab.edit_issue(myrepo, get(issue.id); params=issue_data, headers=options)
@show issue

println("Sleeping before deleting the issue !!")
sleep(10)

del_issue = GitLab.delete_issue(myrepo, get(issue.id); params=issue_data, headers=options)
@show del_issue


println("Done !!!")

