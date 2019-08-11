module RedmineMergeRequestLinks
  class EventHandlerBase
    def initialize(tokens:)
      @tokens = tokens
      @project_ids = ['*']
    end

    def get_allowed_projects
      if @project_ids[0] == '*'
        return ['*']
      end
      allowed_projects = []
      projects = [Project.find(@project_id)]
      projects.each do |project|
        allowed_projects.push(project.id)
        projects << project
      end

      allowed_projects
    end

    def verify_token(token, request, payload)

    end

    def verify(request)
      request.body.rewind
      payload = request.body.read

      for token in @tokens
        if verify_token(token[:token], request, payload) == true
          if token[:project_id] != nil
            @project_ids = token[:project_ids]
          end
          return true
        end
      end
      false
    end

  end
end