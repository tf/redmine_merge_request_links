require 'redmine_merge_request_links/hooks'

module RedmineMergeRequestLinks
  mattr_accessor :providers
  self.providers = [
      :gitea,
      :github,
      :gitlab
  ]

  def get_descendant_ids(project: Project)
    ids = []
    project.descendants.each do |subproject|
      ids.push(subproject.id)
      unless subproject.leaf?
        ids.concat(get_descendant_ids(subproject))
      end
    end
    ids
  end

  def self.collect_tokens
    tokens = {}
    self.providers.each do |provider|
      tokens[provider] = []

      # Get global token from environment if exists
      envtoken = ENV["REDMINE_MERGE_REQUEST_LINKS_#{provider.to_s.upcase}_WEBHOOK_TOKEN"]
      if envtoken.present?
        tokens[provider].push({:token => envtoken, :projects => ['*'] })
      end

      # Get tokens from database
      dbtokens = ProjectsMergeRequestToken.where :provider => provider
      if dbtokens != nil
        dbtokens.each do |dbtoken|
          projectsids = []
          project = Project.find_by_id dbtoken.project_id
          projects_queue = [ project ]
          current_project = projects_queue.shift
          until current_project == nil
            projectsids.push current_project.id
            if dbtoken.subprojects
              projects_queue += current_project.children
            end
            current_project = projects_queue.shift
          end
          tokens[provider].push({:token => dbtoken.token, :projects => projectsids })
        end
      end
    end
    tokens
  end

  def self.get_event_handlers
    event_handlers = []
    tokens = self.collect_tokens
    self.providers.each do |provider|
      # Create new instance of EventHandler and add it to array
      if tokens[provider] != nil && tokens[provider].length > 0
        class_name = "RedmineMergeRequestLinks::EventHandlers::#{provider.to_s.upcase_first}"
        event_handlers.push(Object::const_get(class_name).new(tokens: tokens[provider]))
      end
    end
    event_handlers
  end
end
