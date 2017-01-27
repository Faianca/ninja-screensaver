module password;

import core.sys.posix.pwd;
import cinterface;
import utils;
import core.sys.posix.unistd : getuid, geteuid, getegid, setgid, setuid;
import std.process;

alias Password = passwd*;

class PasswordHandler
{
	import std.string : toStringz;
	private char* userPassword;

	private char* getPassword() {
		if (this.userPassword) {
			return userPassword;
		}

		Password pw;
		pw = getpwuid(getuid());

		if (!pw) {
			die("Cannot retrieve password entry (make sure to suid or sgid slock)");
		}

		auto rval = pw.pw_passwd;
		endpwent();

		if (rval[0] == 'x' && rval[1] == '\0') {
			spwd* sp;
			auto user = environment.get("USER");
			sp = getspnam(user.toStringz());

			if(!sp) {
				die("cannot retrieve shadow entry (make sure to suid or sgid slock)");
			}

			endspent();
			rval = sp.sp_pwdp;
		}

		// drop privileges
		if (geteuid() == 0 && ((getegid() != pw.pw_gid && setgid(pw.pw_gid) < 0) || setuid(pw.pw_uid) < 0)) {
			die("cannot drop privileges\n");
		}

		this.userPassword = rval;

		return rval;
	}

	bool isValid(string password) {
		import std.conv : to;
		auto parsed = toStringz(password);
		auto crypted = crypt(parsed, this.getPassword());
		return (to!string(crypted) == to!string(this.getPassword()));
	}
}
