// Win32 Runner가 사용하는 유틸리티 함수 선언.
#ifndef RUNNER_UTILS_H_
#define RUNNER_UTILS_H_

#include <string>
#include <vector>

// 프로세스용 콘솔을 만들고 stdout/stderr 을 연결한다.
void CreateAndAttachConsole();

// UTF-16 wchar_t* 문자열을 UTF-8 std::string 으로 변환한다.
std::string Utf8FromUtf16(const wchar_t* utf16_string);

// UTF-8 로 인코딩된 명령줄 인자들을 벡터로 반환한다.
std::vector<std::string> GetCommandLineArguments();

#endif  // RUNNER_UTILS_H_
