import GitLab
using BenchmarkTools

myauth = GitLab.authenticate(ENV["GITLAB_AUTH"]) # don't hardcode your access tokens!
println("Authentication successful")
options = Dict("private_token" => myauth.token)
## @show options

# EventListener settings
## mysecret = ENV["MY_SECRET"]

## Get the BenchmarkResults repo!

benchmark_results_repo = GitLab.repo_by_name("BenchmarkResults"; headers=options)
benchmark_results_repo.project_id = benchmark_results_repo.id

# CommentListener settings
trigger = r"`runbenchmarks\(.*?\)`"

# We can use Julia's `do` notation to set up the listener's handler function.
# Note that, in our example case
listener = GitLab.CommentListener(trigger; auth = myauth) do event, phrase
@show phrase
    ## pkg_names = matchall(r"\".*?\"", phrase.match)
    ## pkg_name = pkg_names[1]
    ## Take the current package !!
    pkg_name = event.payload["project"]["name"]
    ## @show pkg_name

    ## @show event.payload["object_attributes"]
    # Parse the original comment event for all the necessary reply info
    comment = GitLab.Comment(event.payload["object_attributes"])
    ## @show comment

    results = include(Pkg.dir(pkg_name, "benchmarks", "runbenchmarks.jl"))

    ## Send the results to the BenchmarkResults repository and get the link for the same.
    issue = GitLab.create_issue(benchmark_results_repo; headers=options, params = Dict("title" => "Benchmark Results"))
    benchmark_reply_to = issue.id.value

    str_buf = IOBuffer(true, true)
    print(str_buf, benchmark_results_repo.web_url.value)
    issue_url = UTF8String(str_buf.data) * "/issues/$(issue.id.value)"

    if event.payload["object_attributes"]["noteable_type"] == "Issue"
        benchmark_comment_params = Dict("body" => "<H2>Your benchmark results are available ! </H2> <code>$results<code>")
        comment_params = Dict("body" => "<H2>Your benchmark results are available here - $(issue_url) </H2>")
        comment_kind = :issue
        reply_to = event.payload["object_attributes"]["noteable_id"]
    elseif event.payload["object_attributes"]["noteable_type"] == "Commit"
        benchmark_comment_params = Dict("note" => "<H2>Your benchmark results are available ! </H2> <code>$results<code>")
        comment_params = Dict("note" => "<H2>Your benchmark results are available here - $(issue_url) </H2>")
        comment_kind = :commit
        reply_to = get(comment.commit_id)
    elseif event.payload["object_attributes"]["noteable_type"] == "MergeRequest"
        benchmark_comment_params = Dict("body" => "<H2>Your benchmark results are available ! </H2> <code>$results<code>")
        comment_params = Dict("body" => "<H2>Your benchmark results are available here - $(issue_url) </H2>")
        comment_kind = :review
        reply_to = event.payload["object_attributes"]["noteable_id"]
        # load required query params for review comment creation
        comment_params["commit_id"] = "$(comment.id)"
        comment_params["path"] = "$(comment.url)"
        ## MDP comment_params["position"] = get(comment.position)
        comment_params["position"] = "$(comment.id)"
    end
    ## @show reply_to, comment_kind

    ## @show benchmark_comment_params
    ## Update the issue with results
    GitLab.create_comment(benchmark_results_repo, benchmark_reply_to, comment_kind; headers = options, params = benchmark_comment_params)
    

    # send the comment creation request to GitLab
    GitLab.create_comment(event.repository, reply_to, comment_kind; headers = options, params = comment_params)

    return HttpCommon.Response(200)
end

# Start the listener on localhost at port 8000
GitLab.run(listener, host=IPv4(0,0,0,0), port=8000)



