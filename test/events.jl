import GitLab
myauth = GitLab.authenticate(ENV["GITLAB_AUTH"]) # don't hardcode your access tokens!
println("Authentication successful")
options = Dict("private_token" => myauth.token)



## GitLab.collaborators("1"; params=options)

# EventListener settings
mysecret = ENV["MY_SECRET"]
myevents = ["pull_request", "Push Hook"]
myrepos = [GitLab.Repo("TestProject1")]
myforwards = [HttpCommon.URI("http://myforward1.com"), "http://myforward2.com"] # can be HttpCommon.URIs or URI strings

# Set up Status parameters
pending_params = Dict(
    "state" => "pending",
    "context" => "Benchmarker",
    "description" => "Running benchmarks..."
)

success_params = Dict(
    "state" => "success",
    "context" => "Benchmarker",
    "description" => "Benchmarks complete!"
)

error_params(err) = Dict(
    "state" => "error",
    "context" => "Benchmarker",
    "description" => "Error: $err"
)

# We can use Julia's `do` notation to set up the listener's handler function
listener = GitLab.EventListener(auth = myauth,
                                secret = mysecret,
                                repos = myrepos,
                                events = myevents,
                                forwards = myforwards) do event
    kind, payload, repo = event.kind, event.payload, event.repository

    if kind == "pull_request" && payload["action"] == "closed"
        return HttpCommon.Response(200)
    end

    if event.kind == "push"
        sha = event.payload["after"]
    elseif event.kind == "pull_request"
        sha = event.payload["pull_request"]["head"]["sha"]
    end

    GitLab.create_status(repo, sha; auth = myauth, params = pending_params)

    try
        # run_and_log_benchmarks isn't actually a defined function, but you get the point
        ## run_and_log_benchmarks(event, "\$(sha)-benchmarks.csv")
        println("Done !
    catch err
        GitLab.create_status(repo, sha; auth = myauth, params = error_params(err))
        return HttpCommon.Response(500)
    end

    GitLab.create_status(repo, sha; auth = myauth, params = success_params)

    return HttpCommon.Response(200)
end

# Start the listener on localhost at port 8000
## GitLab.run(listener, host=IPv4(127,0,0,1), port=8000)
GitLab.run(listener, host=IPv4(0,0,0,0), port=8000)
