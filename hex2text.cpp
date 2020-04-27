#include <fstream>
#include <iostream>
#include <queue>
#include <iomanip>
using namespace std;

int main() {
        streampos size;
    char * memblock;
    ifstream file ("TRACE1.DAT", ios::in|ios::binary|ios::ate);
    //cout << "Opening file\n";
    if (file.is_open())
    {
        size = file.tellg();
        memblock = new char [size];
        file.seekg (0, ios::beg);

        file.read (memblock, size);

        //printf("FIFO Cache configurations.\n");
        for (int x = 0; x < size; x+=3){
            long addr = 0;
            // Load the next 3 bytes in reverse order
            for (int i = 2; i >= 0; i--) {
                addr = addr | (unsigned char)memblock[i+x];
                if (!(i == 0))
                    addr = addr << 8;
            }
            // shift address left 1 byte to get the full 4 byte reference
            //addr = addr << 8;
            cout << right << setiosflags(ios::internal) << setfill('0') << setw(8) << hex << addr << "\n";
        }
        
    }
}