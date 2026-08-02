
int main(void) {
    volatile unsigned int *ram_ptr = (volatile unsigned int *)0x00000000;
    
    unsigned int data_pattern = 0x01;
    for (int i = 0; i < 64; i++) {
        ram_ptr[i] = data_pattern;
        data_pattern++;
    }

    while (1) { }
}
