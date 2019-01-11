require 'google/apis/admin_directory_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'active_support/time'
require_relative './concerns/group_utils'
require_relative './concerns/member_utils'
require 'pry'

module GoogleGroups
  class Client
    # include GoogleGroups::GroupUtils
    include GoogleGroups::MemberUtils

    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
    APPLICATION_NAME = 'Google Group API Client'.freeze
    SCOPE = ['https://www.googleapis.com/auth/admin.directory.user',
             'https://www.googleapis.com/auth/admin.directory.user.readonly',
             'https://www.googleapis.com/auth/admin.directory.user.alias',
             'https://www.googleapis.com/auth/admin.directory.group',
             'https://www.googleapis.com/auth/admin.directory.group.readonly'].freeze

    def initialize(credential_file, token_file, user_id)
      @credential_file = credential_file
      @token_file = token_file
      @user_id = user_id
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
      credentials = authorizer.get_credentials('default')
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

    def find_group(group_email)
      response = @service.list_groups(customer: 'C01h21jpc')
      group_presense = response.groups.select do |group|
        group.email == group_email
      end
      @group = group_presense.first # will return nil from an empty array if there is none with the criteria
    end

    def create_group(email, name, description)
      group = Google::Apis::AdminDirectoryV1::Group
              .new(name: name,
                   email: email,
                   description: description)
      @service.insert_group(group)
      @group = find_group(email)
    end

    def update_group(email, name, description)
      group = Google::Apis::AdminDirectoryV1::Group
              .new(name: name,
                   description: description)
      @service.update_group(email, group)
    end

    def update_group_description(group_email)
      group = find_group(group_email)
      last_updated_time = group.description[/updated at:(.*?)\./m, 1]
      description = if last_updated_time
        group.description.gsub(last_updated_time, Time.current)
      else
        group.description + " Last updated at #{Time.current}."
      end
      update_group(group_email, group.name, description)
    end
  end
end
