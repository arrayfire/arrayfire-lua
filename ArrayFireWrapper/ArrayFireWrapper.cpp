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
}

void PushString (lua_State * L, LPTSTR str)
{
	char mbstr[MAX_PATH];

	size_t n;

	wcstombs_s(&n, mbstr, str, MAX_PATH);

	lua_pushstring(L, mbstr); // ..., str
}

int APIENTRY _tWinMain(_In_ HINSTANCE hInstance,
                     _In_opt_ HINSTANCE hPrevInstance,
                     _In_ LPTSTR    lpCmdLine,
                     _In_ int       nCmdShow)
{
	UNREFERENCED_PARAMETER(hPrevInstance);
	UNREFERENCED_PARAMETER(lpCmdLine);

	RedirectIOToConsole();

	if (_tcslen(lpCmdLine) > 0)
	{
		lua_State * L = luaL_newstate();

		luaL_openlibs(L);

		lua_getglobal(L, "package"); // package
		lua_getfield(L, -1, "path"); // package, package.path

#ifdef _WIN32
		wchar_t dir[MAX_PATH];

		GetCurrentDirectory(MAX_PATH, dir);

		lua_pushliteral(L, ";");// package, package.path, ";"

		PushString(L, dir);	// package, package.path, ";", "!"

		lua_pushliteral(L, "/../../scripts/?.lua"); // package, package.path, ";", "!", "../../scripts/?.lua"
		lua_concat(L, 4);	// package, "PATH/scripts/?.lua"
		lua_setfield(L, -2, "path");// package
		lua_pop(L, 1); // (clear)
#else
		// ???
#endif

		lua_getglobal(L, "require");// require

		PushString(L, lpCmdLine);	// require, path

		if (lua_pcall(L, 1, LUA_MULTRET, 0)) printf(lua_tostring(L, -1));

		lua_close(L);
	}

	else printf("Usage: enter a script name");

	getc(stdin);

	return 0;
}
