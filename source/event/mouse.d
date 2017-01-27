module event.mouse;

class Mouse
{
	Display* dpy;

	this(Display* dpy)
	{
		this.dpy = dpy;
	}

	void grab()
	{
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
			case ButtonPress:
				XButtonPressedEvent *me = &ev.xbutton;
				//takeWebcamShot();
				break;
			case ButtonRelease:
			default:
			break;
		}
	}
}
