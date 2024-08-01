## Key configuration items

- Main config files deployed to [/app/james/conf/](conf)
  - Contents sourced/edited from various Apache James resource sites
  - Key modifications:
    - [conf/mailetcontainer.xml](conf/mailetcontainer.xml) : defines mailets (like servelets, but for mail). These are chained "processors" for the transport pipeline (see below).
    - [conf/smtpserver.xml](conf/smtpserver.xml) : socket bindings, greeting message.
    - [conf/activemq.properties](conf/activemq.properties) : seemingly necessary but not sufficient config for disabling ActiveMQ metrics.
    - [conf/keystore](conf/keystore)
      - Generated file, expected by James to match fields in smtpserver.xml.
      - Everything may work fine without this.
      - Default passphrase is "james72laBalle" (a default, legacy, James phrase).
  - Other files from https://github.com/apache/james-project/tree/master/server/apps/spring-app/src/main/resources (especially James 3.8.1).
    - Many of them can be removed, but incorporating them silences nuisance console warnings.
  - If you want to maximally use the original _example_ config files from `james-project:master`, you can do so simply by uncommenting "Version B" lines in the docker file in lieu of "Version A."  This is not recommended because:
    - Doing so results in overwhelming spam to the console, mostly from metrics tracking.
    - These files are all meant to be further customized, not used "off the shelf," and it is burdensome to `sed` every single one.
    - The current files provided here in [conf/](conf) are sufficient and not likely to alter SMTP fuzzing behavior.
- Transport pipeline:
  - `root` processor immediately passes valid mail to `transport` processor.
  - `transport` removes MIME headers (James complains otherwise), then forwards to the `relay` processor.
  - `relay` attaches arguments necessary for the `RemoteDelivery` class to relay the mail.

- HELO name: \<heloName\> field (`relay` processor, [conf/mailetcontainer.xml](conf/mailetcontainer.xml))
- Target relay host: \<gateway\> field (`relay` processor, [conf/smtpserver.xml](conf/smtpserver.xml))

## Versions

- The fallback Dockerfile generates a (large, ~12gb) image based on Apache James 3.8.1, from the Apache official release source tarball.
  - Note: builds with openjdk-11.  In contrast, current master is based on JRE 21, a substantial leap forward.
- An official Apache James image on Docker Hub, based on 3.6.1 also exists, and could also be tested.
