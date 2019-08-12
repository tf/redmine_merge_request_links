# CHANGELOG

## Version 2.2

2019-08-12

- Gitea support
  ([#18](https://github.com/tf/redmine_merge_request_links/pull/18))

## Version 2.1.1

2018-09-26

- Ensure merged GitHub pull requests are displayed as `merged` not
  just `closed`.
  ([#10](https://github.com/tf/redmine_merge_request_links/pull/10))

## Version 2.1

2018-09-25

- Support Redmine issue links of the form `REDMINE-123`.
  ([#9](https://github.com/tf/redmine_merge_request_links/pull/9))

## Version 2.0

2018-09-20

- **Breaking Change:** Add project module and permission
  ([#8](https://github.com/tf/redmine_merge_request_links/pull/8),
   [#4](https://github.com/tf/redmine_merge_request_links/pull/4))

  The plugin can now be enabled on a per project basis. For a user to
  see associated merge requests on an issue page, you need to enable
  the "Merge request links" project module and add the "View
  associated merge requests" permission to one of their roles.

## Version 1.1

2018-09-20

- Also parse the pull request title.
- Do not associate issues multiple times that are mentioned more than
  once.
- Add German view translations.
  ([#3](https://github.com/tf/redmine_merge_request_links/pull/3))
- Improve install instructions
  ([#6](https://github.com/tf/redmine_merge_request_links/pull/6))

## Version 1.0.1

2018-09-12

- Handle issue ids at the beginning of description
- Do not update merge request author. Gitlab only reports the user
  whose action triggered the webhook. For new merge requests that is
  the author. Prevent overwriting the author when somebody else edits
  the merge request after.

## Version 1.0

2018-09-12

- Initial release
