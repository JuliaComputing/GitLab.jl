import GitLab
using BenchmarkTools

myauth = GitLab.authenticate(ENV["GITLAB_AUTH"]) # don't hardcode your access tokens!
println("Authentication successful")
options = Dict("private_token" => myauth.token)
## @show options



# EventListener settings
mysecret = ENV["MY_SECRET"]
myrepos = [GitLab.Repo("TestProject1")]

# CommentListener settings
trigger = r"`runbenchmarks\(.*?\)`"

# We can use Julia's `do` notation to set up the listener's handler function.
# Note that, in our example case
listener = GitLab.CommentListener(trigger; auth = myauth, secret = mysecret) do event, phrase
    ## @show phrase.match
    ## pkg_names = matchall(r"\".*?\"", phrase.match)
    ## pkg_name = pkg_names[1]
    ## Take the current package !!
    @show event.payload["project"]
    pkg_name = event.payload["project"]["name"]
    @show pkg_name

    @show event.payload["object_attributes"]
    # Parse the original comment event for all the necessary reply info
    comment = GitLab.Comment(event.payload["object_attributes"])
    ## @show comment

    results = @benchmark include(Pkg.dir("TestProject1", "test", "runtests.jl"))
    @show results

    if event.payload["object_attributes"]["noteable_type"] == "Issue"
        comment_params = Dict("body" => "<H2>Your benchmark results are available ! </H2> <br/> <code> $results <code>")
        comment_kind = :issue
        reply_to = event.payload["object_attributes"]["noteable_id"]
    elseif event.payload["object_attributes"]["noteable_type"] == "Commit"
        comment_params = Dict("note" => "<H2>Your benchmark results are available ! </H2> <br/> <code> $results <code>")
        comment_kind = :commit
        reply_to = get(comment.commit_id)
    elseif event.payload["object_attributes"]["noteable_type"] == "MergeRequest"
        comment_params = Dict("body" => "<H2>Your benchmark results are available ! </H2> <br/> <code> $results <code>")
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
    GitLab.create_comment(event.repository, reply_to, comment_kind; auth = myauth, params = comment_params)

    return HttpCommon.Response(200)
end

# Start the listener on localhost at port 8000
## GitLab.run(listener, host=IPv4(127,0,0,1), port=8000)
GitLab.run(listener, host=IPv4(0,0,0,0), port=8000)



