# Redmine Merge Request Links

[![Build Status](https://travis-ci.org/tf/redmine_merge_request_links.svg?branch=master)](https://travis-ci.org/tf/redmine_merge_request_links)

Display links to associated merge requests and pull requests on Redmine's issue page.

Intercepts webhooks and parses merge request descriptions for mentioned issue ids.

The following platforms are supported:

* GitHub
* GitLab
* Gitea


## Requirements

* Redmine 3 (tested with 3.4.6)

## Installation

Copy plugin directoy to `{RAILS_APP}/plugins` on your Redmine
path. Run plugin migrations from your redmine root directory:

```bash
$ rake redmine:plugins:migrate RAILS_ENV=production
```

This plugin requires an additional view hook which can be added by
applying a patch to your Redmine instance. From your Redmine path run:

```bash
$ git apply plugins/redmine_merge_request_links/patches/view_hook_issues_show_after_details_redmine_3.4.patch
```

One of the following environment variables need to be set:

* `REDMINE_MERGE_REQUEST_LINKS_GITEA_WEBHOOK_TOKEN`
* `REDMINE_MERGE_REQUEST_LINKS_GITLAB_WEBHOOK_TOKEN`
* `REDMINE_MERGE_REQUEST_LINKS_GITHUB_WEBHOOK_TOKEN`

They must contain secrets which have to be configured in GitLab/GitHub/Gitea to authenticate webhooks.

Export the environment variable(s) in your bash or webserver config.
Examples with Phusion Passenger webserver can be found here:
https://www.phusionpassenger.com/library/indepth/environment_variables.html

Finally, restart your webserver.


## Configuration

Create a webhook in GitLab, Gitea or GitHub as described here:

### GitLab

* Go to either the webhook page of a project (Settings > Integration)
  or the system hook page (Admin area > System Hooks).

* Enter the URL of your Redmine instance
  `http://redmine.example.com/merge_requests/event`

* Enter the secret token you defined in environment variable
  `REDMINE_MERGE_REQUEST_LINKS_GITLAB_WEBHOOK_TOKEN`

* Check the "Merge request events" trigger.

* Click "Add webhook".

### GitHub

* Go to the webhook page of a project or organization.

* Enter the URL of your Redmine instance
  `https://redmine.example.com/merge_requests/event`.

* Select `application/json` as content type.

* Enter the secret token you defined in environment variable
  `REDMINE_MERGE_REQUEST_LINKS_GITHUB_WEBHOOK_TOKEN`.

* Choose "Let me select individual events".

* Check the "Pull requests" event.

* Click "Add webhook".

### Gitea

* Go to the webhook page of a project or organization.

* Enter the URL of your Redmine instance
  `https://redmine.example.com/merge_requests/event`.

* Select `application/json` as content type.

* Enter the secret token you defined in environment variable
  `REDMINE_MERGE_REQUEST_LINKS_GITEA_WEBHOOK_TOKEN`.

* Choose "Custom events...".

* Check the "Pull requests" event.

* Click "Add webhook".

### Redmine

To display associated merge requests on issue pages:

* Add the "View associated merge requests" permission to one or more
  roles.

* Enable the "Merge request links" project module.


## Usage

Create a merge request and reference a Redmine issue either in the
form `#123` or `REDMINE-123`. See a link to the merge request appear
on the issue's Redmine page.


## Known Issues

* GitLab only passes the author id as part of the merge request
  webhook not a display name. It does include the username of the user
  whose action triggered the webhook, though. To prevent having to
  fetch the author name in a separate REST API call, this username is
  used as author name since the user triggering a merge request's
  first webhook is usually the author. For merge request that were
  created before the plugin was installed, this causes the first user
  to edit the merge request to be recorded as the author.


## Development

After checking out the repository, run

```
$ bin/build
```

to build the Docker container used to run the test suite.

Then run

```
$ bin/test
```

to run the test suite inside a Docker container.

### Adding new providers

If you want to add a new provider please add the following components tailored to the provider:
 
* lib/redmine_merge_request_links/event_handlers/<provider_name>.rb: Verify that request should be processed by event handler. Verify that request and token is valid
* lib/redmine_merge_request_links.rb: Register new provider by adding a new environment variable and instantiate the class
* assets/images/: Add logo (preferably SVG file) for new provider
* assets/stylesheets/redmine_merge_request_links.css: Add new CSS class for logo

Feel free to look at the existing providers as a reference of implementation.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
