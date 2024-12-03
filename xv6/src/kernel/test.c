#define MAX_PROC 10
#define TS0 1
#define TS1 4
#define TS2 8
#define TS3 16
typedef struct queue
{
    struct proc *p[MAX_PROC];
    int front;
    int rear;
    int num_processes
} queue;

queue pq[4];

void queue_init()
{
    for (int i = 0; i < 4; i++)
    {
        pq[i].front = -1;
        pq[i].rear = -1;
        pq[i].num_processes = 0;
    }
}
void addProcess(struct proc *p, int qn)
{
    if (pq[qn].num_processes == MAX_PROC)
    {
        for (int i = 0; i < 4; i++)
        {
            if (pq[qn].num_processes != MAX_PROC)
            {
                if (pq[qn].num_processes == 0)
                {
                    pq[qn].front = 0;
                    pq[qn].rear = 0;
                    pq[qn].p[pq[qn].rear] = p;
                }
                else
                {
                    pq[qn].rear = (pq[qn].rear + 1) % MAX_PROC;
                    pq[qn].p[pq[qn].rear] = p;
                }
                pq[qn].num_processes++;
                break;
            }
        }
    }
    else
    {
        if (pq[qn].num_processes == 0)
        {
            pq[qn].front = 0;
            pq[qn].rear = 0;
            pq[qn].p[pq[qn].rear] = p;
        }
        else
        {
            pq[qn].rear = (pq[qn].rear + 1) % MAX_PROC;
            pq[qn].p[pq[qn].rear] = p;
        }
        pq[qn].num_processes++;
    }
}

struct proc *removeProcess(int qn)
{
    struct proc *p = pq[qn].p[pq[qn].front];

    if (pq[qn].num_processes == 1)
    {
        pq[qn].front = -1;
        pq[qn].rear = -1;
    }
    else
    {
        pq[qn].front = (pq[qn].front + 1) % MAX_PROC;
    }

    pq[qn].num_processes--;
    return p;
}

int non_empty()
{
    for (int i = 0; i < 4; i++)
    {
        if (pq[i].num_processes > 0)
            return i;
    }
    return -1;
}

void scheduler(void)
{
    struct proc *p;
    struct cpu *c = mycpu();
    printf("Default\n");
    c->proc = 0;
    int pb_time = 0;
    for (;;)
    {
        intr_on();
        int ne_empty = non_empty();
        if (ne_empty == -1)
        {
            printf("All queues are empty\n");
        }
        else
        {
            int num_proc = pq[ne_empty].num_processes;
            for (int i = 0; i < num_proc; i++)
            {
                struct proc *p = removeProcess(ne_empty);
                acquire(&p->lock);
                if (p->state == RUNNABLE)
                {
                    // Switch to chosen process.  It is the process's job
                    // to release its lock and then reacquire it
                    // before jumping back to us.
                    p->state = RUNNING;
                    c->proc = p;
                    int start = ticks;
                    swtch(&c->context, &p->context);
                    int end = ticks;
                    int time_taken = end - start;
                    // p->time_taken
                    if (ne_empty == 0)
                    {
                        if (time_taken >= TS0)
                            addProcess(p, 1);
                        else
                            addProcess(p, 0);
                    }
                    else if (ne_empty == 1)
                    {
                        if (time_taken >= TS1)
                            addProcess(p, 2);
                        else
                            addProcess(p, 1);
                    }
                    else if (ne_empty == 2)
                    {
                        if (time_taken >= TS2)
                            addProcess(p, 3);
                        else
                            addProcess(p, 2);
                    }
                    else if (ne_empty == 3)
                    {
                        addProcess(p, 3);
                    }
                    // Process is done running for now.
                    // It should have changed its p->state before coming back.
                    c->proc = 0;
                }
                release(&p->lock);
                pb_time += ticks;
                if (pb_time >= 48)
                {
                    for (int i = 1; i < 4; i++)
                    {
                        while (pq[i].num_processes > 0)
                        {
                            struct proc *p = removeProcess(i);
                            addProcess(p, 0); // Move the process to queue 0
                        }
                    }
                    pb_time = 0;
                }
            }
        }
    }
}
p->state = RUNNING;
c->proc = p;
int start = ticks;
swtch(&c->context, &p->context);
int end = ticks;
int time_taken = end - start;
// p->time_taken
if (ne_empty == 0)
{
    if (time_taken >= TS0)
        addProcess(p, 1);
    else
        addProcess(p, 0);
}
else if (ne_empty == 1)
{
    if (time_taken >= TS1)
        addProcess(p, 2);
    else
        addProcess(p, 1);
}
else if (ne_empty == 2)
{
    if (time_taken >= TS2)
        addProcess(p, 3);
    else
        addProcess(p, 2);
}
else if (ne_empty == 3)
{
    addProcess(p, 3);
}
// Process is done running for now.
// It should have changed its p->state before coming back.
c->proc = 0;
}
release(&p->lock);
pb_time += ticks;
if (pb_time >= 48)
{
    for (int i = 1; i < 4; i++)
    {
        while (pq[i].num_processes > 0)
        {
            struct proc *p = removeProcess(i);
            addProcess(p, 0); // Move the process to queue 0
        }
    }
    pb_time = 0;
}