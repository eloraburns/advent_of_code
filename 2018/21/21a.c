#include <stdio.h>

#define IP_REG 2

typedef enum {
    OP_addr,
    OP_addi,
    OP_mulr,
    OP_muli,
    OP_banr,
    OP_bani,
    OP_borr,
    OP_bori,
    OP_setr,
    OP_seti,
    OP_gtir,
    OP_gtri,
    OP_gtrr,
    OP_eqir,
    OP_eqri,
    OP_eqrr
} opcode;

typedef struct {
    opcode op;
    int a1;
    int a2;
    int a3;
} instruction;

void print_state(int ip, int regs[]) {
    printf("IP=%d\tr0=%d\tr1=%d\tr2=%d\tr3=%d\tr4=%d\tr5=%d\n", ip, regs[0], regs[1], regs[2], regs[3], regs[4], regs[5]);
}

int main(int argc, char **argv) {
    int regs[6] = {12935354, 0, 0, 0, 0, 0};
    int ip = 0;
    instruction program[] = {
      {OP_seti, 123, 0, 5},
      {OP_bani, 5, 456, 5},
      {OP_eqri, 5, 72, 5},
      {OP_addr, 5, 2, 2},
      {OP_seti, 0, 0, 2},
      {OP_seti, 0, 4, 5},
      {OP_bori, 5, 65536, 1},
      {OP_seti, 10678677, 3, 5},
      {OP_bani, 1, 255, 4},
      {OP_addr, 5, 4, 5},
      {OP_bani, 5, 16777215, 5},
      {OP_muli, 5, 65899, 5},
      {OP_bani, 5, 16777215, 5},
      {OP_gtir, 256, 1, 4},
      {OP_addr, 4, 2, 2},
      {OP_addi, 2, 1, 2},
      {OP_seti, 27, 5, 2},
      {OP_seti, 0, 6, 4},
      {OP_addi, 4, 1, 3},
      {OP_muli, 3, 256, 3},
      {OP_gtrr, 3, 1, 3},
      {OP_addr, 3, 2, 2},
      {OP_addi, 2, 1, 2},
      {OP_seti, 25, 4, 2},
      {OP_addi, 4, 1, 4},
      {OP_seti, 17, 6, 2},
      {OP_setr, 4, 6, 1},
      {OP_seti, 7, 5, 2},
      {OP_eqrr, 5, 0, 4}, // 28
      {OP_addr, 4, 2, 2},
      {OP_seti, 5, 4, 2}
    };
    const int program_length = sizeof(program)/ sizeof(*program);
    instruction *current_instruction;
    int cycles = 0;
    //print_state(ip, regs);

    while (ip < program_length) {
        if (ip == 28) print_state(ip, regs);
        cycles++;
        current_instruction = program + ip;

        switch (current_instruction->op) {
            case OP_addr:
                regs[current_instruction->a3] = regs[current_instruction->a1] + regs[current_instruction->a2];
                break;
            case OP_addi:
                regs[current_instruction->a3] = regs[current_instruction->a1] + current_instruction->a2;
                break;
            case OP_mulr:
                regs[current_instruction->a3] = regs[current_instruction->a1] * regs[current_instruction->a2];
                break;
            case OP_muli:
                regs[current_instruction->a3] = regs[current_instruction->a1] * current_instruction->a2;
                break;
            case OP_banr:
                regs[current_instruction->a3] = regs[current_instruction->a1] & regs[current_instruction->a2];
                break;
            case OP_bani:
                regs[current_instruction->a3] = regs[current_instruction->a1] & current_instruction->a2;
                break;
            case OP_borr:
                regs[current_instruction->a3] = regs[current_instruction->a1] | regs[current_instruction->a2];
                break;
            case OP_bori:
                regs[current_instruction->a3] = regs[current_instruction->a1] | current_instruction->a2;
                break;
            case OP_setr:
                regs[current_instruction->a3] = regs[current_instruction->a1];
                break;
            case OP_seti:
                regs[current_instruction->a3] = current_instruction->a1;
                break;
            case OP_gtir:
                regs[current_instruction->a3] = current_instruction->a1 > regs[current_instruction->a2];
                break;
            case OP_gtri:
                regs[current_instruction->a3] = regs[current_instruction->a1] > current_instruction->a2;
                break;
            case OP_gtrr:
                regs[current_instruction->a3] = regs[current_instruction->a1] > regs[current_instruction->a2];
                break;
            case OP_eqir:
                regs[current_instruction->a3] = current_instruction->a1 == regs[current_instruction->a2];
                break;
            case OP_eqri:
                regs[current_instruction->a3] = regs[current_instruction->a1] == current_instruction->a2;
                break;
            case OP_eqrr:
                regs[current_instruction->a3] = regs[current_instruction->a1] == regs[current_instruction->a2];
                break;
        }

        ip = regs[IP_REG];
        ip++;
        regs[IP_REG] = ip;
        //print_state(ip, regs);
    }
    printf("After %d cycles, reg0=%d\n", cycles, regs[0]);

    return 0;
}
