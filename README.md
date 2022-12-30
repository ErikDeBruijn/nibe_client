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
Create a file called `.nibe-client.json` with the following contents:
```json
{
"client_id": "[the CLIENT_ID from step 2]",
  "client_secret": "[the CLIENT_SECRET from step 2]"
}
```

#### Step 4
Run `./bin/authorize.rb` to get credentials. Follow the instructions on the terminal and authorize the app.

Credentials should be written to `.nibe-credentials.json`.

## Usage
### Interactive console
Run `./bin/console` to authorize and explore how to get a list of your systems and see system details.
Here you can type `help` and explore the library.
See the `bin` directory for more examples.

### CLI tool
Run `./bin/nibe-cli --help` to see the available commands.

If you run `nibe_uplink-client/bin/nibe-cli -s 1234 --yaml`, it will output:
```yaml
---
addition.electrical_addition_power: 2.5 kW
addition.time_factor: 729.4 h
heating.degree_minutes: "-1005.0 DM"
price_of_electricity.price_of_electricity: 32.0 öre/kWh
compressor.number_of_starts: '169.0 '
compressor.total_operating_time: 1260.0 h
compressor.of_which_hot_water: 138.0 h
compressor.current_compr_frequency: 118.0 Hz
brine_pump.brine_in: 2.6 °C
brine_pump.brine_out: "-5.6 °C"
brine_pump.brine_pump_speed: 100.0 %
heating_medium_pump.heat_medium_flow: 50.0 °C
heating_medium_pump.return_temp: 39.7 °C
heating_medium_pump.pump_speed_heating_medium: 30.0 %
```
The YAML output is for maximum readability, but `--json` is also available to get a more structured output.

## Development
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/ErikDeBruijn/niebe_uplink.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
