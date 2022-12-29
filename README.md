# NIBE Client

## Introduction

NIBE is a Swedish company that makes heat pumps. They have a service called NIBEuplink.
NIBE heat pumps have NIBEuplink. This client accesses the NIBE uplink API (see [this](https://api.nibeuplink.com/docs/v1) this documentation from NIBE).

It uses the official and sanctioned cloud API provided by NIEBE.

This gem was provided by [Thermogen BV](https://www.thermogen.nl/) and [Stekker.app BV](https://stekker.com) and is not officially supported by NIBE.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add nibe_uplink-client

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install nibe_uplink-client

## Configuration

#### Step 1
Create an account at [NIBEuplink](https://www.nibeuplink.com/).
#### Step 2
Create an application at [NIBEuplink](https://api.nibeuplink.com/).
Note the CLIENT_ID and CLIENT_SECRET and use them below.
#### Step 3
Install [this](https://github.com/SaltwaterC/oauth2-cli) gem as follows: `gem install oauth2-cli`.

Request the tokens (access and refresh token) using the following command:
```bash
oauth2-cli \
  -a https://api.nibeuplink.com/oauth/authorize \
  -t https://api.nibeuplink.com/oauth/token \
  -i CLIENT_ID \
  -s SECRET_ID \
  -w -o READSYSTEM
```
Now there's a file with a key called `api.nibeuplink.com.json`. Rename this:
`.nibe-tokens.json` and place it in this directory.

#### Step 4
Create a file called `.nibe-client.json` with the following contents:
```json
{
  "client_id": "[the CLIENT_ID from step 2]",
  "client_secret": "[the CLIENT_SECRET from step 2]"
}
```

## Usage
Run `ruby nibe-fetch.rb` to get a list of your systems. Note the system id and use it below.

```ruby
require 'nibe'

client = NIBE::Client.new
client.systems
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/niebe_client.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
