# GitLab.jl

### NOTE: 

This is a repo for providing API access to GitLab repos. Majority of the code from [GitHub.jl](https://github.com/JuliaWeb/GitHub.jl) has been reused here. Also, the interfaces and terminologies have been retained to the extent possible.



GitLab.jl provides a Julia interface to the [GitLab API v3](http://docs.gitlab.com/ce/api/). Using GitLab.jl, you can do things like:

- query for basic repository, organization, and user information
- programmatically take user-level actions (e.g. starring a repository, commenting on an issue, etc.)
- set up listeners that can detect and respond to repository events
- create and retrieve commit statuses (i.e. report CI pending/failure/success statuses to GitLab)

Here's a table of contents for this rather lengthy README:

[1. Response Types](#response-types)

[2. REST Methods](#rest-methods)

[3. Authentication](#authentication)

[4. Pagination](#pagination)

[5. Handling Webhook Events](#handling-webhook-events)

## Response Types

GitLab's JSON responses are parsed and returned to the caller as types of the form `G<:GitLab.GitLabType`. Here's some useful information about these types:

- All fields are `Nullable`.
- Field names generally match the corresponding field in GitLab's JSON representation (the exception is `"type"`, which has the corresponding field name `typ` to avoid the obvious language conflict).


Here's a table that matches up the provided `GitLabType`s with their corresponding API documentation, as well as alternative identifying values:

| type          | alternative identifying property                       | link(s) to documentation                                                                                                                                                                                                                        |
|---------------|--------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Owner`       | login, e.g. `"octocat"`                                | [organizations](http://docs.gitlab.com/ce/api/projects.html), [users](http://docs.gitlab.com/ce/api/users.html)                                                                                                                                 |
| `Repo`        | full_name, e.g. `"JuliaComputing/GitLab.jl"`           | [repositories](http://docs.gitlab.com/ce/api/repositories.html)                                                                                                                                                                                 |
| `Commit`      | sha, e.g. `"d069993b320c57b2ba27336406f6ec3a9ae39375"` | [repository commits](http://docs.gitlab.com/ce/api/commits.html)                                                                                                                                                                                |
| `Branch`      | name, e.g. `master`                                    | [repository branches](http://docs.gitlab.com/ce/api/branches.html)                                                                                                                                                                              |
| `Content`     | path, e.g. `"src/owners/owners.jl"`                    | [repository contents](http://docs.gitlab.com/ce/api/projects.html)                                                                                                                                                                              |
| `Comment`     | id, e.g. `162224613`                                   | [commit comments](http://docs.gitlab.com/ce/api/notes.html), [issue comments](http://docs.gitlab.com/ce/api/issues.html#comments-on-issues), [PR review comments](http://docs.gitlab.com/ce/api/merge_requests.html#comments-on-merge-requests) |
| `Status`      | id, e.g. `366961773`                                   | [commit statuses](http://docs.gitlab.com/ce/api/commits.html#commit-status)                                                                                                                                                                     |
| `PullRequest` | number, e.g. `44`                                      | [pull requests](http://docs.gitlab.com/ce/api/merge_requests.html)                                                                                                                                                                              |
| `Issue`       | number, e.g. `31`                                      | [issues](http://docs.gitlab.com/ce/api/issues.html)                                                                                                                                                                                             |

You can inspect which fields are available for a type `G<:GitLabType` by calling `fieldnames(G)`.

## REST Methods

GitLab.jl implements a bunch of methods that make REST requests to GitLab's API. The below sections list these methods (note that a return type of `Tuple{Vector{T}, Dict}` means the result is [paginated](#pagination)).

#### Users and Organizations

| method                                   | return type                        | documentation                                                                                                                                                                                               |
|------------------------------------------|------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `owner(owner[, isorg = false])`          | `Owner`                            | get `owner` as a [user](http://docs.gitlab.com/ce/api/users.html#for-normal-users) or [organization](http://docs.gitlab.com/ce/api/projects.html#search-for-projects-by-name)                                                                                                                                    |
| `repos(owner[, isorg = false])`          | `Tuple{Vector{Repo}, Dict}`       | [get the `owner`'s repositories](http://docs.gitlab.com/ce/api/projects.html#list-owned-projects) 


#### Repositories

| method                                   | return type                        | documentation                                                                                                                                                                                               |
|------------------------------------------|------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `repo_by_name(repo)`                     | `Repo`                             | [get `repo`](http://docs.gitlab.com/ce/api/projects.html#search-for-projects-by-name)                                                                                                                                                    |
| `create_fork(repo)`                      | `Repo`                             | [create a fork of `repo`](http://docs.gitlab.com/ce/api/projects.html#fork-project)                                                                                                                       |
| `contributors(repo)`                     | `Tuple{Vector{Dict}, Dict}`        | [get `repo`'s contributors](http://docs.gitlab.com/ce/api/repositories.html#contributors)                                                                                                                       |
| `collaborators(repo)`                    | `Tuple{Vector{Owner}, Dict}`       | [get `repo`'s collaborators](http://docs.gitlab.com/ce/api/projects.html#list-project-team-members)                                                                                                                     |
| `iscollaborator(repo, user)`             | `Bool`                             | [check if `user` is a collaborator on `repo`](http://docs.gitlab.com/ce/api/projects.html#list-project-team-members)                                                                                                     |
| `add_collaborator(repo, user)`           | `HttpCommon.Response`              | [add `user` as a collaborator to `repo`](http://docs.gitlab.com/ce/api/projects.html#add-project-team-member)                                                                                             |
| `remove_collaborator(repo, user)`        | `HttpCommon.Response`              | [remove `user` as a collaborator from `repo`](http://docs.gitlab.com/ce/api/projects.html#remove-project-team-member)                                                                                     |
| `stats(repo, stat[, attempts = 3])`      | `HttpCommon.Response`              | [get information on `stat` (e.g. "queue_metrics", "process_metrics", "job_stats" & "compound_metrics".)](http://docs.gitlab.com/ce/api/sidekiq_metrics.html)  - This may require additional configuration
| `commit(repo, sha)`                      | `Commit`                           | [get the commit specified by `sha`](http://docs.gitlab.com/ce/api/commits.html#get-a-single-commit)                                                                                                     |
| `commits(repo)`                          | `Tuple{Vector{Commit}, Dict}`      | [get `repo`'s commits](http://docs.gitlab.com/ce/api/commits.html#list-repository-commits)                                                                                                         |
| `branch(repo, branch)`                   | `Branch`                           | [get the branch specified by `branch`](http://docs.gitlab.com/ce/api/branches.html#get-single-repository-branch)                                                                                                                   |
| `branches(repo)`                         | `Tuple{Vector{Branch}, Dict}`      | [get `repo`'s branches](http://docs.gitlab.com/ce/api/branches.html#list-repository-branches)                                                                                                                               |
| `file(repo, path, ref)`                  | `Content`                          | [get the file specified by `path`](http://docs.gitlab.com/ce/api/repository_files.html#get-file-from-repository)                                                                                                            |
| `create_file(repo, path)`                | `Dict`                             | [create a file at `path` in `repo`](http://docs.gitlab.com/ce/api/repository_files.html#create-new-file-in-repository)                                                                                                          |
| `update_file(repo, path)`                | `Dict`                             | [update a file at `path` in `repo`](http://docs.gitlab.com/ce/api/repository_files.html#update-existing-file-in-repository)                                                                                                          |
| `delete_file(repo, path)`                | `Dict`                             | [delete a file at `path` in `repo`](http://docs.gitlab.com/ce/api/repository_files.html#delete-existing-file-in-repository)                                                                                                          |
| `readme(repo)`                           | `Content`                          | [get `repo`'s README.md](http://docs.gitlab.com/ce/api/repository_files.html#get-file-from-repository)                                                                                                                       |
| `create_status(repo, sha)`               | `Status`                           | [create a status for the commit specified by `sha`](http://docs.gitlab.com/ce/api/commits.html#commit-status)                                                                                        |
| `statuses(repo, ref)`                    | `Tuple{Vector{Status}, Dict}`      | [get the statuses posted to `ref`](http://docs.gitlab.com/ce/api/commits.html#commit-status)                                                                                        |


#### Pull Requests and Issues

| method                                   | return type                        | documentation                                                                                                                                                                                               |
|------------------------------------------|------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `pull_request(repo, pr)`                 | `PullRequest`                      | [get the pull request specified by `pr`](http://docs.gitlab.com/ce/api/merge_requests.html#get-single-mr)                                                                                                  |
| `pull_requests(repo)`                    | `Tuple{Vector{PullRequest}, Dict}` | [get `repo`'s pull requests](http://docs.gitlab.com/ce/api/merge_requests.html#list-merge-requests)                                                                                                                     |
| `issue(repo, issue)`                     | `Issue`                            | [get the issue specified by `issue`](http://docs.gitlab.com/ce/api/issues.html#new-issue)                                                                                                            |
| `issues(repo)`                           | `Tuple{Vector{Issue}, Dict}`       | [get `repo`'s issues](http://docs.gitlab.com/ce/api/issues.html#list-issues)                                                                                                                 |
| `create_issue(repo)`                     | `Issue`                            | [create an issue in `repo`](http://docs.gitlab.com/ce/api/issues.html#new-issue)                                                                                                                        |
| `edit_issue(repo, issue)`                | `Issue`                            | [edit `issue` in `repo`](http://docs.gitlab.com/ce/api/issues.html#edit-issue)                                                                                                                             |
| `delete_issue(repo, issue)`              | `Issue`                            | [delete `issue` in `repo`](http://docs.gitlab.com/ce/api/issues.html#delete-an-issue)                                                                                                                             |

#### Comments

| method                                   | return type                        | documentation                                                                                                                                                                                               |
|------------------------------------------|------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `comment(repo, comment, :issue)`         | `Comment`                          | [get an issue `comment` from `repo`](http://docs.gitlab.com/ce/api/notes.html#get-single-issue-note)                                                                                                 |
| `comment(repo, comment, :pr)`            | `Comment`                          | [get a PR `comment` from `repo`](http://docs.gitlab.com/ce/api/notes.html#get-single-merge-request-note)                                                                                                     |
| `comment(repo, comment, :review)`        | `Comment`                          | [get an review `comment` from `repo`](http://docs.gitlab.com/ce/api/notes.html#get-single-merge-request-note)                                                                                                 |
| `comment(repo, comment, :commit)`        | `Comment`                          | [get a commit `comment` from `repo`](http://docs.gitlab.com/ce/api/commits.html#get-the-comments-of-a-commit)                                                                                           |
| `comments(repo, issue, :issue)`          | `Tuple{Vector{Comment}, Dict}`     | [get the comments on `issue` in `repo`](http://docs.gitlab.com/ce/api/notes.html#list-project-issue-notes)                                                                                         |
| `comments(repo, pr, :pr)`                | `Tuple{Vector{Comment}, Dict}`     | [get the comments on `pr` in `repo`](http://docs.gitlab.com/ce/api/notes.html#list-all-merge-request-notes)                                                                                            |
| `comments(repo, pr, :review)`            | `Tuple{Vector{Comment}, Dict}`     | [get the review comments on `pr` in `repo`](http://docs.gitlab.com/ce/api/notes.html#list-all-merge-request-notes)                                                                                |
| `comments(repo, commit, :commit)`        | `Tuple{Vector{Comment}, Dict}`     | [get the comments on `commit` in `repo`](http://docs.gitlab.com/ce/api/commits.html#get-the-comments-of-a-commit)                                                                                 |
| `create_comment(repo, issue, :issue)`    | `Comment`                          | [create a comment on `issue` in `repo`](http://docs.gitlab.com/ce/api/notes.html#create-new-issue-note)                                                                                                  |
| `create_comment(repo, pr, :pr)`          | `Comment`                          | [create a comment on `pr` in `repo`](http://docs.gitlab.com/ce/api/notes.html#create-new-merge-request-note)                                                                                                     |
| `create_comment(repo, pr, :review)`      | `Comment`                          | [create a review comment on `pr` in `repo`](http://docs.gitlab.com/ce/api/notes.html#create-new-merge-request-note)                                                                                               |
| `create_comment(repo, commit, :commit)`  | `Comment`                          | [create a comment on `commit` in `repo`](http://docs.gitlab.com/ce/api/commits.html#post-comment-to-commit)                                                                                           |
| `edit_comment(repo, comment, :issue)`    | `Comment`                          | [edit the issue `comment` in `repo`](http://docs.gitlab.com/ce/api/notes.html#modify-existing-issue-note)                                                                                                       |
| `edit_comment(repo, comment, :pr)`       | `Comment`                          | [edit the PR `comment` in `repo`](http://docs.gitlab.com/ce/api/notes.html#modify-existing-merge-request-note)                                                                                                          |
| `edit_comment(repo, comment, :review)`   | `Comment`                          | [edit the review `comment` in `repo`](http://docs.gitlab.com/ce/api/notes.html#modify-existing-merge-request-note)                                                                                                       |
| `edit_comment(repo, comment, :commit)`   | `Comment`                          | [edit the commit `comment` in `repo`](http://docs.gitlab.com/ce/api/commits.html#post-comment-to-commit)                                                                                              |
| `delete_comment(repo, comment, :issue)`  | `HttpCommon.Response`              | [delete the issue `comment` from `repo`](http://docs.gitlab.com/ce/api/notes.html#delete-an-issue-note)                                                                                                 |
| `delete_comment(repo, comment, :pr)`     | `HttpCommon.Response`              | [delete the PR `comment` from `repo`](http://docs.gitlab.com/ce/api/notes.html#delete-a-merge-request-note)                                                                                                    |
| `delete_comment(repo, comment, :review)` | `HttpCommon.Response`              | [delete the review `comment` from `repo`](http://docs.gitlab.com/ce/api/notes.html#delete-a-merge-request-note)                                                                                                 |


#### Social Activity

| method                                   | return type                        | documentation                                                                                                                                                                                               |
|------------------------------------------|------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `star(repo)`                             | `HttpCommon.Response`              | [star `repo`](http://docs.gitlab.com/ce/api/projects.html#star-a-project)                                                                                                                         |
| `unstar(repo)`                           | `HttpCommon.Response`              | [unstar `repo`](http://docs.gitlab.com/ce/api/projects.html#unstar-a-project)                                                                                                                     |
| `starred(user)`                          | `Tuple{Vector{Repo}, Dict}`        | [get repositories starred by `user`](http://docs.gitlab.com/ce/api/projects.html#list-starred-projects)                                                                                    |


#### Miscellaneous

| method                                   | return type                        | documentation                                                                                                                                                                                               |
|------------------------------------------|------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `authenticate(token)`                    | `OAuth2`                           | [validate `token` and return an authentication object](http://docs.gitlab.com/ce/api/README.html#authentication)                                                                                                     |

#### Keyword Arguments

All REST methods accept the following keyword arguments:

| keyword        | type                    | default value            | description                                                                                    |
|----------------|-------------------------|--------------------------|------------------------------------------------------------------------------------------------|
| `auth`         | `GitLab.Authorization`  | `GitLab.AnonymousAuth()` | The request's authorization                                                                    |
| `params`       | `Dict`                  | `Dict()`                 | The request's query parameters                                                                 |
| `headers`      | `Dict`                  | `Dict()`                 | The request's headers. Note that these headers will be mutated by GitLab.jl request methods.   |
| `handle_error` | `Bool`                  | `true`                   | If `true`, a Julia error will be thrown in the event that GitLab's response reports an error.  |
| `page_limit`   | `Real`                  | `Inf`                    | The number of pages to return (only applies to paginated results, obviously)                   |

## Authentication

To authenticate your requests to GitLab, you'll need to generate an appropriate [access token](http://docs.gitlab.com/ce/api/oauth2.html). Then, you can do stuff like the following (this example assumes that you set an environmental variable `GITLAB_AUTH` containing the access token):

```julia
import GitLab

myauth = GitLab.authenticate(ENV["GITLAB_AUTH"]) # don't hardcode your access tokens!

GitLab.star("JuliaComputing/GitLab.jl"; auth = myauth)  # star the GitLab.jl repo as the user identified by myauth
```

As you can see, you can propagate the identity/permissions of the `myauth` token to GitLab.jl's methods by passing `auth = myauth` as a keyword argument.




## Handling Webhook Events

GitLab.jl comes with configurable `EventListener` and `CommentListener` types that can be used as basic servers for parsing and responding to events delivered by [GitLab's repository Webhooks](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/web_hooks/web_hooks.md).

#### `EventListener`

When an `EventListener` receives an event, it performs some basic validation and wraps the event payload (and some other data) in [a `WebhookEvent` type](https://github.com/JuliaComputing/GitLab.jl/blob/master/src/activity/events/events.jl). This `WebhookEvent` instance, along with the provided `Authorization`, is then fed to the server's handler function, which the user defines to determine the server's response behavior. The handler function is expected to return an `HttpCommon.Response` that is then sent back to GitLab.

The `EventListener` constructor takes the following keyword arguments:

- `auth`: GitLab authorization (usually with repo-level permissions).
- `secret`: A string used to verify the event source. If the event is from a GitLab Webhook, it's the Webhook's secret. If a secret is not provided, the server won't validate the secret signature of incoming requests.
- `repos`: A vector of `Repo`s (or fully qualified repository names) listing all acceptable repositories. All repositories are whitelisted by default.
- `events`: A vector of [event names](https://developer.gitlab.com/webhooks/#events) listing all acceptable events (e.g. ["commit_comment", "pull_request"]). All events are whitelisted by default.
- `forwards`: A vector of `HttpCommon.URI`s (or URI strings) to which any incoming requests should be forwarded (after being validated by the listener)

Here's an example that demonstrates how to construct and run an `EventListener` that does benchmarking on every commit and PR:

```julia
import GitLab

# EventListener settings
myauth = GitLab.authenticate(ENV["GITLAB_AUTH"])
options = Dict("private_token" => myauth.token)
mysecret = ENV["MY_SECRET"]
myevents = ["Note Hook", "MergeRequest"]
myrepos = [GitLab.repo_by_name("MyTestProject1")]
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
        run_and_log_benchmarks(event, "\$(sha)-benchmarks.csv")
    catch err
        GitLab.create_status(repo, sha; auth = myauth, params = error_params(err))
        return HttpCommon.Response(500)
    end

    GitLab.create_status(repo, sha; auth = myauth, params = success_params)

    return HttpCommon.Response(200)
end

# Start the listener on localhost at port 8000
GitLab.run(listener, host=IPv4(127,0,0,1), port=8000)
```

#### `CommentListener`

A `CommentListener` is a special kind of `EventListener` that allows users to pass data to the listener's handler function via commenting. This is useful for triggering events on repositories that require configuration settings.

A `CommentListener` automatically filters out all non-comment events, and then checks the body of each comment event against a trigger `Regex` supplied by the user. If a match is found in the comment, then the `CommentListener` calls its handler function, passing it the event and the corresponding `RegexMatch`.

The `CommentListener` constructor takes the following keyword arguments:

- `auth`: same as `EventListener`
- `secret`: same as `EventListener`
- `repos`: same as `EventListener`
- `forwards`: same as `EventListener`
- `check_collab`: If `true`, only acknowledge comments made by repository collaborators. Note that, if `check_collab` is `true`, `auth` must have the appropriate permissions to query the comment's repository for the collaborator status of the commenter. `check_collab` is `true` by default.

For example, let's set up a silly `CommentListener` that responds to the commenter with a greeting. To give a demonstration of the desired behavior, if a collaborator makes a comment like:

```julia
Man, I really would like to be greeted today.

`sayhello("Bob", "outgoing")`
```

We want the `CommentLister` to reply:

```julia
Hello, Bob, you look very outgoing today!
```

Here's the code that will make this happen:

```julia
import GitLab

myauth = GitLab.authenticate(ENV["GITLAB_AUTH"]) # don't hardcode your access tokens!
println("Authentication successful")
options = Dict("private_token" => myauth.token)

# CommentListener settings
trigger = r"`sayhello\(.*?\)`"

# We can use Julia's `do` notation to set up the listener's handler function.
# Note that, in our example case, `phrase` will be "`sayhello(\"Bob\", \"outgoing\")`"
listener = GitLab.CommentListener(trigger; auth = myauth, secret = mysecret) do event, phrase
    # In our example case, this code sets name to "Bob" and adjective to "outgoing"
    name, adjective = matchall(r"\".*?\"", phrase)
    comment_params = Dict("body" => "Hello, $name, you look very $adjective today!")

    # Parse the original comment event for all the necessary reply info
    comment = GitLab.Comment(event.payload["comment"])

    if event.payload["object_attributes"]["noteable_type"] == "Issue"
        comment_kind = :issue
        reply_to = event.payload["object_attributes"]["noteable_id"]
    elseif event.payload["object_attributes"]["noteable_type"] == "Commit"
        comment_kind = :commit
        reply_to = get(comment.commit_id)
    elseif event.payload["object_attributes"]["noteable_type"] == "MergeRequest"
        comment_kind = :review
        reply_to = event.payload["object_attributes"]["noteable_id"]
        # load required query params for review comment creation
        comment_params["commit_id"] = "$(comment.id)"
        comment_params["path"] = "$(comment.url)"
        comment_params["position"] = "$(comment.id)"
    end

    # send the comment creation request to GitLab
    GitLab.create_comment(event.repository, reply_to, comment_kind; headers = options, params = comment_params)

    return HttpCommon.Response(200)
end

# Start the listener on localhost at port 8000
GitLab.run(listener, host=IPv4(127,0,0,1), port=8000)
```
