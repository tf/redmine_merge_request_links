# CHANGELOG

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
