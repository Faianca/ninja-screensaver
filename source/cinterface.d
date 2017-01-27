module cinterface;

import core.sys.posix.unistd;

extern (C):
	char *crypt(const char *key, const char *salt);

	spwd *getspnam(const char *name);

	void endspent();

	struct spwd
	  {
	    char *sp_namp;
	    char *sp_pwdp;
	    long sp_lstchg;
	    long sp_min;
	    long sp_max;
	    long sp_warn;
	    long sp_inact;
	    long sp_expire;
	    ulong sp_flag;
	  };
