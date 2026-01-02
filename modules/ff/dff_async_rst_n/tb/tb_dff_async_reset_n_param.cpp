#include "Vdff_async_reset_n_param.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

static const double MHz = 100.0;
static double timestamp = 0;
static VerilatedVcdC *trace;
static Vdff_async_reset_n_param *dut;

void half_tick(bool edge)
{
    dut->clk = edge;
    dut->eval();
    trace->dump(timestamp);
    timestamp += 500/MHz;
}
void tick()
{
    half_tick(1);
    half_tick(0);
}

int main(int argc, char **argv)
{
    // Initialize Verilators variables
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    // Crea un objeto para manejar el archivo VCD
    trace = new VerilatedVcdC;

    // Crea una instancia del diseño
    //Vdff_async_reset_n_param* dut = new Vdff_async_reset_n_param;
    dut = new Vdff_async_reset_n_param;

    // Asocia el objeto trace con el diseño (esto permite generar el dump)
    dut->trace(trace, 99);

    // Abre el archivo VCD para volcar la simulación
    trace->open("dump.vcd");

    //  Inicialización
    //      Reset
    dut->async_rst = 0;
    dut->data = 0xA;
    tick();

    dut->async_rst = 1;

    // Stimulus
    half_tick(1);
    dut->data = 0xB;
    half_tick(0);

    half_tick(1);
    dut->data = 0xC;
    half_tick(0);

    half_tick(1);
    dut->data = 0xD;
    half_tick(0);

    half_tick(1);
    dut->data = 0xE;
    half_tick(0);

    // Imprimir valor final
    printf("q = %x\n", dut->q);

    trace->close();
    delete trace;
    delete dut;

    return 0;
}