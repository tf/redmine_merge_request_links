# For unknown reasons, column information is not reloaded correctly
# when running the `db:migrate` and `redmine:plugins:test` tasks in
# one `rake` call. Reset manually.
if defined?(ActiveRecord)
  ActiveRecord::Base.descendants.each(&:reset_column_information)
end

# Suppress warnings
$VERBOSE = false

# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

Rails.logger.level = :warn

module RedmineMergeRequestLinks
  module RequestTestHelperCompat
    def get(action, parameters = {})
      super(action, compatible_request_options(parameters))
    end

    def post(action, parameters = {})
      super(action, compatible_request_options(parameters))
    end

    private

    def compatible_request_options(parameters)
      return parameters if Rails.version < '5.0'
      { params: parameters }
    end
  end
end
