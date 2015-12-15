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

int APIENTRY _tWinMain(_In_ HINSTANCE hInstance,
                     _In_opt_ HINSTANCE hPrevInstance,
                     _In_ LPTSTR    lpCmdLine,
                     _In_ int       nCmdShow)
{
	UNREFERENCED_PARAMETER(hPrevInstance);
	UNREFERENCED_PARAMETER(lpCmdLine);

	RedirectIOToConsole();

	// TODO: Restructure this as a loop, allow IO via pipe or whatever as alternative (when a process)
	// Want persistent, probably, to facilitate communication

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

		if (lua_pcall(L, 1, 0, 0)) printf("%s\n", lua_tostring(L, -1));

		lua_close(L);
	}

	else printf("Usage: enter a script name");

	getc(stdin);

	return 0;
}

/*
wchar_t * wzSecurityDescriptor =
L"D:"
L"(D;OICI;GA;;;BG)" // Deny access to built-in guests
L"(D;OICI;GA;;;AN)" // Deny access to anonymous logon
L"(D;OICI;GA;;;NS)" // Deny access to network service
L"(D;OICI;GA;;;NU)" // Deny access to network users
L"(A;OICI;GRGWGX;;;CO)" // Allow read/write/execute to
creator/owner
L"(A;OICI;GA;;;BA)"; // Allow full control to
administrators

// Check this return code!
ConvertStringSecurityDescriptorToSecurityDescriptor(
wzSecurityDescriptor,
SDDL_REVISION_1,
&sa.lpSecurityDescriptor, // <-- sa = SECURITY_ATTRIBUTES
NULL
);
*/

/*
#include <windows.h> 
#include <stdio.h>
#include <conio.h>
#include <tchar.h>

#define BUFSIZE 512
 
int _tmain(int argc, TCHAR *argv[]) 
{ 
   HANDLE hPipe; 
   LPTSTR lpszWrite = TEXT("Default message from client"); 
   TCHAR chReadBuf[BUFSIZE]; 
   BOOL fSuccess; 
   DWORD cbRead, dwMode; 
   LPTSTR lpszPipename = TEXT("\\\\.\\pipe\\mynamedpipe"); 

   if( argc > 1)
   {
      lpszWrite = argv[1]; 
   }
 
   // Try to open a named pipe; wait for it, if necessary. 
    while (1) 
   { 
      hPipe = CreateFile( 
         lpszPipename,   // pipe name 
         GENERIC_READ |  // read and write access 
         GENERIC_WRITE, 
         0,              // no sharing 
         NULL,           // default security attributes
         OPEN_EXISTING,  // opens existing pipe 
         0,              // default attributes 
         NULL);          // no template file 
 
      // Break if the pipe handle is valid. 
      if (hPipe != INVALID_HANDLE_VALUE) 
         break; 
 
      // Exit if an error other than ERROR_PIPE_BUSY occurs. 
      if (GetLastError() != ERROR_PIPE_BUSY) 
      {
         printf("Could not open pipe\n"); 
         return 0;
      }
 
      // All pipe instances are busy, so wait for 20 seconds. 
      if (! WaitNamedPipe(lpszPipename, 20000) ) 
      {
         printf("Could not open pipe\n"); 
         return 0;
      }
  } 
 
   // The pipe connected; change to message-read mode. 
   dwMode = PIPE_READMODE_MESSAGE; 
   fSuccess = SetNamedPipeHandleState( 
      hPipe,    // pipe handle 
      &dwMode,  // new pipe mode 
      NULL,     // don't set maximum bytes 
      NULL);    // don't set maximum time 
   if (!fSuccess) 
   {
      printf("SetNamedPipeHandleState failed.\n"); 
      return 0;
   }
 
   // Send a message to the pipe server and read the response. 
   fSuccess = TransactNamedPipe( 
      hPipe,                  // pipe handle 
      lpszWrite,              // message to server
      (lstrlen(lpszWrite)+1)*sizeof(TCHAR), // message length 
      chReadBuf,              // buffer to receive reply
      BUFSIZE*sizeof(TCHAR),  // size of read buffer
      &cbRead,                // bytes read
      NULL);                  // not overlapped 

   if (!fSuccess && (GetLastError() != ERROR_MORE_DATA)) 
   {
      printf("TransactNamedPipe failed.\n"); 
      return 0;
   }
 
   while(1)
   { 
      _tprintf(TEXT("%s\n"), chReadBuf);

      // Break if TransactNamedPipe or ReadFile is successful
      if(fSuccess)
         break;

      // Read from the pipe if there is more data in the message.
      fSuccess = ReadFile( 
         hPipe,      // pipe handle 
         chReadBuf,  // buffer to receive reply 
         BUFSIZE*sizeof(TCHAR),  // size of buffer 
         &cbRead,  // number of bytes read 
         NULL);    // not overlapped 

      // Exit if an error other than ERROR_MORE_DATA occurs.
      if( !fSuccess && (GetLastError() != ERROR_MORE_DATA)) 
         break;
      else _tprintf( TEXT("%s\n"), chReadBuf); 
   }

   _getch(); 

   CloseHandle(hPipe); 
 
   return 0; 
}
*/

/*
#include <windows.h> 
#include <stdio.h>
#include <conio.h>
#include <tchar.h>

#define BUFSIZE 512
 
int _tmain(int argc, TCHAR *argv[]) 
{ 
   LPTSTR lpszWrite = TEXT("Default message from client"); 
   TCHAR chReadBuf[BUFSIZE]; 
   BOOL fSuccess; 
   DWORD cbRead; 
   LPTSTR lpszPipename = TEXT("\\\\.\\pipe\\mynamedpipe"); 

   if( argc > 1)
   {
      lpszWrite = argv[1]; 
   }
 
   fSuccess = CallNamedPipe( 
      lpszPipename,        // pipe name 
      lpszWrite,           // message to server 
      (lstrlen(lpszWrite)+1)*sizeof(TCHAR), // message length 
      chReadBuf,              // buffer to receive reply 
      BUFSIZE*sizeof(TCHAR),  // size of read buffer 
      &cbRead,                // number of bytes read 
      20000);                 // waits for 20 seconds 
 
   if (fSuccess || GetLastError() == ERROR_MORE_DATA) 
   { 
      _tprintf( TEXT("%s\n"), chReadBuf ); 
    
      // The pipe is closed; no more data can be read. 
 
      if (! fSuccess) 
      {
         printf("\nExtra data in message was lost\n"); 
      }
   }
 
   _getch(); 

   return 0; 
}

*/

/*
PIPE_ACCESS_DUPLEX (0x00000003)	FILE_GENERIC_READ, FILE_GENERIC_WRITE, and SYNCHRONIZE
PIPE_ACCESS_INBOUND (0x00000001)	FILE_GENERIC_READ and SYNCHRONIZE
PIPE_ACCESS_OUTBOUND (0x00000002)	FILE_GENERIC_WRITE and SYNCHRONIZE
*/

/*
CreateProcess(NULL, lpszCommandLine, NULL, NULL, FALSE, 
              CREATE_NO_WINDOW, NULL, NULL, &si, &pi);

STARTUPINFO si = { 0 };
    si.cb = sizeof(si);
    si.dwFlags = STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW;
    si.hStdInput = GetStdHandle(STD_INPUT_HANDLE);
    si.hStdOutput =  GetStdHandle(STD_OUTPUT_HANDLE);
    si.hStdError = GetStdHandle(STD_ERROR_HANDLE);
    si.wShowWindow = SW_HIDE;
*/

/*
#include <windows.h>
#include <stdio.h>
#include <tchar.h>

void _tmain( int argc, TCHAR *argv[] )
{
    STARTUPINFO si;
    PROCESS_INFORMATION pi;

    ZeroMemory( &si, sizeof(si) );
    si.cb = sizeof(si);
    ZeroMemory( &pi, sizeof(pi) );

    if( argc != 2 )
    {
        printf("Usage: %s [cmdline]\n", argv[0]);
        return;
    }

    // Start the child process. 
    if( !CreateProcess( NULL,   // No module name (use command line)
        argv[1],        // Command line
        NULL,           // Process handle not inheritable
        NULL,           // Thread handle not inheritable
        FALSE,          // Set handle inheritance to FALSE
        0,              // No creation flags
        NULL,           // Use parent's environment block
        NULL,           // Use parent's starting directory 
        &si,            // Pointer to STARTUPINFO structure
        &pi )           // Pointer to PROCESS_INFORMATION structure
    ) 
    {
        printf( "CreateProcess failed (%d).\n", GetLastError() );
        return;
    }

    // Wait until child process exits.
    WaitForSingleObject( pi.hProcess, INFINITE );

    // Close process and thread handles. 
    CloseHandle( pi.hProcess );
    CloseHandle( pi.hThread );
}
*/
