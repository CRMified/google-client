# rp-google-client

#### Installation

Add this line to your application's Gemfile:

```ruby
gem 'rp-google_client', git: 'https://github.com/CRMified/google-client.git', branch: 'dev'
```

And then execute:
```
    $ bundle install
```

#### Getting Started

We need to initialize a google grups client by passing in the following parameters.

- `credential_file` : The path of gogle app credentials file that downloaded from google.admin.
- `token_file`: Path of token file that get after google.admin sign in.
- `customer_id`: Client id that get form token file.

```rb
gcc = GoogleClient::Groups::Client.new(credential_file, token_file, customer_id)
```


#### Methods
- `upsert(group_email:, group_name:, group_description:, member_emails:)`

If you are not sure if the group already exist one can use this method. It is a bit slow
initially as we are doing a fetch of all the groups and then comparing for its
existence.

- `create_group(email, name, description)`

To create group, the parameters are:
email       - group email
name        - group name
description - group description

- `update_group(email, name, description)`

To update group, the parameters are:
email       - group email
name        - group name
description - group description

- `list_groups`

Loads all the groups associated with this client