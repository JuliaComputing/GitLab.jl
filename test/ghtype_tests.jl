import JSON
using GitLab, GitLab.name, GitLab.GitLabString, GitLab.Branch
using Base.Test

# This file tests various GitLabType constructors. To test for proper Nullable
# handling, most fields have been removed from the JSON samples used below.
# Sample fields were selected in order to cover the full range of type behavior,
# e.g. if the GitLabType has a few Nullable{Dates.DateTime} fields, at least one
# of those fields should be present in the JSON sample.

function test_show(g::GitLab.GitLabType)
    tmpio = IOBuffer()
    show(tmpio, g)

    # basically trivial, but proves that things aren't completely broken
    @test repr(g) == takebuf_string(tmpio)

    tmpio = IOBuffer()
    showcompact(tmpio, g)

    @test "$(typeof(g))($(repr(name(g))))" == takebuf_string(tmpio)
end

#########
# Owner #
#########

owner_json = JSON.parse(
"""
{
  "name": "octocat_name",
  "username": "octocat",
  "id": 1,
  "state": "active",
  "web_url": "https://GitHub.com/octocat",
  "avatar_url": "",
  "ownership_type": "User"
}
"""
)

owner_result = Owner(
    Nullable{GitLabString}(GitLabString(owner_json["name"])),
    Nullable{GitLabString}(GitLabString(owner_json["username"])),
    Nullable{Int}(Int(owner_json["id"])),
    Nullable{GitLabString}(GitLabString(owner_json["state"])),
    Nullable{HttpCommon.URI}(HttpCommon.URI("")),
    Nullable{HttpCommon.URI}(HttpCommon.URI(owner_json["web_url"])),
    Nullable{GitLabString}(GitLabString(owner_json["ownership_type"]))
)

@test Owner(owner_json) == owner_result
@test name(Owner(owner_json["username"])) == name(owner_result)
## @test setindex!(GitLab.gitlab2json(owner_result), nothing, "username") == owner_json
@test setindex!(GitLab.gitlab2json(owner_result), "", "avatar_url") == owner_json

test_show(owner_result)

########
# Repo #
########

repo_json = JSON.parse(
"""
{
    "project_id": 1296269,
    "owner": {
        "username": "octocat"
    },
    "name": "octocat/Hello-World",
    "public": true,
    "web_url": "https://api.github.com/repos/octocat/Hello-World",
    "last_activity_at": "2011-01-26T19:06:43"
    }
"""
)

repo_result = Repo(
    Nullable{GitLabString}(GitLabString(repo_json["name"])),
    Nullable{Int}(),
    Nullable{HttpCommon.URI}(),
    Nullable{HttpCommon.URI}(),
    Nullable{GitLabString}(),
    Nullable{Int}(Int(repo_json["project_id"])),
    Nullable{Int}(),
    Nullable{GitLabString}(),
    Nullable{Vector{GitLabString}}(),
    Nullable{Bool}(Bool(repo_json["public"])),
    Nullable{Bool}(),
    Nullable{HttpCommon.URI}(),
    Nullable{HttpCommon.URI}(HttpCommon.URI(repo_json["web_url"])),
    Nullable{Owner}(Owner(repo_json["owner"])),
    Nullable{GitLabString}(),
    Nullable{GitLabString}(),
    Nullable{GitLabString}(),
    Nullable{Bool}(),
    Nullable{Bool}(),
    Nullable{Bool}(),
    Nullable{Bool}(),
    Nullable{Bool}(),
    Nullable{Bool}(),
    Nullable{Dates.DateTime}(),
    Nullable{Dates.DateTime}(Dates.DateTime(repo_json["last_activity_at"])),
    Nullable{Bool}(),
    Nullable{Int}(),
    Nullable{HttpCommon.URI}(),
    Nullable{Int}(),
    Nullable{Int}(),
    Nullable{Int}(),
    Nullable{GitLabString}(),
    Nullable{Bool}()
)

@test Repo(repo_json) == repo_result
@test name(Repo(repo_json["name"])) == name(repo_result)
## @test setindex!(GitLab.gitlab2json(repo_result), nothing, "avatar_url") == repo_json

test_show(repo_result)

##########
# Commit #
##########

commit_json = JSON.parse(
"""
{
    "id": "5c35ae1de7f6d6bfadf0186e165f7af6537e7da8",
    "short_id": "5c35ae1d",
    "title": "Fixed test",
    "author_name": "Pradeep Mudlapur",
    "author_email": "pradeep@juliacomputing.com",
    "created_at": "2016-07-21T12:40:40.000+05:30",
    "message": "Fixed test"
}
"""
)

commit_result = Commit(
    Nullable{GitLabString}(GitLabString(commit_json["id"])),
    Nullable{GitLabString}(GitLabString(commit_json["author_email"])),
    Nullable{GitLabString}(GitLabString(commit_json["title"])),
    Nullable{GitLabString}(GitLabString(commit_json["short_id"])),
    Nullable{GitLabString}(GitLabString(commit_json["message"])),
    Nullable{GitLabString}(),
    Nullable{Vector{Any}}(),
    Nullable{GitLabString}(),
    Nullable{GitLabString}(),
    Nullable{GitLabString}(GitLabString(commit_json["author_name"])),
    Nullable{GitLabString}(),
    Nullable{GitLabString}(GitLabString(commit_json["created_at"]))
)

@test Commit(commit_json) == commit_result
@test name(Commit(commit_json["id"])) == name(commit_result)
## @test setindex!(GitLab.gitlab2json(commit_result), nothing, "html_url") == commit_json

test_show(commit_result)

##########
# Branch #
##########

branch_json = JSON.parse(
"""
{
    "name": "branch1",
    "protected": false,
    "commit": {
      "id": "1c5008fbc343f8793055d155af2e760fc3c1b6be",
      "message": "test",
      "parent_ids": [
        "15b89b7edde90eabc33580799277cbed6d3e4331"
      ],
      "authored_date": "2016-07-15T17:26:55.000+05:30",
      "author_name": "Pradeep Mudlapur",
      "author_email": "pradeep@juliacomputing.com",
      "committed_date": "2016-07-15T17:26:55.000+05:30",
      "committer_name": "Pradeep Mudlapur",
      "committer_email": "pradeep@juliacomputing.com"
    }
}
"""
)

branch_result = Branch(
    Nullable{GitLabString}(GitLabString(branch_json["name"])),
    Nullable{Bool}(Bool(branch_json["protected"])),
    Nullable{Commit}(Commit(branch_json["commit"]))
)

@test Branch(branch_json) == branch_result
@test name(Branch(branch_json["name"])) == name(branch_result)
## @test setindex!(GitLab.gitlab2json(branch_result), true, "protected") == branch_json

test_show(branch_result)

###########
# Comment #
###########

comment_json = JSON.parse(
"""
{
    "note": "Test ...",
    "author": {
      "name": "Pradeep",
      "username": "mdpradeep",
      "id": 2,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/7e32a35a20817e0258e12665c9099422?s=80&d=identicon",
      "web_url": "http://104.197.141.88/u/mdpradeep"
    },
    "created_at": "2016-07-16T16:02:12.923Z"
}
"""
)

comment_result = Comment(
    Nullable{GitLabString}(),
    Nullable{GitLabString}(GitLabString(comment_json["created_at"])),
    Nullable{Int64}(),
    Nullable{GitLabString}(GitLabString(comment_json["note"])),
    Nullable{Owner}(Owner(comment_json["author"])),
    Nullable{Int64}(),
    Nullable{GitLabString}(),
    Nullable{Int64}(),
    Nullable{GitLabString}(),
    Nullable{Bool}(),
    Nullable{HttpCommon.URI}(),
    Nullable{Bool}(),
    Nullable{GitLabString}(),
    Nullable{Int64}(),
    Nullable{GitLabString}(),
    Nullable{Int64}(),
    Nullable{GitLabString}(),
    Nullable{GitLabString}(),
    Nullable{GitLabString}(),
    Nullable{GitLabString}()
)


@test Comment(comment_json) == comment_result
## @test name(Comment(comment_json["id"])) == name(comment_result)
## @test setindex!(GitLab.gitlab2json(comment_result), nothing, "position") == comment_json

## TODO check this failure
## test_show(comment_result)

###########
# Content #
###########

content_json = JSON.parse(
"""
{
  "file_name": "file1",
  "file_path": "src/file1",
  "size": 52,
  "encoding": "base64",
  "content": "bmV3IGZpbGUKCmNoYW5nZQpjb21tZW50cwptb3JlIGNoYW5nZXMKbW9yZSBjaGFuZ2VzCg==",
  "ref": "master",
  "blob_id": "cce7fdffea49a72ec48b8055faa52a664f91b917",
  "commit_id": "5c35ae1de7f6d6bfadf0186e165f7af6537e7da8",
  "last_commit_id": "078beb463b6a21ff97fc1b93594f1e7063cd78da"
}
"""
)

content_result = Content(
    Nullable{GitLabString}(GitLabString(content_json["file_name"])),
    Nullable{GitLabString}(GitLabString(content_json["file_path"])),
    Nullable{Int}(Int(content_json["size"])),
    Nullable{GitLabString}(GitLabString(content_json["encoding"])),
    Nullable{GitLabString}(GitLabString(content_json["content"])),
    Nullable{GitLabString}(GitLabString(content_json["ref"])),
    Nullable{GitLabString}(GitLabString(content_json["blob_id"])),
    Nullable{GitLabString}(GitLabString(content_json["commit_id"])),
    Nullable{GitLabString}(GitLabString(content_json["last_commit_id"]))
)

@test Content(content_json) == content_result
@test name(Content(content_json["file_path"])) == name(content_result)
## @test setindex!(GitLab.gitlab2json(content_result), nothing, "encoding") == content_json

test_show(content_result)

##########
# Status #
##########

status_json = JSON.parse(
"""
{
    "id": 31696,
    "sha": "5c35ae1de7f6d6bfadf0186e165f7af6537e7da8",
    "ref": "",
    "status": "pending",
    "name": "default",
    "target_url": null,
    "description": null,
    "created_at": "2016-07-26T08:23:49",
    "started_at": null,
    "finished_at": null,
    "allow_failure": false,
    "author": {
      "name": "Pradeep",
      "username": "mdpradeep",
      "id": 2,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/7e32a35a20817e0258e12665c9099422?s=80&d=identicon",
      "web_url": "http://104.197.141.88/u/mdpradeep"
    }
}
"""
)

status_result = Status(
    Nullable{Int}(Int(status_json["id"])),
    Nullable{Int}(),
    Nullable{GitLabString}(),
    Nullable{GitLabString}(),
    Nullable{GitLabString}(),
    Nullable{GitLabString}(GitLabString(status_json["sha"])),
    Nullable{HttpCommon.URI}(),
    Nullable{HttpCommon.URI}(),
    Nullable{Dates.DateTime}(Dates.DateTime(status_json["created_at"])),
    Nullable{Dates.DateTime}(),
    Nullable{Owner}(),
    Nullable{Repo}(),
    Nullable{Vector{Status}}(),
    Nullable{GitLabString}(GitLabString(status_json["status"])),
    Nullable{GitLabString}(GitLabString(status_json["name"])),
    Nullable{Owner}(Owner(status_json["author"])),
    Nullable{GitLabString}(GitLabString(status_json["ref"])),
    Nullable{Dates.DateTime}(),
    Nullable{Dates.DateTime}(),
    Nullable{Bool}(Bool(status_json["allow_failure"]))
)

@test Status(status_json) == status_result
@test name(Status(status_json["id"])) == name(status_result)
## @test setindex!(GitLab.gitlab2json(status_result), nothing, "context") == status_json

test_show(status_result)

###############
# PullRequest #
###############

pr_json = JSON.parse(
"""
  {
    "id": 4,
    "iid": 4,
    "project_id": 1,
    "title": "test",
    "description": "",
    "state": "merged",
    "created_at": "2016-07-15T11:58:01.819",
    "updated_at": "2016-07-22T07:32:20.149",
    "target_branch": "master",
    "source_branch": "branch1",
    "upvotes": 0,
    "downvotes": 0,
    "author": {
      "name": "Administrator",
      "username": "siteadmin",
      "id": 1,
      "state": "active",
      "avatar_url": "http://www.gravatar.com/avatar/a3918c0a2d98a6606bd787c54e6e5268?s=80&d=identicon",
      "web_url": "http://104.197.141.88/u/siteadmin"
    },
    "assignee": null,
    "source_project_id": 1,
    "target_project_id": 1,
    "labels": [],
    "work_in_progress": false,
    "milestone": null,
    "merge_when_build_succeeds": false,
    "merge_status": "cannot_be_merged",
    "subscribed": true,
    "user_notes_count": 70
  }
"""
)

pr_result = PullRequest(
    Nullable{Int}(Int(pr_json["id"])),
    Nullable{Int}(Int(pr_json["iid"])),
    Nullable{Int}(Int(pr_json["project_id"])),
    Nullable{GitLabString}(GitLabString(pr_json["title"])),
    Nullable{GitLabString}(GitLabString(pr_json["description"])),
    Nullable{GitLabString}(GitLabString(pr_json["state"])),
    Nullable{Dates.DateTime}(Dates.DateTime(pr_json["created_at"])),
    Nullable{Dates.DateTime}(Dates.DateTime(pr_json["updated_at"])),
    Nullable{GitLabString}(GitLabString(pr_json["target_branch"])),
    Nullable{GitLabString}(GitLabString(pr_json["source_branch"])),
    Nullable{Int}(Int(pr_json["upvotes"])),
    Nullable{Int}(Int(pr_json["downvotes"])),
    Nullable{Owner}(Owner(pr_json["author"])),
    Nullable{Owner}(), ## assignee
    Nullable{Int}(Int(pr_json["source_project_id"])),
    Nullable{Int}(Int(pr_json["target_project_id"])),
    Nullable{Vector{GitLabString}}(Vector{GitLabString}(pr_json["labels"])),
    Nullable{Bool}(Bool(pr_json["work_in_progress"])),
    Nullable{GitLabString}(), ## milestone
    Nullable{Bool}(Bool(pr_json["merge_when_build_succeeds"])),
    Nullable{GitLabString}(GitLabString(pr_json["merge_status"])),
    Nullable{Bool}(Bool(pr_json["subscribed"])),
    Nullable{Int}(Int(pr_json["user_notes_count"]))
)

@test PullRequest(pr_json) == pr_result
@test name(PullRequest(pr_json["id"])) == name(pr_result)
## @test GitLab.gitlab2json(pr_result) == pr_json

test_show(pr_result)

#########
# Issue #
#########

issue_json = JSON.parse(
"""
{
  "id": 1,
  "iid": 1,
  "project_id": 1,
  "title": "Test Issue 1",
  "description": "Test for webhooks ...",
  "state": "opened",
  "created_at": "2016-06-20T10:06:27.980",
  "updated_at": "2016-07-26T09:37:12.651",
  "labels": [
    "MyLabel"
  ],
  "milestone": null,
  "assignee": {
    "name": "Pradeep",
    "username": "mdpradeep",
    "id": 2,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/7e32a35a20817e0258e12665c9099422?s=80&d=identicon",
    "web_url": "http://104.197.141.88/u/mdpradeep"
  },
  "author": {
    "name": "Pradeep",
    "username": "mdpradeep",
    "id": 2,
    "state": "active",
    "avatar_url": "http://www.gravatar.com/avatar/7e32a35a20817e0258e12665c9099422?s=80&d=identicon",
    "web_url": "http://104.197.141.88/u/mdpradeep"
  },
  "subscribed": true,
  "user_notes_count": 12
}
"""
)

issue_result = Issue(
    Nullable{Int}(Int(issue_json["id"])),
    Nullable{Int}(Int(issue_json["iid"])),
    Nullable{Int}(Int(issue_json["project_id"])),
    Nullable{GitLabString}(GitLabString(issue_json["title"])),
    Nullable{GitLabString}(GitLabString(issue_json["description"])),
    Nullable{GitLabString}(GitLabString(issue_json["state"])),
    Nullable{Dates.DateTime}(Dates.DateTime(issue_json["created_at"])),
    Nullable{Dates.DateTime}(Dates.DateTime(issue_json["updated_at"])),
    Nullable{Vector{GitLabString}}(Vector{GitLabString}(issue_json["labels"])),
    Nullable{GitLabString}(), ## milestone
    Nullable{Owner}(Owner(issue_json["assignee"])),
    Nullable{Owner}(Owner(issue_json["author"])),
    Nullable{Bool}(Bool(issue_json["subscribed"])),
    Nullable{Int}(Int(issue_json["user_notes_count"]))
)

@test Issue(issue_json) == issue_result
@test name(Issue(issue_json["id"])) == name(issue_result)
## @test setindex!(GitLab.gitlab2json(issue_result), nothing, "closed_at") == issue_json

test_show(issue_result)
