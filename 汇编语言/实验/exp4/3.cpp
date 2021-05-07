#include <iostream>
using namespace std;

char dbyte[] = { 0x34,0x45,0x56,0x67,0xaf };
int main() {
	for (int i = 0; i < 5; ++i) {
		cout << hex << (short)dbyte[i] << " ";
	}
	cout << endl;
	__asm {
		mov ebx, 0
		mov ecx, 5
		l1:
		mov dl, dbyte[ebx]
		rol dl, 4
		mov dbyte[ebx], dl
		inc ebx
		loop l1
	}
	for (int i = 0; i < 5; ++i) {
		cout << hex << (short)dbyte[i] << " ";
	}
	cout << endl;

	return 0;
}