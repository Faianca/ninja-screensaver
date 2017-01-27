module display;

import x11.Xlib;

class AppDisplay
{
  Display *dpy;
  bool running = true;

  static AppDisplay instance()
  {
    if (!instantiated_) {
      synchronized {
        if (instance_ is null) {
          instance_ = new AppDisplay;
          instance_.dpy = XOpenDisplay(null);
        }
        instantiated_ = true;
      }
    }
    return instance_;
  }

  int getScreenNumber() {
	return ScreenCount(this.dpy);
  }

  void quit()
  {
     this.running = false;
  }

 private:
  this() {}
  static bool instantiated_;  // Thread local
  __gshared AppDisplay instance_;
 }
