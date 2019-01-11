# rp-google-client

#### Installation

Add this line to your application's Gemfile:

```ruby
gem 'rp-google_client'
```

And then execute:
```
    $ bundle install
```
Or install it yourself as:
```
    $ gem install rp-google_client
```
#### Datas
`GoogleClient::Groups::Client.new(credential_file, token_file, customer_id)`

- `credential_file` : The path of gogle app credentials file that downloaded from google.admin.
- `token_file`: Path of token file that get after google.admin sign in.
- `customer_id`: Client id that get form token file.


#### Methods
- `upsert(group_email:, group_name:, group_description:, member_emails:)`
- `create_group(email, name, description)`
- `update_group(email, name, description)`
