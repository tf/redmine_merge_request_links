module RedmineMergeRequestLinks
  class EventHandlerBase
    def initialize(token:)
      @token = nil
      unless token == nil
          @token = {:token => token, :projects => ['*'] }
      end
      @active_token = nil
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
          project_ids = []
          project = Project.find_by_id dbtoken.project_id
          projects_queue = [ project ]
          current_project = projects_queue.shift
          until current_project == nil
            project_ids.push current_project.id
            if dbtoken.subprojects
              projects_queue += current_project.children
            end
            current_project = projects_queue.shift
          end
          tokens.push({:token => dbtoken.token, :projects => project_ids })
        end
      end
      tokens
    end

    def get_active_token
      @active_token
    end

    def verify_token(token, request, payload)
      # Check if token from payload matches this token
    end

    def get_all_tokens
      tokens = []
      if @token != nil
        tokens.push(@token)
      end
      tokens += self.get_database_tokens

      tokens
    end

    def verify(request)
      request.body.rewind
      payload = request.body.read

      for token in self.get_all_tokens
        if verify_token(token[:token], request, payload) == true
          @active_token = token
          return true
        end
      end
      false
    end

  end
end