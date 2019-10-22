module RedmineMergeRequestLinks
  module EventHandlers
    class Gitlab < RedmineMergeRequestLinks::EventHandlerBase
      def matches?(request)
        request.headers['X-Gitlab-Event'] == 'Merge Request Hook' ||
          (request.headers['X-Gitlab-Event'] == 'System Hook' &&
           request.request_parameters['event_type'] == 'merge_request')
      end

      def get_provider_name
        'gitlab'
      end

      def verify_token(token, request, payload)
        request.headers['X-Gitlab-Token'] == token
      end

      def parse_params(params)
        params
          .require(:object_attributes)
          .permit(:state, :url, :title, :description, :iid,
                  user: :name, target: :path_with_namespace)
          .tap do |attributes|
            target = attributes.delete(:target) || {}

            attributes[:provider] = 'gitlab'
            attributes[:display_id] =
              "#{target[:path_with_namespace]}!#{attributes.delete(:iid)}"

          attributes[:author_name] = "@#{params.require(:user).fetch(:username)}"
          end
      end
    end
  end
end
