module RedmineMergeRequestLinks
  module EventHandlers
    class Gitea
      def initialize(token:)
        @token = token
      end

      def matches?(request)
        request.headers['X-Gitea-Event'] == 'pull_request'
      end

      def verify(request)
      end

      def parse_params(params)
        params
          .require(:pull_request)
          .permit(:state, :merged, :html_url, :title, :body, :number,
                  user: :login,
                  base: { repo: :full_name }).tap do |attributes|

          merged = attributes.delete(:merged)
          user = attributes.delete(:user) || {}
          base = attributes.delete(:base) || {}
          repo = base.fetch(:repo, {})

          if attributes[:state] == 'closed' && merged
            attributes[:state] = 'merged'
          end

          attributes[:provider] = 'gitea'
          attributes[:url] = attributes.delete(:html_url)
          attributes[:description] = attributes.delete(:body)
          attributes[:author_name] = "@#{user[:login]}"

          attributes[:display_id] =
            "#{repo[:full_name]}##{attributes.delete(:number)}"
        end
      end
    end
  end
end
