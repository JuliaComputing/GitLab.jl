import GitHub
myauth = GitHub.authenticate(ENV["GITHUB_AUTH"]) # don't hardcode your access tokens!
GitHub.star("JuliaWeb/GitHub.jl"; auth = myauth)  # star the GitHub.jl repo as the user identified by myauth
