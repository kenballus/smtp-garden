"""
# Reserved for future use
config.binding = {
 "aiosmtpd": "2501",
 "courier": "2502",
 "courier-msa": "2601",
 "dovecot": "2401",
 "echo": "25",
 "exim": "2503",
 "james": "2504",
 "msmtp": "2505",
 "nullmailer": "2507",
 "opensmtpd": "2508",
 "postfix": "2509",
 "sendmail": "2510"
}
"""

# Use python syntax for dictionaries, i.e.:
#   "key": [List of string values]
# Nesting keys and functions works, too.
# Just make sure any dependencies get imported.
config.grammar = {
 "__SOURCE__": ["validator@__SOURCEPEER__.smtp.garden"],
 "__SOURCEPEER__": ["validator"],
 "__DEST__": ["__USER__@__HOST__"],
 "__USER__": ["user1", "user2", "nouser"],
 "__HOST__": ["__PEER__.smtp.garden"],
 "__DATE__": [f"{datetime.datetime.now()}"],
 "__PEER__": [
  "aiosmtpd",
  "courier",
  "courier-msa",
  "dovecot",
  "echo",
  "exim",
  "james",
  "msmtp",
  "nullmailer",
  "opensmtpd",
  "postfix",
  "sendmail",
  "UNKNOWN"
 ]
}
