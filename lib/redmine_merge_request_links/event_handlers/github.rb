module RedmineMergeRequestLinks
  module EventHandlers
    class Github
      def initialize(token:)
        @token = token
      end

      def matches?(request)
        request.headers['X-GitHub-Event'] == 'pull_request'
      end

      def verify(request)
        request.body.rewind
        payload = request.body.read

        signature =
          'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'),
                                            @token,
                                            payload)

        Rack::Utils.secure_compare(signature,
                                   request.headers['X-Hub-Signature'])
      end

      def parse_params(params)
        params
          .require(:pull_request)
          .permit(:state, :html_url, :title, :body, :number,
                  user: :login,
                  base: { repo: :full_name }).tap do |attributes|

          user = attributes.delete(:user) || {}
          base = attributes.delete(:base) || {}
          repo = base.fetch(:repo, {})

          attributes[:provider] = 'github'
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
