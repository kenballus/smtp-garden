## Alternative James Image: Custom Maildir delivery

This image is based off the `james` image, originally from commit 669db6a.  See [james](../james/) image for configuration details.

This image *should* generally track the `james` image configuration, but it must be manually updated (see "Future Work").  This README contains only specifics regarding custom Maildir functionality.

Two components have been added, contained in the [maildir-utils](maildir-utils/) directory.
- [ToMaildir.java](maildir-utils/ToMaildir.java) is a custom mailet.  Notes:
  - For each local recipient, it send email in text format to a delivery script
  - Defaults to `/app/localdelivery.sh` but this can be overridden in `mailetcontainer.xml`.
  - Respects `passThrough` setting.
  - Utilizes James' native logging mechanism.
  - The Docker build file places this Java class in the project source tree for compilation with the rest of the project
    - Maven requires disabling style checker for this
  - Future maintenance may include:
    - Modularizing the Java class, so it can be modified without rebuilding the entire project (slow, inconvenient)
    - Replacing the custom delivery script target with another subject program (such as procmail) for testing.
- [localdelivery.sh](maildir-utils/localdelivery.sh) script is a custom shell script to enable Maildir delivery. Notes:
  - Receives the email via `stdin`,
  - Saves it under a unique file name (with a lock, to prevent races),
  - Backs up any existing files in case of name collision (unlikely).
- Strictly speaking, together these represent a convenience mechanism for output collection.  As such:
  - They have __not__ been comprehensively tested, use at your own risk.
  - Message delivery to James `inbox` has been preserved for confirmation of any anomalous output.
- `mailetcontainer.xml` has also been modified accordingly.

## Future Work
- With minimal adaptation, this image may serve as a basis for other James variants which could employ procmail, maildrop, fdm, or other test subject tools, as needed.
- Modularization of the custom Java class, so it can be built independently of the main project.  This would enable "drop in" support, improving the development-testing cycle

