FROM redmine:3.4.6

COPY patches/view_hook_issues_show_after_details.patch /
RUN git apply /view_hook_issues_show_after_details.patch

RUN apt-get update \
    && apt-get install -y build-essential \
    && bundle install --with test