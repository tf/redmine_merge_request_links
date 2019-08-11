require 'redmine_merge_request_links/hooks'

module RedmineMergeRequestLinks
  github_envtoken = ENV['REDMINE_MERGE_REQUEST_LINKS_GITHUB_WEBHOOK_TOKEN']
  gitlab_envtoken = ENV['REDMINE_MERGE_REQUEST_LINKS_GITLAB_WEBHOOK_TOKEN']
  gitea_envtoken  = ENV['REDMINE_MERGE_REQUEST_LINKS_GITEA_WEBHOOK_TOKEN']

  gitea_token = []
  if gitea_envtoken.present?
    gitea_token.push({:token => gitea_envtoken, :project_id => nil })
  end

  github_token = []
  if github_envtoken.present?
    github_token.push({:token => github_envtoken, :project_id => nil })
  end

  gitlab_token = []
  if gitlab_envtoken.present?
    gitlab_token.push({:token => gitlab_envtoken, :project_id => nil })
  end

  mattr_accessor :event_handlers
  self.event_handlers = [
    RedmineMergeRequestLinks::EventHandlers::Gitea.new(tokens: gitea_token),
    RedmineMergeRequestLinks::EventHandlers::Github.new(tokens: github_token),
    RedmineMergeRequestLinks::EventHandlers::Gitlab.new(tokens: gitlab_token)
  ]
end
