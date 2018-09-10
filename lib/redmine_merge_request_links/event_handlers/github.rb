module RedmineMergeRequestLinks
  module EventHandlers
    class Github
      def matches?(request)
        request.headers['X-GitHub-Event'] == 'pull_request'
      end

      def parse_params(params)
        params.require(:pull_request).permit(:state, :html_url, :title).tap do |attributes|
          attributes[:url] = attributes.delete(:html_url)
        end
      end
    end
  end
end
