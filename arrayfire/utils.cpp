#include "utils.h"

af_dtype GetDataType (lua_State * L, int index)
{
	af_dtype types[] = {
		f32, c32, f64, c64, b8, s32, u32, u8, s64, u64,
		// s16, u16???
	};

	const char * names[] = {
		"f32", "c32", "f64", "c64", "b8", "s32", "u32", "u8", "s64", "u64"
	};

	return types[luaL_checkoption(L, index, "f32", names)];
}

#define RESULT_CODE(what) case what: \
	lua_pushliteral(L, #what);		 \
	break;

void PushResult (lua_State * L, af_err err)
{
	switch (err)
	{
	RESULT_CODE(AF_SUCCESS)
	RESULT_CODE(AF_ERR_NO_MEM)
	RESULT_CODE(AF_ERR_DRIVER)
	RESULT_CODE(AF_ERR_RUNTIME)
	RESULT_CODE(AF_ERR_INVALID_ARRAY)
	RESULT_CODE(AF_ERR_ARG)
	RESULT_CODE(AF_ERR_SIZE)
	RESULT_CODE(AF_ERR_TYPE)
	RESULT_CODE(AF_ERR_DIFF_TYPE)
	RESULT_CODE(AF_ERR_BATCH)
	RESULT_CODE(AF_ERR_NOT_SUPPORTED)
	RESULT_CODE(AF_ERR_NOT_CONFIGURED)
	RESULT_CODE(AFF_ERR_NONFREE)
	RESULT_CODE(AF_ERR_NO_DBL)
	RESULT_CODE(AF_ERR_NO_GFX)
	RESULT_CODE(AF_ERR_INTERNAL)
	RESULT_CODE(AF_ERR_UNKNOWN)
	}
}

#undef RESULT_CODE

af_array GetArray (lua_State * L, int index)
{
	return *(af_array *)lua_touserdata(L, index);
}

void * NewArray (lua_State * L)
{
	void * amem = lua_newuserdata(L, sizeof(af_array)); // amem

	luaL_newmetatable(L, "af_array"); // amem, mt
	lua_setmetatable(L, -2); // amem

	return amem;
}

LuaDimsAndType::LuaDimsAndType (lua_State * L, int first)
{
	luaL_checktype(L, first + 1, LUA_TTABLE);

	int n;

	if (!lua_isnil(L, first)) n = lua_tointeger(L, first);

	else n = lua_objlen(L, first + 1);

	for (int i = 0; i < n; ++i)
	{
		lua_rawgeti(L, first + 1, i + 1);	// ..., n?, t[, type], ..., dim

		mDims.push_back(lua_tointeger(L, -1));

		lua_pop(L, 1);	// ..., n?, t[, type], ...
	}

	mType = GetDataType(L, first + 2);
}

template<typename T> void AddToVector (std::vector<char> & arr, T value)
{
	const char * bytes = (const char *)&value;

	for (auto i = arr.size(); i < arr.size() + sizeof(T); ++i) arr[i] = *bytes++;
}

template<typename T> T Float (lua_State * L, int index)
{
	return (T)lua_tonumber(L, index);
}

template<typename T> T Int (lua_State * L, int index)
{
	return (T)lua_tointeger(L, index);
}

template<typename T> void AddFloat (std::vector<char> & arr, lua_State * L, int index, int pos)
{
	lua_rawgeti(L, index, pos + 1);	// ..., arr, ..., float

	AddToVector(arr, Float<T>(L, -1));

	lua_pop(L, 1); // ..., arr, ...
}

template<typename T> void AddInt (std::vector<char> & arr, lua_State * L, int index, int pos)
{
	lua_rawgeti(L, index, pos + 1);	// ..., arr, ..., int

	AddToVector(arr, Int<T>(L, -1));

	lua_pop(L, 1); // ..., arr, ...
}

LuaData::LuaData (lua_State * L, int index, af_dtype type) : mType(type)
{
	// Non-string: build up from Lua array.
	if (!lua_isstring(L, index))
	{
		int count = lua_objlen(L, index);

		switch (type)
		{
		case b8:
		case u8:
			mData.reserve(count);
			break;
		// Docs list an s16, u16... ??
		case f32:
		case s32:
		case u32:
			mData.reserve(count * 4);
			break;
		case c32:
		case f64:
		case s64:
		case u64:
			mData.reserve(count * 8);
			break;
		case c64:
			mData.reserve(count * 16);
			break;
		}

		for (int i = 0; i < count; ++i)
		{
			switch (type)
			{
			case f32:
				AddFloat<float>(mData, L, index, i);
				break;
			case c32:
				// ?
				break;
			case f64:
				AddFloat<double>(mData, L, index, i);
				break;
			case c64:
				// ?
				break;
			case b8:
				AddInt<char>(mData, L, index, i);
				break;
			case s32:
				AddInt<int>(mData, L, index, i);
				break;
			case u32:
				AddInt<unsigned int>(mData, L, index, i);
				break;
			case u8:
				AddInt<unsigned char>(mData, L, index, i);
				break;
			case s64:
				AddInt<intl>(mData, L, index, i);
				break;
			case u64:
				AddInt<uintl>(mData, L, index, i);
				break;
			}
		}
	}

	// Already a Lua string: make a copy.
	else
	{
		const char * str = lua_tostring(L, index);

		mData.assign(str, str + lua_objlen(L, index));
	}
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