// ArrayFireWrapper.cpp : Defines the entry point for the application.
//

#include "stdafx.h"

extern "C" {
	#include <lua.h>
	#include <lualib.h>
	#include <lauxlib.h>
}

#include <stdio.h>
#include <io.h>
#include <fcntl.h>
#include <io.h>
#include <iostream>
#include <fstream>

#ifdef _WIN32
// http://www.cplusplus.com/forum/windows/58206/
void RedirectIOToConsole()
{
    int hConHandle;
    long lStdHandle;
    CONSOLE_SCREEN_BUFFER_INFO coninfo;
    FILE *fp;

// allocate a console for this app
    AllocConsole();

// set the screen buffer to be big enough to let us scroll text
    GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE),&coninfo);
    coninfo.dwSize.Y = 20;
    SetConsoleScreenBufferSize(GetStdHandle(STD_OUTPUT_HANDLE),coninfo.dwSize);

// redirect unbuffered STDOUT to the console
    lStdHandle = (long)GetStdHandle(STD_OUTPUT_HANDLE);
    hConHandle = _open_osfhandle(lStdHandle, _O_TEXT);

    fp = _fdopen( hConHandle, "w" );

    *stdout = *fp;

    setvbuf( stdout, NULL, _IONBF, 0 );

// redirect unbuffered STDIN to the console

    lStdHandle = (long)GetStdHandle(STD_INPUT_HANDLE);
    hConHandle = _open_osfhandle(lStdHandle, _O_TEXT);

    fp = _fdopen( hConHandle, "r" );
    *stdin = *fp;
    setvbuf( stdin, NULL, _IONBF, 0 );

// redirect unbuffered STDERR to the console
    lStdHandle = (long)GetStdHandle(STD_ERROR_HANDLE);
    hConHandle = _open_osfhandle(lStdHandle, _O_TEXT);

    fp = _fdopen( hConHandle, "w" );

    *stderr = *fp;

    setvbuf( stderr, NULL, _IONBF, 0 );

// make cout, wcout, cin, wcin, wcerr, cerr, wclog and clog
// point to console as well
    std::ios::sync_with_stdio();
}

void PushString (lua_State * L, LPTSTR str)
{
	char mbstr[MAX_PATH];

	size_t n;

	wcstombs_s(&n, mbstr, str, MAX_PATH);

	lua_pushstring(L, mbstr); // ..., str
}

// https://msdn.microsoft.com/en-us/library/windows/desktop/bb773748(v=vs.85).aspx
void path_strip_filename(TCHAR *Path) {
    size_t Len = _tcslen(Path);
    if (Len==0) {return;};
    size_t Idx = Len-1;
    while (TRUE) {
        TCHAR Chr = Path[Idx];
        if (Chr==TEXT('\\')||Chr==TEXT('/')) {
            if (Idx==0||Path[Idx-1]==':') {Idx++;};
            break;
        } else if (Chr==TEXT(':')) {
            Idx++; break;
        } else {
            if (Idx==0) {break;} else {Idx--;};
        };
    };
    Path[Idx] = TEXT('\0');
};
#endif

#ifdef _WIN32
int APIENTRY _tWinMain(_In_ HINSTANCE hInstance,
                     _In_opt_ HINSTANCE hPrevInstance,
                     _In_ LPTSTR    lpCmdLine,
                     _In_ int       nCmdShow)
{
	UNREFERENCED_PARAMETER(hPrevInstance);

	RedirectIOToConsole();
#endif

	// TODO: Restructure this as a loop, allow IO via pipe or whatever as alternative (when a process)
	// Want persistent, probably, to facilitate communication
#ifdef _WIN32
	if (_tcslen(lpCmdLine) > 0)
#endif
	{
		lua_State * L = luaL_newstate();

		luaL_openlibs(L);

		lua_getglobal(L, "package"); // package
		lua_getfield(L, -1, "path"); // package, package.path

#ifdef _WIN32
		wchar_t dir[MAX_PATH];

		GetCurrentDirectory(MAX_PATH, dir);

		size_t name_len = wcslen(L"cpp");

		while (true)
		{
			size_t len = wcslen(dir);

			if (len < name_len) break;
			if (wcscmp(dir + len - name_len, L"cpp") == 0) break;

			path_strip_filename(dir);
		}
		wprintf(L"DIR: %s\n", dir);
#endif
		int n = 0;

		for (const char * name : { "/../../lib/?.lua", "/../lua/?.lua" })
		{
			lua_pushliteral(L, ";");// package, package.path, ..., ";"
#ifdef _WIN32
			PushString(L, dir);	// package, package.path, ..., ";", "!"
#endif
			lua_pushstring(L, name); // package, package.path, ..., ";", "!", name

			n += 3;
		}

		lua_concat(L, n + 1);	// package, "PATH/*.lua"
		lua_setfield(L, -2, "path");// package
		lua_pop(L, 1); // (clear)

		// ???

		lua_getglobal(L, "require");// require
#ifdef _WIN32
		PushString(L, lpCmdLine);	// require, path
#endif
		if (lua_pcall(L, 1, 0, 0)) printf("%s\n", lua_tostring(L, -1));

		lua_close(L);
	}

	else printf("Usage: enter a script name");

	getc(stdin);

	return 0;
}
