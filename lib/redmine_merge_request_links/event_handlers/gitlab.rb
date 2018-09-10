module RedmineMergeRequestLinks
  module EventHandlers
    class Gitlab
      def initialize(token:)
        @token = token
      end

      def matches?(request)
        request.headers['X-Gitlab-Event'] == 'Merge Request Hook'
      end

      def verify(request)
        request.headers['X-Gitlab-Token'] == @token
      end

      def parse_params(params)
        params.require(:object_attributes).permit(:state, :url, :title)
      end
    end
  end
end
