require "orion"

# ???
router OrionBenchmark do
  get "/authorizations", ->(context : HTTP::Server::Context) do
  end

  get "/authorizations/:id", ->(context : HTTP::Server::Context) do
  end

  post "/authorizations", ->(context : HTTP::Server::Context) do
  end

  put "/authorizations/clients/:client_id", ->(context : HTTP::Server::Context) do
  end

  patch "/authorizations/:id", ->(context : HTTP::Server::Context) do
  end

  delete "/authorizations/:id", ->(context : HTTP::Server::Context) do
  end

  get "/applications/:client_id/tokens/:access_token", ->(context : HTTP::Server::Context) do
  end

  delete "/applications/:client_id/tokens", ->(context : HTTP::Server::Context) do
  end

  delete "/applications/:client_id/tokens/:access_token", ->(context : HTTP::Server::Context) do
  end

  # Activity
  get "/events", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/events", ->(context : HTTP::Server::Context) do
  end

  get "/networks/:owner/:repo/events", ->(context : HTTP::Server::Context) do
  end

  get "/orgs/:org/events", ->(context : HTTP::Server::Context) do
  end

  get "/users/:user/received_events", ->(context : HTTP::Server::Context) do
  end

  get "/users/:user/received_events/public", ->(context : HTTP::Server::Context) do
  end

  get "/users/:user/events", ->(context : HTTP::Server::Context) do
  end

  get "/users/:user/events/public", ->(context : HTTP::Server::Context) do
  end

  get "/users/:user/events/orgs/:org", ->(context : HTTP::Server::Context) do
  end

  get "/feeds", ->(context : HTTP::Server::Context) do
  end

  get "/notifications", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/notifications", ->(context : HTTP::Server::Context) do
  end

  put "/notifications", ->(context : HTTP::Server::Context) do
  end

  put "/repos/:owner/:repo/notifications", ->(context : HTTP::Server::Context) do
  end

  get "/notifications/threads/:id", ->(context : HTTP::Server::Context) do
  end

  patch "/notifications/threads/:id", ->(context : HTTP::Server::Context) do
  end

  get "/notifications/threads/:id/subscription", ->(context : HTTP::Server::Context) do
  end

  put "/notifications/threads/:id/subscription", ->(context : HTTP::Server::Context) do
  end

  delete "/notifications/threads/:id/subscription", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/stargazers", ->(context : HTTP::Server::Context) do
  end

  get "/users/:user/starred", ->(context : HTTP::Server::Context) do
  end

  get "/user/starred", ->(context : HTTP::Server::Context) do
  end

  get "/user/starred/:owner/:repo", ->(context : HTTP::Server::Context) do
  end

  put "/user/starred/:owner/:repo", ->(context : HTTP::Server::Context) do
  end

  delete "/user/starred/:owner/:repo", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/subscribers", ->(context : HTTP::Server::Context) do
  end

  get "/users/:user/subscriptions", ->(context : HTTP::Server::Context) do
  end

  get "/user/subscriptions", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/subscription", ->(context : HTTP::Server::Context) do
  end

  put "/repos/:owner/:repo/subscription", ->(context : HTTP::Server::Context) do
  end

  delete "/repos/:owner/:repo/subscription", ->(context : HTTP::Server::Context) do
  end

  get "/user/subscriptions/:owner/:repo", ->(context : HTTP::Server::Context) do
  end

  put "/user/subscriptions/:owner/:repo", ->(context : HTTP::Server::Context) do
  end

  delete "/user/subscriptions/:owner/:repo", ->(context : HTTP::Server::Context) do
  end

  # Gists
  get "/users/:user/gists", ->(context : HTTP::Server::Context) do
  end

  get "/gists", ->(context : HTTP::Server::Context) do
  end

  get "/gists/public", ->(context : HTTP::Server::Context) do
  end

  get "/gists/starred", ->(context : HTTP::Server::Context) do
  end

  get "/gists/:id", ->(context : HTTP::Server::Context) do
  end

  post "/gists", ->(context : HTTP::Server::Context) do
  end

  patch "/gists/:id", ->(context : HTTP::Server::Context) do
  end

  put "/gists/:id/star", ->(context : HTTP::Server::Context) do
  end

  delete "/gists/:id/star", ->(context : HTTP::Server::Context) do
  end

  get "/gists/:id/star", ->(context : HTTP::Server::Context) do
  end

  post "/gists/:id/forks", ->(context : HTTP::Server::Context) do
  end

  delete "/gists/:id", ->(context : HTTP::Server::Context) do
  end

  # Git Data
  get "/repos/:owner/:repo/git/blobs/:sha", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/git/blobs", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/git/commits/:sha", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/git/commits", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/git/refs/*ref", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/git/refs", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/git/refs", ->(context : HTTP::Server::Context) do
  end

  patch "/repos/:owner/:repo/git/refs/*ref", ->(context : HTTP::Server::Context) do
  end

  delete "/repos/:owner/:repo/git/refs/*ref", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/git/tags/:sha", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/git/tags", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/git/trees/:sha", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/git/trees", ->(context : HTTP::Server::Context) do
  end

  # Issues
  get "/issues", ->(context : HTTP::Server::Context) do
  end

  get "/user/issues", ->(context : HTTP::Server::Context) do
  end

  get "/orgs/:org/issues", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/issues", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/issues/:number", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/issues", ->(context : HTTP::Server::Context) do
  end

  patch "/repos/:owner/:repo/issues/:number", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/assignees", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/assignees/:assignee", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/issues/:number/comments", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/issues/comments", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/issues/comments/:id", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/issues/:number/comments", ->(context : HTTP::Server::Context) do
  end

  patch "/repos/:owner/:repo/issues/comments/:id", ->(context : HTTP::Server::Context) do
  end

  delete "/repos/:owner/:repo/issues/comments/:id", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/issues/:number/events", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/issues/events", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/issues/events/:id", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/labels", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/labels/:name", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/labels", ->(context : HTTP::Server::Context) do
  end

  patch "/repos/:owner/:repo/labels/:name", ->(context : HTTP::Server::Context) do
  end

  delete "/repos/:owner/:repo/labels/:name", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/issues/:number/labels", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/issues/:number/labels", ->(context : HTTP::Server::Context) do
  end

  delete "/repos/:owner/:repo/issues/:number/labels/:name", ->(context : HTTP::Server::Context) do
  end

  put "/repos/:owner/:repo/issues/:number/labels", ->(context : HTTP::Server::Context) do
  end

  delete "/repos/:owner/:repo/issues/:number/labels", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/milestones/:number/labels", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/milestones", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/milestones/:number", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/milestones", ->(context : HTTP::Server::Context) do
  end

  patch "/repos/:owner/:repo/milestones/:number", ->(context : HTTP::Server::Context) do
  end

  delete "/repos/:owner/:repo/milestones/:number", ->(context : HTTP::Server::Context) do
  end

  # Miscellaneous
  get "/emojis", ->(context : HTTP::Server::Context) do
  end

  get "/gitignore/templates", ->(context : HTTP::Server::Context) do
  end

  get "/gitignore/templates/:name", ->(context : HTTP::Server::Context) do
  end

  post "/markdown", ->(context : HTTP::Server::Context) do
  end

  post "/markdown/raw", ->(context : HTTP::Server::Context) do
  end

  get "/meta", ->(context : HTTP::Server::Context) do
  end

  get "/rate_limit", ->(context : HTTP::Server::Context) do
  end

  # Organizations
  get "/users/:user/orgs", ->(context : HTTP::Server::Context) do
  end

  get "/user/orgs", ->(context : HTTP::Server::Context) do
  end

  get "/orgs/:org", ->(context : HTTP::Server::Context) do
  end

  patch "/orgs/:org", ->(context : HTTP::Server::Context) do
  end

  get "/orgs/:org/members", ->(context : HTTP::Server::Context) do
  end

  get "/orgs/:org/members/:user", ->(context : HTTP::Server::Context) do
  end

  delete "/orgs/:org/members/:user", ->(context : HTTP::Server::Context) do
  end

  get "/orgs/:org/public_members", ->(context : HTTP::Server::Context) do
  end

  get "/orgs/:org/public_members/:user", ->(context : HTTP::Server::Context) do
  end

  put "/orgs/:org/public_members/:user", ->(context : HTTP::Server::Context) do
  end

  delete "/orgs/:org/public_members/:user", ->(context : HTTP::Server::Context) do
  end

  get "/orgs/:org/teams", ->(context : HTTP::Server::Context) do
  end

  get "/teams/:id", ->(context : HTTP::Server::Context) do
  end

  post "/orgs/:org/teams", ->(context : HTTP::Server::Context) do
  end

  patch "/teams/:id", ->(context : HTTP::Server::Context) do
  end

  delete "/teams/:id", ->(context : HTTP::Server::Context) do
  end

  get "/teams/:id/members", ->(context : HTTP::Server::Context) do
  end

  get "/teams/:id/members/:user", ->(context : HTTP::Server::Context) do
  end

  put "/teams/:id/members/:user", ->(context : HTTP::Server::Context) do
  end

  delete "/teams/:id/members/:user", ->(context : HTTP::Server::Context) do
  end

  get "/teams/:id/repos", ->(context : HTTP::Server::Context) do
  end

  get "/teams/:id/repos/:owner/:repo", ->(context : HTTP::Server::Context) do
  end

  put "/teams/:id/repos/:owner/:repo", ->(context : HTTP::Server::Context) do
  end

  delete "/teams/:id/repos/:owner/:repo", ->(context : HTTP::Server::Context) do
  end

  get "/user/teams", ->(context : HTTP::Server::Context) do
  end

  # Pull Requests
  get "/repos/:owner/:repo/pulls", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/pulls/:number", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/pulls", ->(context : HTTP::Server::Context) do
  end

  patch "/repos/:owner/:repo/pulls/:number", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/pulls/:number/commits", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/pulls/:number/files", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/pulls/:number/merge", ->(context : HTTP::Server::Context) do
  end

  put "/repos/:owner/:repo/pulls/:number/merge", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/pulls/:number/comments", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/pulls/comments", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/pulls/comments/:number", ->(context : HTTP::Server::Context) do
  end

  put "/repos/:owner/:repo/pulls/:number/comments", ->(context : HTTP::Server::Context) do
  end

  patch "/repos/:owner/:repo/pulls/comments/:number", ->(context : HTTP::Server::Context) do
  end

  delete "/repos/:owner/:repo/pulls/comments/:number", ->(context : HTTP::Server::Context) do
  end

  # Repositories
  get "/user/repos", ->(context : HTTP::Server::Context) do
  end

  get "/users/:user/repos", ->(context : HTTP::Server::Context) do
  end

  get "/orgs/:org/repos", ->(context : HTTP::Server::Context) do
  end

  get "/repositories", ->(context : HTTP::Server::Context) do
  end

  post "/user/repos", ->(context : HTTP::Server::Context) do
  end

  post "/orgs/:org/repos", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo", ->(context : HTTP::Server::Context) do
  end

  patch "/repos/:owner/:repo", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/contributors", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/languages", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/teams", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/tags", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/branches", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/branches/:branch", ->(context : HTTP::Server::Context) do
  end

  delete "/repos/:owner/:repo", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/collaborators", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/collaborators/:user", ->(context : HTTP::Server::Context) do
  end

  put "/repos/:owner/:repo/collaborators/:user", ->(context : HTTP::Server::Context) do
  end

  delete "/repos/:owner/:repo/collaborators/:user", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/comments", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/commits/:sha/comments", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/commits/:sha/comments", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/comments/:id", ->(context : HTTP::Server::Context) do
  end

  patch "/repos/:owner/:repo/comments/:id", ->(context : HTTP::Server::Context) do
  end

  delete "/repos/:owner/:repo/comments/:id", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/commits", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/commits/:sha", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/readme", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/contents/*path", ->(context : HTTP::Server::Context) do
  end

  put "/repos/:owner/:repo/contents/*path", ->(context : HTTP::Server::Context) do
  end

  delete "/repos/:owner/:repo/contents/*path", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/:archive_format/:ref", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/keys", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/keys/:id", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/keys", ->(context : HTTP::Server::Context) do
  end

  patch "/repos/:owner/:repo/keys/:id", ->(context : HTTP::Server::Context) do
  end

  delete "/repos/:owner/:repo/keys/:id", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/downloads", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/downloads/:id", ->(context : HTTP::Server::Context) do
  end

  delete "/repos/:owner/:repo/downloads/:id", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/forks", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/forks", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/hooks", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/hooks/:id", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/hooks", ->(context : HTTP::Server::Context) do
  end

  patch "/repos/:owner/:repo/hooks/:id", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/hooks/:id/tests", ->(context : HTTP::Server::Context) do
  end

  delete "/repos/:owner/:repo/hooks/:id", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/merges", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/releases", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/releases/:id", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/releases", ->(context : HTTP::Server::Context) do
  end

  patch "/repos/:owner/:repo/releases/:id", ->(context : HTTP::Server::Context) do
  end

  delete "/repos/:owner/:repo/releases/:id", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/releases/:id/assets", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/stats/contributors", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/stats/commit_activity", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/stats/code_frequency", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/stats/participation", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/stats/punch_card", ->(context : HTTP::Server::Context) do
  end

  get "/repos/:owner/:repo/statuses/:ref", ->(context : HTTP::Server::Context) do
  end

  post "/repos/:owner/:repo/statuses/:ref", ->(context : HTTP::Server::Context) do
  end

  # Search
  get "/search/repositories", ->(context : HTTP::Server::Context) do
  end

  get "/search/code", ->(context : HTTP::Server::Context) do
  end

  get "/search/issues", ->(context : HTTP::Server::Context) do
  end

  get "/search/users", ->(context : HTTP::Server::Context) do
  end

  get "/legacy/issues/search/:owner/:repository/:state/:keyword", ->(context : HTTP::Server::Context) do
  end

  get "/legacy/repos/search/:keyword", ->(context : HTTP::Server::Context) do
  end

  get "/legacy/user/search/:keyword", ->(context : HTTP::Server::Context) do
  end

  get "/legacy/user/email/:email", ->(context : HTTP::Server::Context) do
  end

  # Users
  get "/users/:user", ->(context : HTTP::Server::Context) do
  end

  get "/user", ->(context : HTTP::Server::Context) do
  end

  patch "/user", ->(context : HTTP::Server::Context) do
  end

  get "/users", ->(context : HTTP::Server::Context) do
  end

  get "/user/emails", ->(context : HTTP::Server::Context) do
  end

  post "/user/emails", ->(context : HTTP::Server::Context) do
  end

  delete "/user/emails", ->(context : HTTP::Server::Context) do
  end

  get "/users/:user/followers", ->(context : HTTP::Server::Context) do
  end

  get "/user/followers", ->(context : HTTP::Server::Context) do
  end

  get "/users/:user/following", ->(context : HTTP::Server::Context) do
  end

  get "/user/following", ->(context : HTTP::Server::Context) do
  end

  get "/user/following/:user", ->(context : HTTP::Server::Context) do
  end

  get "/users/:user/following/:target_user", ->(context : HTTP::Server::Context) do
  end

  put "/user/following/:user", ->(context : HTTP::Server::Context) do
  end

  delete "/user/following/:user", ->(context : HTTP::Server::Context) do
  end

  get "/users/:user/keys", ->(context : HTTP::Server::Context) do
  end

  get "/user/keys", ->(context : HTTP::Server::Context) do
  end

  get "/user/keys/:id", ->(context : HTTP::Server::Context) do
  end

  post "/user/keys", ->(context : HTTP::Server::Context) do
  end

  patch "/user/keys/:id", ->(context : HTTP::Server::Context) do
  end

  delete "/user/keys/:id", ->(context : HTTP::Server::Context) do
  end
end

# puts OrionBenchmark.visualize

OrionBenchmark.listen(port: ENV["PORT"].to_i, host: "0.0.0.0")
