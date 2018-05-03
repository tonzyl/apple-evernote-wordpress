# apple-evernote-wordpress
Applescript to publish from Evernote to Wordpress

This Applescript:
1 gets a list of notes from Evernote, specified by notebook and date range
2 takes title, source URL, tags and first line
3 makes a list of all tags used, of all used once, and all used more than once
4 builds a posting titled Suggested Read: tag1, tag2, tag3 and more
5 makes an <UL> with <LI> for each evernote note [first line]: [title] linked to [source]
6 mails the posting to Postie Wordpress plugin, using Mail
7 so that the posting is scheduled in 24 hours, allowing time to review
8 but will autopost without review.
