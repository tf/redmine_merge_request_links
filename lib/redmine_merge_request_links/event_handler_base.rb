module RedmineMergeRequestLinks
  class EventHandlerBase
    def initialize()
      @token = nil
      self.set_envtoken
      @active_token_project_ids = ['*']
    end

    def set_envtoken
      envtoken = ENV["REDMINE_MERGE_REQUEST_LINKS_#{get_provider_name.to_s.upcase}_WEBHOOK_TOKEN"]
      if envtoken.present?
        @token = {:token => envtoken, :projects => ['*'] }
      end
    end

    def get_provider_name
      ''
    end

    def get_database_tokens
      tokens = []
      # Get tokens from database
      dbtokens = ProjectsMergeRequestToken.where :provider => self.get_provider_name
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
          tokens.push({:token => dbtoken.token, :projects => projectsids })
        end
      end
      tokens
    end

    def get_allowed_projects
      @active_token_project_ids
    end

    def verify_token(token, request, payload)

    end

    def verify(request)
      request.body.rewind
      payload = request.body.read

      tokens = get_database_tokens
      unless @token
        tokens.shift(@token)
      end
      for token in tokens
        if verify_token(token[:token], request, payload) == true
          if token[:projects] != []
            @active_token_project_ids = token[:projects]
          end
          return true
        end
      end
      false
    end

  end
end