module event.event;

import x11.Xlib : XEvent;

interface EventListener
{
	void listen(XEvent ev);
}
