## Key configuration items

- Main files in: [/app/james/conf/](conf)
  - Contents collected from https://github.com/apache/james-project/tree/master/examples
  - Key files:
    - [conf/mailetcontainer.xml](conf/mailetcontainer.xml) : defines mailets (like servelets, but for mail). Chained "processors" for the transport pipeline (see below)
    - [conf/smtpserver.xml](conf/smtpserver.xml) : socket bindings, greeting message
  - [conf/keystore](conf/keystore) : generated file, expected by James to match fields in smtpserver.xml (would be nice to remove this if not truly required.)

- Transport pipeline:
  - `root` processor immediately passes valid mail to `transport` processor
  - `transport` removes MIME headers (James complains otherwise), then forwards to the `relay` processor
  - `relay` attaches arguments necessary for the `RemoteDelivery` class to relay the mail

- HELO name: \<heloName\> field (`relay` processor, [conf/mailetcontainer.xml](conf/mailetcontainer.xml))
- Target relay host: \<gateway\> field (`relay` processor, [conf/smtpserver.xml](conf/smtpserver.xml))
