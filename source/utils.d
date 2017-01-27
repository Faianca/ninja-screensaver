module utils;

import core.sys.posix.stdlib : exit;
import std.stdio : writeln;

void die(string message, int exitCode = -1) {
	writeln(message);
	exit(exitCode);
}
