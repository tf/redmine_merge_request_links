require 'redmine_merge_request_links/hooks'

module RedmineMergeRequestLinks
  mattr_accessor :providers
  self.providers = [
      :gitea,
      :github,
      :gitlab
  ]

  mattr_accessor :event_handlers
  self.event_handlers = []

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

  tokens = {}
  self.providers.each do |provider|
    tokens[provider] = []

    # Get global token from environment if exists
    envtoken = ENV["REDMINE_MERGE_REQUEST_LINKS_#{provider.to_s.upcase}_WEBHOOK_TOKEN"]
    if envtoken.present?
      tokens[provider].push({:token => envtoken, :projects => nil })
    end

    # Get tokens from database
    dbtokens = ProjectsMergeRequestToken.where :provider => provider
    if dbtokens != nil
      dbtokens.each do |dbtoken|
        tokens[provider].push({:token => dbtoken.token, :projects => dbtoken.project_id })
        if dbtoken.subprojects


          # todo: add tokens for subprojects
        end
      end
    end

    Logger.new(STDOUT).error "Processing the request..."

    # Create new instance of EventHandler and add it to array
    class_name = "RedmineMergeRequestLinks::EventHandlers::#{provider.to_s.upcase_first}"
    self.event_handlers.push(Object::const_get(class_name).new(tokens: tokens[provider]))
  end
end
