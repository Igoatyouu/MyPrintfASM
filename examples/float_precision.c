
int _my_printf(const char *format, ...);

int main(void)
{
    float pi = 3.14159;

    _my_printf("Float with different precisions:\n");
    _my_printf("2 decimals: %f\n", pi, 2);
    _my_printf("4 decimals: %f\n", pi, 4);
    _my_printf("0 decimals: %f\n", pi, 0);
    return 0;
}
