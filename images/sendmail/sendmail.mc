divert(-1)
#
# Copyright (c) 1998, 1999 Proofpoint, Inc. and its suppliers.
#       All rights reserved.
# Copyright (c) 1983 Eric P. Allman.  All rights reserved.
# Copyright (c) 1988, 1993
#       The Regents of the University of California.  All rights reserved.
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the sendmail distribution.
#
#

#
#  This is a generic configuration file for Linux.
#  It has support for local and SMTP mail only.  If you want to
#  customize it, copy it to a name appropriate for your environment
#  and do the modifications there.
#

divert(0)dnl
VERSIONID(`$Id: generic-linux.mc,v 8.2 2013-11-22 20:51:08 ca Exp $')
OSTYPE(linux)dnl
DOMAIN(generic)dnl

dnl Commented out until procmail or similar is enabled
dnl FEATURE(`maildir')dnl

# Added by smtp-garden
define(`confTRY_NULL_MX_LIST', `true')dnl
define(confHELO_NAME,`sendmail.smtp.garden')dnl

FEATURE(`promiscuous_relay')dnl
FEATURE(`nocanonify')dnl
FEATURE(`accept_unqualified_senders')dnl
FEATURE(`mailertable', `hash /etc/mail/mailertable')dnl
dnl FEATURE(`accept_unresolvable_domains')dnl

define(`SMART_HOST', `smtp:[__RELAYHOST__]')dnl
define(`confBIND_OPTS', `-DNSRCH -DEFNAMES')dnl
MAILER(local)dnl
MAILER(smtp)dnl
