using GitLab, GitLab.name
using Base.Test

# The below tests are network-dependent, and actually make calls to GitLab's API

## testuser = Owner("julia-gitlab-test-bot")
testuser = Owner("mdpradeep")
julweb = Owner("TestProject1", true)
testcommit = Commit("93add52417601de893c3db3b30276c576933bf33")

hasghobj(obj, items) = any(x -> name(x) == name(obj), items)

auth = GitLab.authenticate(ENV["GITLAB_AUTH"]) # don't hardcode access tokens!
println("Authentication successful")
options = Dict("private_token" => auth.token)
ghjl = GitLab.repo_by_name("Calculus"; headers=options)

## @test rate_limit(; headers = options)["rate"]["limit"] == 5000

##########
# Owners #
##########

# test GitLab.owner
@test name(owner(testuser; headers = options)) == name(testuser)
## TODO CHECK @test name(owner(julweb; headers = options)) == name(julweb)

# test GitLab.orgs
## TODO CHECK @test hasghobj("TestProject1", orgs("TestProject1"; headers = options))

#= No equivalent APIs
# test GitLab.followers, GitLab.following
@test hasghobj("mdpradeep", first(followers(testuser; headers = options)))
@test hasghobj("mdpradeep", first(following(testuser; headers = options)))
=#

# test GitLab.repos
@test hasghobj(ghjl, first(repos(julweb; headers = options)))

################
# Repositories #
################

# test GitLab.repo
@test name(repo(get(ghjl.id); headers = options)) == name(ghjl)

#= No equivalent API
# test GitLab.forks
@test length(first(forks(ghjl; headers = options))) > 0
=#

# test GitLab.contributors
@test hasghobj("Pradeep Mudlapur", map(x->x["contributor"], first(contributors(ghjl; headers = options))))

# test GitLab.stats
## TODO - Enable @test stats(ghjl, "compound_metrics"; headers = options).status < 300

# test GitLab.branch, GitLab.branches
@test name(branch(ghjl, "master"; headers = options)) == "master"
@test hasghobj("master", first(branches(ghjl; headers = options)))

# test GitLab.commit, GitLab.commits
@test name(commit(ghjl, testcommit; headers = options)) == name(testcommit)
@test hasghobj(testcommit, first(commits(ghjl; headers = options)))

# test GitLab.file, GitLab.directory, GitLab.readme, GitLab.permalink
readme_file = file(ghjl, "README.md", "master"; headers = options)
#= No equivalent API - directory()
src_dir = first(directory(ghjl, "src"; headers = options))
owners_dir = src_dir[findfirst(c -> get(c.path) == "src/owners", src_dir)]
test_sha = "eab14e1ab7b4de848ef6390101b6d40b489d5d08"
readme_permalink = string(permalink(readme_file, test_sha))
owners_permalink = string(permalink(owners_dir, test_sha))
@test readme_permalink == "https://github.com/JuliaComputing/GitLab.jl/blob/$(test_sha)/README.md"
@test owners_permalink == "https://github.com/JuliaComputing/GitLab.jl/tree/$(test_sha)/src/owners"
@test hasghobj("src/GitLab.jl", src_dir)
=#

@test readme_file == readme(ghjl; headers = options)
# test GitLab.status, GitLab.statuses
## TODO No equivalent API @test get(status(ghjl, testcommit; headers = options).sha) == name(testcommit)
@test !(isempty(first(statuses(ghjl, testcommit; headers = options))))

test_repo = GitLab.repo_by_name("TestProject1"; headers=options)
# test GitLab.comment, GitLab.comments
## TODO - CHECK  @test name(comment(test_repo, 9, :commit; headers = options)) == 9
@test !(isempty(first(comments(test_repo, "5c35ae1de7f6d6bfadf0186e165f7af6537e7da8", :commit; headers = options))))

# These require `auth` to have push-access
@test hasghobj("mdpradeep", collaborators(ghjl; headers = options))
@test iscollaborator(ghjl, "mdpradeep"; headers = options)

##########
# Issues #
##########

## TODO - check
state_param = Dict("state" => "all")

# test GitLab.pull_request, GitLab.pull_requests
@test get(pull_request(test_repo, 3; headers = options).title) == "edit"
@test hasghobj(3, first(pull_requests(test_repo; headers = options, params = state_param)))

# test GitLab.issue, GitLab.issues
@test get(issue(test_repo, 6; headers = options).title) == "This is a test"
@test hasghobj(6, first(issues(test_repo; headers = options, params = state_param)))

############
# Activity #
############

# test GitLab.stargazers, GitLab.starred
## TODO - NO equivalent API @test length(first(stargazers(ghjl; headers = options))) > 10 # every package should fail tests if it's not popular enough :p
@test hasghobj(GitLab.repo_by_name("admin-project"; headers=options), first(starred(testuser; headers = options)))

#= TODO no equivalent API
# test GitLab.watched, GitLab.watched
@test hasghobj(testuser, first(watchers(test_repo; headers = options)))
@test hasghobj(ghjl, first(watched(testuser; headers = options)))
=#
