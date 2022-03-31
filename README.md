# ⛔️ DEPRECATED: LinkedIn to Orbit Workspace Ruby App

This repository is no longer recommended or maintained and it will soon be marked as archived in Github. Huge thanks to the original authors and contributors for providing this Github Actions template to our community. To add LinkedIn interactions to your Orbit workspace, you can now request access to the Linkedin integration under `Workspace Settings > Integrations`. 

---

![Build Status](https://github.com/orbit-love/community-ruby-linkedin-orbit/workflows/CI/badge.svg)
[![Gem Version](https://badge.fury.io/rb/linkedin_orbit.svg)](https://badge.fury.io/rb/dev_orbit)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-4baaaa.svg)](code_of_conduct.md)

Add your LinkedIn interactions into your Orbit workspace with this community-built integration.

![New LinkedIn post comment in Orbit screenshot](readme_images/new-comment-screenshot.png)

|<p align="left">:sparkles:</p> This is a *community project*. The Orbit team does its best to maintain it and keep it up to date with any recent API changes.<br/><br/>We welcome community contributions to make sure that it stays current. <p align="right">:sparkles:</p>|
|-----------------------------------------|

![There are three ways to use this integration. Install package - build and run your own applications. Run the CLI - run on-demand directly from your terminal. Schedule an automation with GitHub - get started in minutes - no coding required](readme_images/ways-to-use.png)
## First Time Setup

To set up this integration you will need to follow some steps required by LinkedIn. Please follow the [First Time Setup guide](docs/FIRST_TIME_INSTRUCTIONS.md) for step-by-step instructions.

## Application Credentials

The application requires the following environment variables:

| Variable | Description | More Info
|---|---|--|
| `LINKEDIN_TOKEN` | LinkedIn Token | Follow the [First Time Setup guide](docs/FIRST_TIME_INSTRUCTIONS.md) to obtain the token
| `LINKEDIN_ORGANIZATION` | LinkedIn Organization Page ID | Format: `urn:li:organization:#{id}`, where `id` is the set of numbers in the LinkedIn page URL, i.e. `https://www.linkedin.com/company/28866695`, the `id` is `28866695`.
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
    linkedin_token: YOUR_LINKEDIN_TOKEN,
    linkedin_organization: YOUR_LINKEDIN_ORGANIZATION_ID
)
```

### Instantiation with credentials in dotenv file:

```ruby
client = LinkedinOrbit::Client.new
```

### Performing a Historical Import

You may want to perform a one-time historical import to fetch all your previous LinkedIn interactions and bring them into your Orbit workspace. To do so, instantiate your `client` with the `historical_import` flag:

```ruby
client = LinkedinOrbit::Client.new(
  historical_import: true
)
```

### Fetching LinkedIn Comments

**The API token owner must be an admin on the LinkedIn organization's page in order to fetch comments. Please ask the manager of your LinkedIn page to grant admin status to your account before attempting to fetch comments.**

Once, you have an instantiated client, you can fetch LinkedIn comments on your organization's posts and send them to Orbit by invoking the `#comments` instance method:

```ruby
client.comments
```
## CLI Usage

You can also use this package with the included CLI. To use the CLI pass in the required environment variables on the command line before invoking the CLI:

```bash
$ ORBIT_API_KEY=... ORBIT_WORKSPACE_ID=... LINKEDIN_TOKEN=... LINKEDIN_ORGANIZATION=... bundle exec linkedin_orbit --check_comments
```

**Add the `--historical-import` flag to your CLI command to perform a historical import of all your LinkedIn interactions using the CLI.**
## GitHub Actions Automation Setup

⚡ You can set up this integration in a matter of minutes using our GitHub Actions template. It will run regularly to add new activities to your Orbit workspace. All you need is a GitHub account.

[See our guide for setting up this automation](https://github.com/orbit-love/github-actions-templates/blob/main/LinkedIn/README.md).
## Contributing

We 💜 contributions from everyone! Check out the [Contributing Guidelines](.github/CONTRIBUTING.md) for more information.

## License

This is available as open source under the terms of the [MIT License](LICENSE).

## Code of Conduct

This project uses the [Contributor Code of Conduct](.github/CODE_OF_CONDUCT.md). We ask everyone to please adhere by its guidelines.
