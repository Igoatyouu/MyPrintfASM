
int _my_printf(const char *format, ...);

int main(void)
{
    _my_printf("Basic string: %s\n", "Hello World!");
    _my_printf("Character: %c\n", 'A');
    _my_printf("Integer: %d\n", 42);
    _my_printf("Simple float: %f\n", 3.14159, 2);
    return 0;
}
