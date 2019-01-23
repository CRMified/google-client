module GoogleClient
  module GroupUtils
    def find_group(group_email)
      group_presense = group_list.select do |group|
        group.email == group_email
      end
      return group_presense.first # will return nil from an empty array if there is none with the criteria
    end

    def create_group(email, name, description)
      group = Google::Apis::AdminDirectoryV1::Group
              .new(name: name,
                   email: email,
                   description: description)
      @service.insert_group(group)
    end

    def update_group(email, name, description)
      group = Google::Apis::AdminDirectoryV1::Group
              .new(name: name,
                   description: description)
      @service.update_group(email, group)
    end

    def update_group_description(group)
      last_updated_time = group.description[/updated at (.*?)\./m, 1]
      description = if last_updated_time
                      group.description.gsub(last_updated_time, Time.now.utc.to_s)
                    else
                      group.description + " Last updated at #{Time.now.utc}."
                    end
      update_group(group.email, group.name, description)
    end

    def group_list
      return @group_list if @group_list

      fetch_group_list
    end

    def fetch_group_list
      @group_list = @service.list_groups(customer: @customer_id).groups
      next_page = @service.list_groups(customer: @customer_id).next_page_token
      until next_page.nil?
        @group_list = @group_list.push(@service.list_groups(
          customer: @customer_id,
          page_token: next_page
        ).groups)
        next_page = @service.list_groups(customer: @customer_id,
                                         page_token: next_page).next_page_token
      end
      @group_list.flatten!
      @group_list
    end
  end
end
