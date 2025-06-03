#ifndef HEAP_H
#define HEAP_H

#define MCB_SIZE 32

#define ROUNDUP(x) (1 << LOG2_CEIL((x + MCB_SIZE - 1) / MCB_SIZE))
#define LOG2(x) ({ int r = 0; while ((1 << r) < x) r++; r; })
#define LOG2_CEIL(x) ({ int r = 0; while ((1 << r) < x) r++; r; })
#define BUDDY_OF(i, k) (i ^ (1 << k))

void* _kinit(void* heap_start, int heap_size);
void* _kalloc(int size);
void _kfree(void* addr);

#endif
