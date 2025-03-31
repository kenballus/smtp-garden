## Validation

- The following basic functionalities of SMTP Garden should be validated prior to formal testing of garden servers:
  - Routing functionality between all peers
  - Local Maildir delivery, for supporting servers
- The `gen.py` script and associated files (`config.py` and `template.txt`) can be used to automatically generate testing payloads.
  - Script tested under Python 3.10.12 and 3.13.2, and it should work on >=3.9
  - Be careful which folder you run it in, it is capable of generating a __lot__ of files.
  - Filenames are of format: `test_"source host"_"target host"_"username".txt`
  - The config file maps `__SOURCEPEER__` to source host, `__PEER__` to target host, and `__USER__` to username, but feel free to modify.
  - Want to change the filename format?  See `filename` in `TokenTree.self_to_file()` method.
  - a separate `template-dovecot.txt` file, provided, may be used for testing Dovecot MSA, which requires `AUTH`
- Batch send the payload files to the SMTP Garden, then:
  - Verify expected number of Maildir products,
  - Verify echo server outputs,
  - Gather header differentials, necessary to screen out false-positive diffs.

Example usages:
```
# Test one server at a time, given by $PORT_NUM, for delivery to itself and to all peers:
$ python gen.py [options]
$ for file in $(ls test*.txt); do ../sendmsg.py $file $PORT_NUM; done


# Test Dovecot MSA, which requires AUTH line:
$ python gen.py -t template-dovecot.txt --assign __SOURCEPEER__="['auth']"
$ for file in $(ls test_auth*.txt); do ../sendmsg.py $file 2602; done

# NOTE: --assign uses '=' instead of ':' (the standard python key-value separator)

```
These two examples each test one server at a time (given by $PORT_NUM) for delivery to itself and to all peers.

__WARNING__: Script does not sanitize any inputs.
