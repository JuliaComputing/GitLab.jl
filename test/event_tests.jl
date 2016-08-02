using GitLab
using JLD, HttpCommon
using Base.Test

event_request = JLD.load(joinpath(dirname(@__FILE__), "event_request.jld"), "event_request")
event_json = Requests.json(event_request)
event = GitLab.event_from_payload!("Issue", event_json)
## @show event

################
# WebhookEvent #
################

@test get(event.repository.name) == "Calculus"
@test get(event.sender.username) == "mdpradeep"

#################
# EventListener #
#################
## @test !(GitLab.has_valid_secret(event_request, "wrong"))
## @test GitLab.has_valid_secret(event_request, "secret")
@test !(GitLab.is_valid_event(event_request, ["wrong"]))
@test GitLab.is_valid_event(event_request, ["Note Hook"])
@test !(GitLab.from_valid_repo(event, ["Random"]))
@test GitLab.from_valid_repo(event, ["Calculus"])

@test (GitLab.handle_event_request(event_request, x -> true, secret = "secret",
            events = ["Issue"], repos = ["Calculus"])).status == 400

@test begin
    listener = EventListener(x -> true;
                             secret = "secret",
                             repos = [Repo("JuliaCI/BenchmarkTrackers.jl"), "JuliaWeb/GitLab.jl"],
                             events = ["commit_comment"],
                             forwards = ["http://bob.com", HttpCommon.URI("http://jim.org")])
    r = listener.server.http.handle(HttpCommon.Request(),HttpCommon.Response())
    r.status == 400
end

###################
# CommentListener #
###################

result = GitLab.handle_comment((e, m) -> m, event, GitLab.AnonymousAuth(), r"`runbenchmarks\(.*?\)`", false)

@test result.match == "`runbenchmarks()`"

@test begin
    listener = CommentListener((x, y) -> true, r"trigger";
                               secret = "secret",
                               repos = [Repo("JuliaCI/BenchmarkTrackers.jl"), "JuliaWeb/GitLab.jl"],
                               forwards = ["http://bob.com", HttpCommon.URI("http://jim.org")],
                               check_collab = false)
    r = listener.listener.server.http.handle(HttpCommon.Request(), HttpCommon.Response())
    r.status == 400
end
