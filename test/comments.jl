import GitLab
using BenchmarkTools

myauth = GitLab.authenticate(ENV["GITLAB_AUTH"]) # don't hardcode your access tokens!
println("Authentication successful")
options = Dict("private_token" => myauth.token)
## @show options

# EventListener settings
mysecret = ENV["MY_SECRET"]

# CommentListener settings
trigger = r"`runbenchmarks\(.*?\)`"

# We can use Julia's `do` notation to set up the listener's handler function.
# Note that, in our example case
listener = GitLab.CommentListener(trigger; auth = myauth) do event, phrase
    ## pkg_names = matchall(r"\".*?\"", phrase.match)
    ## pkg_name = pkg_names[1]
    ## Take the current package !!
    @show event.payload["project"]
    pkg_name = event.payload["project"]["name"]
    ## @show pkg_name

    @show event.payload["object_attributes"]
    # Parse the original comment event for all the necessary reply info
    comment = GitLab.Comment(event.payload["object_attributes"])
    ## @show comment

    results = include(Pkg.dir(pkg_name, "benchmarks", "runbenchmarks.jl"))
    final_results = "$(results["calculus"]) \n $(results["calculus"]["test"])\n"
    @show final_results

    if event.payload["object_attributes"]["noteable_type"] == "Issue"
        comment_params = Dict("body" => "<H2>Your benchmark results are available ! </H2> <br/> <code> $final_results <code>")
        comment_kind = :issue
        reply_to = event.payload["object_attributes"]["noteable_id"]
        #=
        issue_details = event.payload["issue"]
        reply_to = event.payload["issue"]["iid"]
        =#
    elseif event.payload["object_attributes"]["noteable_type"] == "Commit"
        comment_params = Dict("note" => "<H2>Your benchmark results are available ! </H2> <br/> <code> $final_results <code>")
        comment_kind = :commit
        reply_to = get(comment.commit_id)
    elseif event.payload["object_attributes"]["noteable_type"] == "MergeRequest"
        comment_params = Dict("body" => "<H2>Your benchmark results are available ! </H2> <br/> <code> $final_results <code>")
        comment_kind = :review
        reply_to = event.payload["object_attributes"]["noteable_id"]
        # load required query params for review comment creation
        comment_params["commit_id"] = "$(comment.id)"
        comment_params["path"] = "$(comment.url)"
        ## MDP comment_params["position"] = get(comment.position)
        comment_params["position"] = "$(comment.id)"
    end
    ## @show reply_to, comment_kind

    # send the comment creation request to GitLab
    GitLab.create_comment(event.repository, reply_to, comment_kind; headers = Dict("private_token" => myauth.token), params = comment_params)

    return HttpCommon.Response(200)
end

# Start the listener on localhost at port 8000
GitLab.run(listener, host=IPv4(0,0,0,0), port=8000)



