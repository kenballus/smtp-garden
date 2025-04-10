import argparse
import copy
import datetime
from os.path import isfile
from itertools import starmap

SILENT=0
INFO=1
VERBOSE=2
DEBUG=3

""" Titrates screen output """
class Verbosity:
    def __init__(self, level: int) -> None:
        assert level >= SILENT and level <= DEBUG, f"Bad verbosity number set. Must be {SILENT}-{DEBUG}"
        self.level = level
        self.prefix = ["[WARN] ", "[INFO] ", "[INFO] ", "[DEBUG] "]

    def reset(self, level: int) -> None:
        assert level >= SILENT and level <= DEBUG, f"Bad verbosity number reset. Must be {SILENT}-{DEBUG}"
        self.level = level

    def vprint(self, level: int, msg: str, pref=True, vend="\n") -> None:
        if level <= self.level:
            assert level >= SILENT and level <= DEBUG, f"Bad verbosity number referenced. Must be {SILENT}-{DEBUG}"
            prefix = self.prefix[level] if pref else ""
            print(f"{prefix}{msg}", end=vend)

""" Support dictionary update with command line args """
""" The string after the split should translate into a list of strings """
class kwargs_add_dict(argparse.Action):
    def __call__(self, parser, args, values, option_string=None):

        def extract_list_from_tuple(k, v_list):
            return k, eval(v_list)

        existing = getattr(args, self.dest, None) or {}
        try:
            m = map(lambda x: x.split("="), values)
            d = dict( starmap(extract_list_from_tuple, m) )
        except ValueError as e:
            raise argparse.ArgumentError(self, f"Bad key-value pair in {values}.")
        setattr(args, self.dest, existing | d)

""" Tree creation/output for template-based permutations """
class TokenTree:
    """ Recursively generates permutations of the template """
    def __init__(self,
                 parent,
                 template: list[str],
                 tokens: dict,
                 list_target: int) -> None:
        # Establish ancestry, metadata record, & depth
        self.children: list = []
        self.parent = parent
        if self.parent is not None:
            self.depth = self.parent.depth + 1
            self.replaced_tokens = copy.deepcopy(parent.getreplaced_tokens())
        else:
            self.depth = 0
            self.replaced_tokens = {}

        # Build this node's template and history metadata
        self.tokens = []        
        self.repl, *self.remaining_keys = tokens
        self.template: list[str] = []
        self.replaced_tokens[self.repl] = tokens[self.repl][list_target]
        for line in template:
            self.template.append(line.replace(self.repl, tokens[self.repl][list_target]))
        if len(self.remaining_keys) == 0:
            return

        # Generate new token dictionary
        self.tokens = { key: tokens[key] for key in self.remaining_keys }

        # Create this node's children
        for i in range(0, len(self.tokens[self.remaining_keys[0]])):
            self.children.append(TokenTree(self, self.template, self.tokens, i))

    def getreplaced_tokens(self) -> list:
        return self.replaced_tokens

    def get_branch_products(self) -> list:
        textlist = []
        if len(self.children) == 0:
            textlist.append(self.template)
        else:
            for child in self.children:
                textlist += child.get_branch_products()
        return textlist

    """ returns tuple of count of files created, attempted """
    def self_to_file(self) -> (int, int):
        filename = f"test_{self.replaced_tokens['__PRIMARY__']}_{self.replaced_tokens['__PEER__']}_{self.replaced_tokens['__USER__']}.txt"
        v.vprint(VERBOSE, f"TokenTree: writing to file {filename}...", vend="")
        if len(self.children) != 0:
            v.vprint(VERBOSE, "node has children, skipping.", pref=False)
            return 0,0
        if isfile(filename):
            v.vprint(VERBOSE, "already exists, trying modifying name: ", pref=False, vend="")
            while True:
                #assert len(filename) < 254, "filename got too long, aborting"
                if len(filename) > 254:
                    v.vprint(VERBOSE, "filename got too long, skipping. Please clean your folder.", pref=False)
                    return 0,1
                v.vprint(VERBOSE, "_", pref=False, vend="")
                filename = filename[:-4] + "_.txt"
                if not isfile(filename):
                    v.vprint(VERBOSE, ", ", pref=False, vend="")
                    break
        with open(filename, "x") as fout:
            for line in self.template:
                fout.write(line + '\n')
        v.vprint(VERBOSE, "done.", pref=False)
        return 1,1

    """ returns tuple of cumulative count of files created, attempted """
    def branch_products_to_files(self) -> (int,int):
        if len(self.children) == 0:
            return self.self_to_file()
        else:
            a, b = 0, 0
            created, tried = 0, 0
            for child in self.children:
                a, b = child.branch_products_to_files()
                created += a
                tried += b
            return created, tried

""" Load/manage template and configuration files """
class Templator:

    required: list[str] = ["grammar"]
    template_lines: list[str] = []

    def __init__(self,
                 conf_file: str,
                 template_file: str) -> None:
        assert isfile(conf_file), f"Config file not found: {conf_file}, aborting."
        assert isfile(template_file), f"Template file not found: {template_file}, aborting."

        v.vprint(DEBUG, f"Templator: opening config file {conf_file}...", vend="")
        with open(conf_file, "r") as conf_fd:
            conf_data = conf_fd.read().replace("config.", "self.")
        exec(conf_data)
        for var in self.required:
            assert var in self.__dict__, f"Missing {var} in {self.conf_file}, aborting"
        v.vprint(DEBUG, "OK", pref=False)

        v.vprint(DEBUG, f"Templator: opening template file {template_file}...", vend="")
        with open(template_file, "r") as template:
            for line in template:
                self.template_lines.append(line[:-1])
        v.vprint(DEBUG, f"OK", pref=False)

    def custom_kvargs(self, d) -> None:
        v.vprint(VERBOSE, f"Templator: adding custom dictionary.")
        v.vprint(DEBUG, d)
        self.grammar = self.grammar | d

    def print_template(self) -> None:
        v.vprint(VERBOSE, f"{len(self.template_lines)} lines long.")
        i = 0
        for line in self.template_lines:
            v.vprint(SILENT, f"Line {i:02d}: {line}", pref=False)
            i += 1


""" Main """
""" Lazily avoiding a main method, to preserve v.vprint() calls by other classes """
if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        description = "Generates a payload library, based on the grammar given in config.py, applied to the contents of ./template.txt",
        epilog = "Intended for establishing correct configuration of SMTP Garden Maildir and peer SMTP routing."
    )

    parser.add_argument("-c", "--config-file",
                        help="Defaults to \"config.py\"",
                        default="config.py")
    parser.add_argument("-t", "--template-file",
                        help="Defaults to \"template.txt\"",
                        default="template.txt")
    parser.add_argument("-s", "--silent",
                        help="silences all non-error output (overridden by -v or -d)",
                        action="store_true")
    parser.add_argument("-v", "--verbose",
                        help="increased verbosity (overrides -s)",
                        action="store_true")
    parser.add_argument("-d", "--debug",
                        help="debug output (overrides -v, -s)",
                        action="store_true")
    parser.add_argument("--assign",
                        help="Manually set/override config entries, i.e. --set __USER__=\"['me', 'us']\" __PEER__=\"['sendmail']\". Use care to enclose list of strings in quotes.  Any pre-existing keys in CONFIG_FILE have all pre-existing values replaced.  Option may appear more than once.",
                        action=kwargs_add_dict,
                        required=False,
                        nargs="*",
                        metavar="KEY=VALUE")
    args = parser.parse_args()

    # debug overrides verbose overrides silent overrides default:
    output_level = 3 if args.debug else 2 if args.verbose else 0 if args.silent else 1    
    v = Verbosity(output_level)

    v.vprint(DEBUG, f"Main: Output level = {output_level}")
    v.vprint(DEBUG, f"Main: Config file = {args.config_file}")
    v.vprint(DEBUG, f"Main: Template file = {args.template_file}")
    v.vprint(DEBUG, f"Main: override entries = {args.assign}")

    v.vprint(VERBOSE, f"Main: loading template and configuration.")
    master_template = Templator(args.config_file, args.template_file)

    if args.assign is not None:
        v.vprint(VERBOSE, f"Main: applying custom key-values to template.")
        master_template.custom_kvargs(args.assign)

    v.vprint(DEBUG, "Main: working dictionary:")
    v.vprint(DEBUG, master_template.grammar)

    v.vprint(VERBOSE, f"Main: Generating payloads...")
    newtree = TokenTree(None, master_template.template_lines, master_template.grammar, 0)
    created, tried = newtree.branch_products_to_files()
    v.vprint(INFO, f"Main: Created total {created} of {tried} payloads.")


