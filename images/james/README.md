## Key configuration items

James is an enterprise application, with enterprise-scale configuration.
- Main config files are deployed to [/app/james/conf/](conf)
  - HELO name: \<heloName\> field (`relay` processor, [conf/mailetcontainer.xml](conf/mailetcontainer.xml))
  - Target relay host: \<gateway\> field (`relay` processor, [conf/smtpserver.xml](conf/smtpserver.xml))
  - Contents sourced/edited from various Apache James resource sites
- Key modifications:
  - [conf/mailetcontainer.xml](conf/mailetcontainer.xml) : defines mailets (like servelets, but for mail). These are chained "processors" for the transport pipeline (see below).
  - [conf/smtpserver.xml](conf/smtpserver.xml) : socket bindings, greeting message.
  - [conf/activemq.properties](conf/activemq.properties) : seemingly necessary but not sufficient config for __disabling__ ActiveMQ metrics.
  - [conf/keystore](conf/keystore)
    - Generated file, expected by James to match fields in smtpserver.xml.
    - Everything may work fine without this, feel free to try without it.
    - Uses default passphrase "james72laBalle" (a default, legacy, James phrase).
- Other files from https://github.com/apache/james-project/tree/master/server/apps/spring-app/src/main/resources (especially James 3.8.1).
  - Many of them can be removed, but incorporating them silences nuisance console warnings.

## Transport pipeline:
- `root` processor immediately passes valid mail to `transport` processor.
- `transport` removes MIME headers (James complains otherwise), then forwards to the `relay` processor.
- `relay` attaches arguments necessary for the `RemoteDelivery` class to relay the mail.

## Alternate Versions

Three versions are provided: the standard Dockerfile, an alternate (minimalistic) config, and a "latest stable release."
- Use the "alternate config" Dockerfile if you prefer a configuration that is minimally different from the official examples. However:
  - It probably won't affect fuzzing behavior either way.
  - This generates overwhelming console spam due to ActiveMQ
  - These files are intended to be modified, not just used "off the shelf."
- Use the "fallback" Dockerfile for Apache James 3.8.1, the latest stable James release
  - Fetches .zip from official source release at [https://dlcdn.apache.org/james/server/3.8.1/james-project-3.8.1-source-release.zip](https://dlcdn.apache.org/james/server/3.8.1/james-project-3.8.1-source-release.zip).
  - See project homepage at [https://james.apache.org/download.cgi](https://james.apache.org/download.cgi) for other versions.
  - Note: builds with openjdk-11.  In contrast, current master is based on JRE 21, a substantial leap forward.
- An official Apache James image on Docker Hub, based on 3.6.1 also exists, and could also be tested.
