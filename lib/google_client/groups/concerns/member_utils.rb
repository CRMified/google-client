module GoogleClient
  module MemberUtils
    def member_list(email)
      @member_list = @service.list_members(email).members || []
    end

    def members_to_be_removed(group_email, emails)
      if @service.list_members(group_email).members.nil?
        []
      else
        @service.list_members(group_email).members.reject do |member|
          emails.include?(member.email)
        end
      end
    end

    def members_to_be_added(group_email, emails)
      if @service.list_members(group_email).members.nil?
        emails
      else
        emails.reject do |email|
          @service.list_members(group_email).members.map(&:email).include?(email)
        end
      end
    end


    # swarna.saravanan@trailblazercgl.com
    # swarnalatha.saravanan@trailblazercgl.com



    def add_members(group_email, emails)
      emails.each do |email|
        member = Google::Apis::AdminDirectoryV1::Member.new(email: email)
        @service.insert_member(group_email, member)
      end
    end

    def remove_members(group_email, members)
      members.each do |member|
        @service.delete_member(group_email, member.email)
      end
    end

    def remove_or_add_members(group_email, emails)
      member_list(group_email)
      remove_members(group_email, members_to_be_removed(group_email, emails))
      add_members(group_email, members_to_be_added(group_email, emails))
    end
  end
end
