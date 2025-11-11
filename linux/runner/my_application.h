#ifndef FLUTTER_MY_APPLICATION_H_
#define FLUTTER_MY_APPLICATION_H_

#include <gtk/gtk.h>

G_DECLARE_FINAL_TYPE(MyApplication, my_application, MY, APPLICATION,
                     GtkApplication)

// GTK 기반 Flutter 앱 인스턴스를 생성한다.
MyApplication* my_application_new();

#endif  // FLUTTER_MY_APPLICATION_H_
