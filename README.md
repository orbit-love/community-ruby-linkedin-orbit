# LinkedIn to Orbit Workspace Ruby App

![Build Status](https://github.com/orbit-love/community-ruby-linkedin-orbit/workflows/CI/badge.svg)
[![Gem Version](https://badge.fury.io/rb/linkedin_orbit.svg)](https://badge.fury.io/rb/dev_orbit)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-4baaaa.svg)](code_of_conduct.md)

This is a Ruby app that can be used to integrate LinkedIn post comments into your organization's Orbit workspace.

|<p align="left">:sparkles:</p> This is a *community project*. The Orbit team does its best to maintain it and keep it up to date with any recent API changes.<br/><br/>We welcome community contributions to make sure that it stays current. <p align="right">:sparkles:</p>|
|-----------------------------------------|

![There are three ways to use this integration. Install package - build and run your own applications. Run the CLI - run on-demand directly from your terminal. Schedule an automation with GitHub - get started in minutes - no coding required](readme_images/ways-to-use.png)
## First Time Setup

To set up this integration you will need to follow some steps required by LinkedIn. Please follow the [First Time Setup guide](docs/FIRST_TIME_INSTRUCTIONS.md) for step-by-step instructions.

## Application Credentials

The application requires the following environment variables:

| Variable | Description | More Info
|---|---|--|
| `LINKEDIN_CODE` | LinkedIn Browser Refresh Code | [LinkedIn Docs](https://docs.microsoft.com/en-us/linkedin/shared/authentication/authorization-code-flow)
| `LINKEDIN_ORGANIZATION` | LinkedIn Organization Page ID | Format: `urn:li:organization:#{id}`. ID is the set of numbers in LinkedIn page URL, i.e. `https://www.linkedin.com/company/28866695`, the ID is `28866695`.
| `ORBIT_API_KEY` | API key for Orbit | Found in `Account Settings` in your Orbit workspace
| `ORBIT_WORKSPACE_ID` | ID for your Orbit workspace | Last part of the Orbit workspace URL, i.e. `https://app.orbit.love/my-workspace`, the ID is `my-workspace`

## Package Usage

To install this integration in a standalone app, add the gem to your `Gemfile`:

```ruby
gem "linkedin_orbit"
```

Then, run `bundle install` from your terminal.

You can instantiate a client by either passing in the required credentials during instantiation or by providing them in your `.env` file.

### Instantiation with credentials:

```ruby
client = LinkedinOrbit::Client.new(
    orbit_api_key: YOUR_API_KEY,
    orbit_workspace_id: YOUR_ORBIT_WORKSPACE_ID,
    linkedin_code: YOUR_LINKEDIN_BROWSER_REFRESH_CODE,
    linkedin_organization: YOUR_LINKEDIN_ORGANIZATION_ID
)
```

### Instantiation with credentials in dotenv file:

```ruby
client = LinkedinOrbit::Client.new
```

### Fetching LinkedIn Comments

Once, you have an instantiated client, you can fetch LinkedIn comments on your organization's posts and send them to Orbit by invoking the `#comments` instance method:

```ruby
client.comments
```
## CLI Usage

You can also use this package with the included CLI. To use the CLI pass in the required environment variables on the command line before invoking the CLI:

```bash
$ ORBIT_API_KEY=... ORBIT_WORKSPACE_ID=... LINKEDIN_CODE=... LINKEDIN_ORGANIZATION=... bundle exec linkedin_orbit --check_comments
```
## GitHub Actions Automation Setup

⚡ You can set up this integration in a matter of minutes using our GitHub Actions template. It will run regularly to add new activities to your Orbit workspace. All you need is a GitHub account.

[See our guide for setting up this automation](https://github.com/orbit-love/github-actions-templates/blob/main/LinkedIn/README.md).
## Contributing

We 💜 contributions from everyone! Check out the [Contributing Guidelines](.github/CONTRIBUTING.md) for more information.

## License

This is available as open source under the terms of the [MIT License](LICENSE).

## Code of Conduct

This project uses the [Contributor Code of Conduct](.github/CODE_OF_CONDUCT.md). We ask everyone to please adhere by its guidelines.
