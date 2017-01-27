module event.keyboard;

import x11.Xlib : Display, XEvent, XKeyEvent;
import password;

class Keyboard
{
	Display* dpy;
	string passwd;
	PasswordHandler handler;

	this(Display* dpy)
	{
		this.handler = new PasswordHandler();
		this.dpy = dpy;
	}

	void grab()
	{
		XGrabKeyboard(
			this.dpy,
			DefaultRootWindow(this.dpy),
			True,
			GrabModeAsync,
			GrabModeAsync,
			CurrentTime
		);
	}

	void listen(XEvent ev)
	{
		XKeyEvent *e;
		e = &ev.xkey;
		switch (ev.type) {
			case KeyPress:
				this.keypress(&ev);
			break;
			case KeyRelease:
			case MotionNotify:
			case ConfigureNotify:
			default:
			break;
		}
	}

	void keypress(XEvent *e)
	{
		import std.array;

		auto keysym = this.getKeysym(&e.xkey);
		switch(keysym) {
			case XK_Pause:
				disableSlack = true;
			case XK_BackSpace:
				if (!this.passwd.empty) {
					this.passwd.popBack();
				}
			break;
			case XK_Return:
				/*writeln(this.passwd);*/
				bool valid = handler.isValid(this.passwd);
				writeln(valid);
				if (valid) {
					AppDisplay.instance().running = false;
				} else {
				  takeWebcamShot();
				}
				this.passwd = "";
			break;
			default:
				this.passwd ~= this.getKeyName(keysym);
			break;
		}
	}

	KeySym getKeysym(XKeyEvent *e)
	{
		return XKeycodeToKeysym(this.dpy, cast(KeyCode)e.keycode, 0);
	}

	string getKeyName(XKeyEvent *e)
	{
		return to!string(XKeysymToString(this.getKeysym(e)));
	}

	string getKeyName(KeySym keysym)
	{
		return to!string(XKeysymToString(keysym));
	}

}
