
# Added by smtp-garden
define(`SMART_HOST', `smtp:__RELAYHOST__')dnl
define(confHELO_NAME,`smtp-garden-sendmail')dnl
FEATURE(`promiscuous_relay')dnl
FEATURE(`nocanonify')dnl
FEATURE(`accept_unqualified_senders')dnl
FEATURE(`accept_unresolvable_domains')dnl

