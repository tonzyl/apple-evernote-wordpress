# apple-evernote-wordpress
Applescript to publish from Evernote to Wordpress

This Applescript:
<ol>
<li>gets a list of notes from Evernote, specified by notebook and date range
<li>takes title, source URL, tags and first line
<li>makes a list of all tags used, of all used once, and all used more than once
<li>builds a posting titled Suggested Read: tag1, tag2, tag3 and more
<li>makes an UL with LI for each evernote note [first line]: [title] linked to [source]
<li>mails the posting to Postie Wordpress plugin, using Mail
<li>so that the posting is scheduled in 24 hours, allowing time to review
<li>but will autopost without review.
</ol>
