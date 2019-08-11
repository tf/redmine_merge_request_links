module RedmineMergeRequestLinks
  class EventHandlerBase
    def initialize(tokens:)
      @tokens = tokens
      @project_id = nil
    end

    def verify_project(project: Project)
      @project_id == nil || project.id == @project_id
    end

    def get_allowed_projects
      if @project_id == nil
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
            @project_id = token[:project_id]
          end
          return true
        end
      end
      false
    end

  end
end