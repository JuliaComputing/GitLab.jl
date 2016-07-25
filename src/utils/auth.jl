#######################
# Authorization Types #
#######################

abstract Authorization

immutable OAuth2 <: Authorization
    token::GitLabString
end

immutable AnonymousAuth <: Authorization end

###############
# API Methods #
###############

function authenticate(token::AbstractString; params = Dict(), options...)
    auth = OAuth2(token)
    ## params["access_token"] = auth.token
    params["private_token"] = auth.token ## MDP
    gh_get("/"; params = params, options...)
    return auth
end

#########################
# Header Authentication #
#########################

authenticate_headers!(headers, auth::AnonymousAuth) = headers

function authenticate_headers!(headers, auth::OAuth2)
    headers["Authorization"] = "token $(auth.token)"
    return headers
end

###################
# Pretty Printing #
###################

function Base.show(io::IO, a::OAuth2)
    token_str = a.token[1:6] * repeat("*", length(a.token) - 6)
    print(io, "GitLab.OAuth2($token_str)")
end
