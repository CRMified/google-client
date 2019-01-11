require 'google/apis/admin_directory_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'active_support/time'
require_relative './concerns/group_utils'
require_relative './concerns/member_utils'
require 'pry'

module Groups
  class Client
    include GoogleGroups::GroupUtils
    include GoogleGroups::MemberUtils

    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
    APPLICATION_NAME = 'Google Group API Client'.freeze
    SCOPE = ['https://www.googleapis.com/auth/admin.directory.user',
             'https://www.googleapis.com/auth/admin.directory.user.readonly',
             'https://www.googleapis.com/auth/admin.directory.user.alias',
             'https://www.googleapis.com/auth/admin.directory.group',
             'https://www.googleapis.com/auth/admin.directory.group.readonly'].freeze
    USER_ID = 'default'.freeze

    def initialize(credential_file, token_file, customer_id)
      @credential_file = credential_file
      @token_file = token_file
      @customer_id = customer_id
      authorize
      service
    end

    def upsert(group_email:, group_name:, group_description: nil, member_emails: [])
      if find_group(group_email)
        update_group(group_email, group_name, group_description)
      else
        create_group(group_email, group_name, group_description)
      end
      remove_or_add_members(group_email, member_emails)
      # update_group_description(group_name)
    end

    private

    def authorize
      client_id = Google::Auth::ClientId.from_file(@credential_file)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: @token_file)
      authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
      credentials = authorizer.get_credentials(USER_ID)
      credentials
    end

    def service
      @service ||= load_service
    end

    def load_service
      service = Google::Apis::AdminDirectoryV1::DirectoryService.new
      service.client_options.application_name = APPLICATION_NAME
      service.authorization = authorize
      service
    end
  end
end
