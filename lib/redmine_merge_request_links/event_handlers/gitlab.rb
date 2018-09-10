module RedmineMergeRequestLinks
  module EventHandlers
    class Gitlab
      def matches?(request)
        request.headers['X-Gitlab-Event'] == 'Merge Request Hook'
      end

      def parse_params(params)
        params.require(:object_attributes).permit(:state, :url, :title)
      end
    end
  end
end
