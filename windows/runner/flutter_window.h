// FlutterView 를 호스팅하는 Win32 창 선언.
#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>

#include <memory>

#include "win32_window.h"

// Flutter 뷰만 호스팅하는 특수화된 Win32Window.
class FlutterWindow : public Win32Window {
 public:
  // 지정된 Flutter 프로젝트를 구동하는 창을 생성한다.
 explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window 오버라이드
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // 실행할 Flutter 프로젝트.
  flutter::DartProject project_;

  // 창 안에 호스팅되는 FlutterViewController 인스턴스.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
