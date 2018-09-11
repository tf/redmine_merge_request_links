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
        params
          .require(:object_attributes)
          .permit(:state, :url, :title, :description, :iid,
                  user: :name, target: :path_with_namespace)
          .tap do |attributes|
            target = attributes.delete(:target) || {}

            attributes[:display_id] =
              "#{target[:path_with_namespace]}!#{attributes.delete(:iid)}"

            attributes[:author_name] = params.require(:user).fetch(:name)
          end
      end
    end
  end
end
