require "sinatra"

# OAuth Authorizations
get "/authorizations" do
  ""
end

get "/authorizations/:id" do
  ""
end

post "/authorizations" do
  ""
end

put "/authorizations/clients/:client_id" do
  ""
end

patch "/authorizations/:id" do
  ""
end

delete "/authorizations/:id" do
  ""
end

get "/applications/:client_id/tokens/:access_token" do
  ""
end

delete "/applications/:client_id/tokens" do
  ""
end

delete "/applications/:client_id/tokens/:access_token" do
  ""
end

# Activity
get "/events" do
  ""
end

get "/repos/:owner/:repo/events" do
  ""
end

get "/networks/:owner/:repo/events" do
  ""
end

get "/orgs/:org/events" do
  ""
end

get "/users/:user/received_events" do
  ""
end

get "/users/:user/received_events/public" do
  ""
end

get "/users/:user/events" do
  ""
end

get "/users/:user/events/public" do
  ""
end

get "/users/:user/events/orgs/:org" do
  ""
end

get "/feeds" do
  ""
end

get "/notifications" do
  ""
end

get "/repos/:owner/:repo/notifications" do
  ""
end

put "/notifications" do
  ""
end

put "/repos/:owner/:repo/notifications" do
  ""
end

get "/notifications/threads/:id" do
  ""
end

patch "/notifications/threads/:id" do
  ""
end

get "/notifications/threads/:id/subscription" do
  ""
end

put "/notifications/threads/:id/subscription" do
  ""
end

delete "/notifications/threads/:id/subscription" do
  ""
end

get "/repos/:owner/:repo/stargazers" do
  ""
end

get "/users/:user/starred" do
  ""
end

get "/user/starred" do
  ""
end

get "/user/starred/:owner/:repo" do
  ""
end

put "/user/starred/:owner/:repo" do
  ""
end

delete "/user/starred/:owner/:repo" do
  ""
end

get "/repos/:owner/:repo/subscribers" do
  ""
end

get "/users/:user/subscriptions" do
  ""
end

get "/user/subscriptions" do
  ""
end

get "/repos/:owner/:repo/subscription" do
  ""
end

put "/repos/:owner/:repo/subscription" do
  ""
end

delete "/repos/:owner/:repo/subscription" do
  ""
end

get "/user/subscriptions/:owner/:repo" do
  ""
end

put "/user/subscriptions/:owner/:repo" do
  ""
end

delete "/user/subscriptions/:owner/:repo" do
  ""
end

# Gists
get "/users/:user/gists" do
  ""
end

get "/gists" do
  ""
end

get "/gists/public" do
  ""
end

get "/gists/starred" do
  ""
end

get "/gists/:id" do
  ""
end

post "/gists" do
  ""
end

patch "/gists/:id" do
  ""
end

put "/gists/:id/star" do
  ""
end

delete "/gists/:id/star" do
  ""
end

get "/gists/:id/star" do
  ""
end

post "/gists/:id/forks" do
  ""
end

delete "/gists/:id" do
  ""
end

# Git Data
get "/repos/:owner/:repo/git/blobs/:sha" do
  ""
end

post "/repos/:owner/:repo/git/blobs" do
  ""
end

get "/repos/:owner/:repo/git/commits/:sha" do
  ""
end

post "/repos/:owner/:repo/git/commits" do
  ""
end

get "/repos/:owner/:repo/git/refs/*ref" do
  ""
end

get "/repos/:owner/:repo/git/refs" do
  ""
end

post "/repos/:owner/:repo/git/refs" do
  ""
end

patch "/repos/:owner/:repo/git/refs/*ref" do
  ""
end

delete "/repos/:owner/:repo/git/refs/*ref" do
  ""
end

get "/repos/:owner/:repo/git/tags/:sha" do
  ""
end

post "/repos/:owner/:repo/git/tags" do
  ""
end

get "/repos/:owner/:repo/git/trees/:sha" do
  ""
end

post "/repos/:owner/:repo/git/trees" do
  ""
end

# Issues
get "/issues" do
  ""
end

get "/user/issues" do
  ""
end

get "/orgs/:org/issues" do
  ""
end

get "/repos/:owner/:repo/issues" do
  ""
end

get "/repos/:owner/:repo/issues/:number" do
  ""
end

post "/repos/:owner/:repo/issues" do
  ""
end

patch "/repos/:owner/:repo/issues/:number" do
  ""
end

get "/repos/:owner/:repo/assignees" do
  ""
end

get "/repos/:owner/:repo/assignees/:assignee" do
  ""
end

get "/repos/:owner/:repo/issues/:number/comments" do
  ""
end

get "/repos/:owner/:repo/issues/comments" do
  ""
end

get "/repos/:owner/:repo/issues/comments/:id" do
  ""
end

post "/repos/:owner/:repo/issues/:number/comments" do
  ""
end

patch "/repos/:owner/:repo/issues/comments/:id" do
  ""
end

delete "/repos/:owner/:repo/issues/comments/:id" do
  ""
end

get "/repos/:owner/:repo/issues/:number/events" do
  ""
end

get "/repos/:owner/:repo/issues/events" do
  ""
end

get "/repos/:owner/:repo/issues/events/:id" do
  ""
end

get "/repos/:owner/:repo/labels" do
  ""
end

get "/repos/:owner/:repo/labels/:name" do
  ""
end

post "/repos/:owner/:repo/labels" do
  ""
end

patch "/repos/:owner/:repo/labels/:name" do
  ""
end

delete "/repos/:owner/:repo/labels/:name" do
  ""
end

get "/repos/:owner/:repo/issues/:number/labels" do
  ""
end

post "/repos/:owner/:repo/issues/:number/labels" do
  ""
end

delete "/repos/:owner/:repo/issues/:number/labels/:name" do
  ""
end

put "/repos/:owner/:repo/issues/:number/labels" do
  ""
end

delete "/repos/:owner/:repo/issues/:number/labels" do
  ""
end

get "/repos/:owner/:repo/milestones/:number/labels" do
  ""
end

get "/repos/:owner/:repo/milestones" do
  ""
end

get "/repos/:owner/:repo/milestones/:number" do
  ""
end

post "/repos/:owner/:repo/milestones" do
  ""
end

patch "/repos/:owner/:repo/milestones/:number" do
  ""
end

delete "/repos/:owner/:repo/milestones/:number" do
  ""
end

# Miscellaneous
get "/emojis" do
  ""
end

get "/gitignore/templates" do
  ""
end

get "/gitignore/templates/:name" do
  ""
end

post "/markdown" do
  ""
end

post "/markdown/raw" do
  ""
end

get "/meta" do
  ""
end

get "/rate_limit" do
  ""
end

# Organizations
get "/users/:user/orgs" do
  ""
end

get "/user/orgs" do
  ""
end

get "/orgs/:org" do
  ""
end

patch "/orgs/:org" do
  ""
end

get "/orgs/:org/members" do
  ""
end

get "/orgs/:org/members/:user" do
  ""
end

delete "/orgs/:org/members/:user" do
  ""
end

get "/orgs/:org/public_members" do
  ""
end

get "/orgs/:org/public_members/:user" do
  ""
end

put "/orgs/:org/public_members/:user" do
  ""
end

delete "/orgs/:org/public_members/:user" do
  ""
end

get "/orgs/:org/teams" do
  ""
end

get "/teams/:id" do
  ""
end

post "/orgs/:org/teams" do
  ""
end

patch "/teams/:id" do
  ""
end

delete "/teams/:id" do
  ""
end

get "/teams/:id/members" do
  ""
end

get "/teams/:id/members/:user" do
  ""
end

put "/teams/:id/members/:user" do
  ""
end

delete "/teams/:id/members/:user" do
  ""
end

get "/teams/:id/repos" do
  ""
end

get "/teams/:id/repos/:owner/:repo" do
  ""
end

put "/teams/:id/repos/:owner/:repo" do
  ""
end

delete "/teams/:id/repos/:owner/:repo" do
  ""
end

get "/user/teams" do
  ""
end

# Pull Requests
get "/repos/:owner/:repo/pulls" do
  ""
end

get "/repos/:owner/:repo/pulls/:number" do
  ""
end

post "/repos/:owner/:repo/pulls" do
  ""
end

patch "/repos/:owner/:repo/pulls/:number" do
  ""
end

get "/repos/:owner/:repo/pulls/:number/commits" do
  ""
end

get "/repos/:owner/:repo/pulls/:number/files" do
  ""
end

get "/repos/:owner/:repo/pulls/:number/merge" do
  ""
end

put "/repos/:owner/:repo/pulls/:number/merge" do
  ""
end

get "/repos/:owner/:repo/pulls/:number/comments" do
  ""
end

get "/repos/:owner/:repo/pulls/comments" do
  ""
end

get "/repos/:owner/:repo/pulls/comments/:number" do
  ""
end

put "/repos/:owner/:repo/pulls/:number/comments" do
  ""
end

patch "/repos/:owner/:repo/pulls/comments/:number" do
  ""
end

delete "/repos/:owner/:repo/pulls/comments/:number" do
  ""
end

# Repositories
get "/user/repos" do
  ""
end

get "/users/:user/repos" do
  ""
end

get "/orgs/:org/repos" do
  ""
end

get "/repositories" do
  ""
end

post "/user/repos" do
  ""
end

post "/orgs/:org/repos" do
  ""
end

get "/repos/:owner/:repo" do
  ""
end

patch "/repos/:owner/:repo" do
  ""
end

get "/repos/:owner/:repo/contributors" do
  ""
end

get "/repos/:owner/:repo/languages" do
  ""
end

get "/repos/:owner/:repo/teams" do
  ""
end

get "/repos/:owner/:repo/tags" do
  ""
end

get "/repos/:owner/:repo/branches" do
  ""
end

get "/repos/:owner/:repo/branches/:branch" do
  ""
end

delete "/repos/:owner/:repo" do
  ""
end

get "/repos/:owner/:repo/collaborators" do
  ""
end

get "/repos/:owner/:repo/collaborators/:user" do
  ""
end

put "/repos/:owner/:repo/collaborators/:user" do
  ""
end

delete "/repos/:owner/:repo/collaborators/:user" do
  ""
end

get "/repos/:owner/:repo/comments" do
  ""
end

get "/repos/:owner/:repo/commits/:sha/comments" do
  ""
end

post "/repos/:owner/:repo/commits/:sha/comments" do
  ""
end

get "/repos/:owner/:repo/comments/:id" do
  ""
end

patch "/repos/:owner/:repo/comments/:id" do
  ""
end

delete "/repos/:owner/:repo/comments/:id" do
  ""
end

get "/repos/:owner/:repo/commits" do
  ""
end

get "/repos/:owner/:repo/commits/:sha" do
  ""
end

get "/repos/:owner/:repo/readme" do
  ""
end

get "/repos/:owner/:repo/contents/*path" do
  ""
end

put "/repos/:owner/:repo/contents/*path" do
  ""
end

delete "/repos/:owner/:repo/contents/*path" do
  ""
end

get "/repos/:owner/:repo/:archive_format/:ref" do
  ""
end

get "/repos/:owner/:repo/keys" do
  ""
end

get "/repos/:owner/:repo/keys/:id" do
  ""
end

post "/repos/:owner/:repo/keys" do
  ""
end

patch "/repos/:owner/:repo/keys/:id" do
  ""
end

delete "/repos/:owner/:repo/keys/:id" do
  ""
end

get "/repos/:owner/:repo/downloads" do
  ""
end

get "/repos/:owner/:repo/downloads/:id" do
  ""
end

delete "/repos/:owner/:repo/downloads/:id" do
  ""
end

get "/repos/:owner/:repo/forks" do
  ""
end

post "/repos/:owner/:repo/forks" do
  ""
end

get "/repos/:owner/:repo/hooks" do
  ""
end

get "/repos/:owner/:repo/hooks/:id" do
  ""
end

post "/repos/:owner/:repo/hooks" do
  ""
end

patch "/repos/:owner/:repo/hooks/:id" do
  ""
end

post "/repos/:owner/:repo/hooks/:id/tests" do
  ""
end

delete "/repos/:owner/:repo/hooks/:id" do
  ""
end

post "/repos/:owner/:repo/merges" do
  ""
end

get "/repos/:owner/:repo/releases" do
  ""
end

get "/repos/:owner/:repo/releases/:id" do
  ""
end

post "/repos/:owner/:repo/releases" do
  ""
end

patch "/repos/:owner/:repo/releases/:id" do
  ""
end

delete "/repos/:owner/:repo/releases/:id" do
  ""
end

get "/repos/:owner/:repo/releases/:id/assets" do
  ""
end

get "/repos/:owner/:repo/stats/contributors" do
  ""
end

get "/repos/:owner/:repo/stats/commit_activity" do
  ""
end

get "/repos/:owner/:repo/stats/code_frequency" do
  ""
end

get "/repos/:owner/:repo/stats/participation" do
  ""
end

get "/repos/:owner/:repo/stats/punch_card" do
  ""
end

get "/repos/:owner/:repo/statuses/:ref" do
  ""
end

post "/repos/:owner/:repo/statuses/:ref" do
  ""
end

# Search
get "/search/repositories" do
  ""
end

get "/search/code" do
  ""
end

get "/search/issues" do
  ""
end

get "/search/users" do
  ""
end

get "/legacy/issues/search/:owner/:repository/:state/:keyword" do
  ""
end

get "/legacy/repos/search/:keyword" do
  ""
end

get "/legacy/user/search/:keyword" do
  ""
end

get "/legacy/user/email/:email" do
  ""
end

# Users
get "/users/:user" do
  ""
end

get "/user" do
  ""
end

patch "/user" do
  ""
end

get "/users" do
  ""
end

get "/user/emails" do
  ""
end

post "/user/emails" do
  ""
end

delete "/user/emails" do
  ""
end

get "/users/:user/followers" do
  ""
end

get "/user/followers" do
  ""
end

get "/users/:user/following" do
  ""
end

get "/user/following" do
  ""
end

get "/user/following/:user" do
  ""
end

get "/users/:user/following/:target_user" do
  ""
end

put "/user/following/:user" do
  ""
end

delete "/user/following/:user" do
  ""
end

get "/users/:user/keys" do
  ""
end

get "/user/keys" do
  ""
end

get "/user/keys/:id" do
  ""
end

post "/user/keys" do
  ""
end

patch "/user/keys/:id" do
  ""
end

delete "/user/keys/:id" do
  ""
end

set :logging, false
set :port, 3000
