#include <stdio.h>

#define IP_REG 4

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
    int regs[6] = {0};
    int ip = 0;
    instruction program[] = {
        {OP_addi, 4, 16, 4},
        {OP_seti, 1, 2, 3},
        {OP_seti, 1, 6, 1},
        {OP_mulr, 3, 1, 2},
        {OP_eqrr, 2, 5, 2},
        {OP_addr, 2, 4, 4},
        {OP_addi, 4, 1, 4},
        {OP_addr, 3, 0, 0},
        {OP_addi, 1, 1, 1},
        {OP_gtrr, 1, 5, 2},
        {OP_addr, 4, 2, 4},
        {OP_seti, 2, 8, 4},
        {OP_addi, 3, 1, 3},
        {OP_gtrr, 3, 5, 2},
        {OP_addr, 2, 4, 4},
        {OP_seti, 1, 4, 4},
        {OP_mulr, 4, 4, 4},

        {OP_addi, 5, 2, 5}, // 17
        {OP_mulr, 5, 5, 5},
        {OP_muli, 5, 19, 5}, // hack
        {OP_muli, 5, 11, 5},
        {OP_addi, 2, 5, 2},
        {OP_muli, 2, 22, 2}, // 22
        {OP_addi, 2, 18, 2},
        {OP_addr, 5, 2, 5},
        {OP_addr, 4, 0, 4},
        {OP_seti, 0, 6, 4},
        {OP_seti, 27, 8, 2}, // 27
        {OP_muli, 2, 28, 2}, // 28
        {OP_addi, 2, 29, 2}, // 29
        {OP_muli, 2, 30, 2}, // 30
        {OP_muli, 2, 14, 2},
        {OP_muli, 2, 32, 2}, // 32
        {OP_addr, 5, 2, 5},
        {OP_seti, 0, 1, 0},
        {OP_seti, 0, 5, 4}
    };
    const int program_length = sizeof(program)/ sizeof(*program);
    instruction *current_instruction;
    int cycles = 0;
    print_state(ip, regs);

    while (ip < program_length) {
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
        print_state(ip, regs);
    }
    printf("After %d cycles, reg0=%d\n", cycles, regs[0]);

    return 0;
}
