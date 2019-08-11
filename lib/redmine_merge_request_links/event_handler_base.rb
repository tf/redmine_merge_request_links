module RedmineMergeRequestLinks
  class EventHandlerBase
    def initialize(tokens:)
      @tokens = tokens
      @project_ids = ['*']
    end

    def get_allowed_projects
      @project_ids
    end

    def verify_token(token, request, payload)

    end

    def verify(request)
      request.body.rewind
      payload = request.body.read

      for token in @tokens
        if verify_token(token[:token], request, payload) == true
          if token[:projects] != []
            @project_ids = token[:projects]
          end
          return true
        end
      end
      false
    end

  end
end