import std.stdio;
import x11.Xlib_xcb;
import x11.Xlib;
import x11.Xutil;
import x11.Xatom;
import x11.Xlib;
import x11.X;
import x11.keysym;
import x11.keysymdef;

import std.conv : to;
import display;
import cinterface;
import utils : die;
import password;
import std.string;
import std.process;
import std.datetime;

bool disableSlack = false;
int timeToTakeScreenShot = 5;
SysTime lastTimeTooked;

void main() {
	import std.conv;
	auto nscreens = AppDisplay.instance().getScreenNumber();
	lastTimeTooked = Clock.currTime;
	run();
	AppDisplay.instance().quit();
}

void run()
{
	extern(C) __gshared XEvent ev;

	XSync(AppDisplay.instance().dpy, false);

	auto dpy = AppDisplay.instance().dpy;
	auto keyboard = new Keyboard(dpy);
	keyboard.grab();

	/* main event loop */
	/*while(AppDisplay.instance().running && !XNextEvent(dpy, &ev)) {
		keyboard.listen(ev);
	}*/
}

enum BUTTONMASK = ButtonPressMask | ButtonReleaseMask;
enum MOUSEMASK = ButtonPressMask | ButtonReleaseMask | PointerMotionMask;

string getImageName()
{
	import std.string : format;
	return format(
		"ffmpeg -y -loglevel quiet -f video4linux2 -i /dev/video0 -f image2 %s/patinhos/opatocuscovilheiro.jpg",
		environment.get("HOME")
	);
}

void sendToSlack()
{
	import std.string : format;
	string slackCommand = format(
		"SLACK_TOKEN=%s slackcat -c aiquepatinho -m %s/patinhos/opatocuscovilheiro.jpg -i 'Mexe Mexe depois choras' ",
		environment.get("SLACK_TOKEN"), environment.get("HOME")
	);
	auto sc = executeShell(slackCommand);
	if (sc.status != 0) writeln("Failed to send to slack");
}

void takeWebcamShot()
{
	if (lastTimeTooked < Clock.currTime) {
		auto ls = executeShell(getImageName());
		if (!disableSlack) {
			sendToSlack();
		}
		lastTimeTooked += dur!"seconds"(timeToTakeScreenShot);
	}
}

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

		XGrabButton(
			this.dpy,
			AnyButton,
			AnyModifier,
			DefaultRootWindow(this.dpy),
			false,
			BUTTONMASK,
			GrabModeAsync,
			GrabModeSync,
			None,
			None
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
			case ButtonPress:
				XButtonPressedEvent *me = &ev.xbutton;
				//takeWebcamShot();
				break;
			case ButtonRelease:
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


void waitForKeyboard() {

}
