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

    def update_group_description(group_email)
      group = find_group(group_email)
      last_updated_time = group.description[/updated at (.*?)\./m, 1]
      description = if last_updated_time
        group.description.gsub(last_updated_time, Time.now.utc.to_s)
      else
        group.description + " Last updated at #{Time.now.utc}."
      end
      update_group(group_email, group.name, description)
    end

    def group_list
      @group_list ||= @service.list_groups(customer: @customer_id).groups
    end
  end
end
