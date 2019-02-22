module GoogleClient
  module MemberUtils
    def member_list(email)
      @member_list = @service.list_members(email).members || []
    end

    def members_to_be_removed(group_email, emails)
      @members_to_be_removed ||= @service.list_members(group_email).members.reject do |member|
        emails.include?(member.email)
      end
    end

    def members_to_be_added(group_email, emails)
      @members_to_be_added ||= emails.reject do |email|
        @service.list_members(group_email).members.map(&:email).include?(email)
      end
    end

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
      #sleep(1)
      member_list(group_email)
      add_members(group_email, members_to_be_added(group_email, emails))
      remove_members(group_email, members_to_be_removed(group_email, emails))
    end
  end
end
