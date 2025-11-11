// Win32 창 생성을 추상화한 공통 베이스 클래스 선언.
#ifndef RUNNER_WIN32_WINDOW_H_
#define RUNNER_WIN32_WINDOW_H_

#include <windows.h>

#include <functional>
#include <memory>
#include <string>

// 고해상도 Win32 창을 래핑하는 기본 클래스.
class Win32Window {
 public:
  struct Point {
    unsigned int x;
    unsigned int y;
    Point(unsigned int x, unsigned int y) : x(x), y(y) {}
  };

  struct Size {
    unsigned int width;
    unsigned int height;
    Size(unsigned int width, unsigned int height)
        : width(width), height(height) {}
  };

  Win32Window();
  virtual ~Win32Window();

  // 제목/위치/크기를 받아 창을 생성한다. Show 호출 전까지는 숨김 상태다.
  bool Create(const std::wstring& title, const Point& origin, const Size& size);

  // 현재 창을 화면에 표시한다.
  bool Show();

  // OS 자원을 해제하며 창을 파괴한다.
  void Destroy();

  // child 콘텐츠를 윈도우 트리에 주입한다.
  void SetChildContent(HWND content);

  // HWND 핸들을 반환하며, 파괴된 창이면 nullptr을 돌려준다.
  HWND GetHandle();

  // true면 창을 닫을 때 앱 전체를 종료한다.
  void SetQuitOnClose(bool quit_on_close);

  // 현재 클라이언트 영역 사각형을 반환한다.
  RECT GetClientArea();

 protected:
  // 마우스/크기/DPI 관련 메시지를 처리한 뒤 하위 클래스 훅으로 위임한다.
  virtual LRESULT MessageHandler(HWND window,
                                 UINT const message,
                                 WPARAM const wparam,
                                 LPARAM const lparam) noexcept;

  // CreateAndShow 직후 호출되어 하위 클래스 설정을 수행한다.
  virtual bool OnCreate();

  // Destroy 시점에 하위 클래스 정리 코드를 실행한다.
  virtual void OnDestroy();

 private:
  friend class WindowClassRegistrar;

  // WM_NCCREATE 등을 처리해 논클라이언트 영역 DPI 스케일링을 켠다.
  static LRESULT CALLBACK WndProc(HWND const window,
                                  UINT const message,
                                  WPARAM const wparam,
                                  LPARAM const lparam) noexcept;

  // 윈도우 핸들에서 클래스 인스턴스 포인터를 얻는다.
  static Win32Window* GetThisFromHandle(HWND const window) noexcept;

  // 시스템 테마에 맞춰 창 프레임 테마를 갱신한다.
  static void UpdateTheme(HWND const window);

  bool quit_on_close_ = false;

  // 최상위 창 핸들.
  HWND window_handle_ = nullptr;

  // 플러터 콘텐츠가 들어가는 child 창 핸들.
  HWND child_content_ = nullptr;
};

#endif  // RUNNER_WIN32_WINDOW_H_
