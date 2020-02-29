#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int main(int argc, char **argv)
{

    char matrix_name[200], vector_name[200], solution_name[200];
    int rows, columns, size, rank;
    int check_open;
    double total_time, io_time = 0, setup_time, kernel_time, mpi_time = 0;
    double total_start, io_start, setup_start, kernel_start, mpi_start;
    FILE *matrix_file, *vector_file, *solution_file;
    MPI_Status status;

    double *mat_size_double;
    MPI_File fh, fh_vec, fh_sol;

    if (argc != 2)
    {
        perror("The base name of the input matrix and vector files must be given\n");
        exit(-1);
    }

    int print_a = 0;
    int print_b = 0;
    int print_x = 0;

    sprintf(matrix_name, "%s.bin", argv[1]);
    sprintf(vector_name, "%s_vec.bin", argv[1]);
    sprintf(solution_name, "%s_sol.bin", argv[1]);

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    
    if (rank == 0)
    {
        printf("Solving the Ax=b system with Gaussian Elimination:\n");
        printf("READ:  Matrix   (A) file name: \"%s\"\n", matrix_name);
        printf("READ:  RHS      (b) file name: \"%s\"\n", vector_name);
        printf("WRITE: Solution (x) file name: \"%s\"\n", solution_name);
    }

    total_start = MPI_Wtime();

    int row, column, index;
    
    /**************************************************/
    /* Start input matrix A */

    io_start = MPI_Wtime(); //io time start

    check_open = MPI_File_open(MPI_COMM_WORLD, matrix_name, MPI_MODE_RDWR | MPI_MODE_CREATE, MPI_INFO_NULL, &fh);
    if (check_open)
    {
        perror("Could not open the specified matrix file");
        MPI_Abort(MPI_COMM_WORLD, -1);
    }

    mat_size_double = (double *)malloc(2 * sizeof(double));
    MPI_File_read_all(fh, mat_size_double, 2, MPI_DOUBLE, &status);
    columns = mat_size_double[0];
    rows = mat_size_double[1];
    if (rows != columns)
    {
        perror("Only square matrices are allowed\n");
        MPI_Abort(MPI_COMM_WORLD, -1);
    }
    if (rows % size != 0)
    {
        perror("The matrix should be divisible by the number of processes\n");
        MPI_Abort(MPI_COMM_WORLD, -1);
    }

    setup_start = MPI_Wtime(); //setup time start

    int local_block_size = rows / size; //LBS
    double *matrix_local_block = (double *)malloc(local_block_size * rows * sizeof(double)); //MLB
    int mlb_offset = local_block_size * rows;  //matrix_local_block offset
    int mlb_memory_offset = sizeof(double) * ( 2 + rank * mlb_offset); //offset by byte! very inportant!!!

    setup_time = MPI_Wtime() - setup_start; //setup end

    // collectivelly reads matrix A with offset into all ranks
    MPI_File_read_at_all(fh, mlb_memory_offset, matrix_local_block, local_block_size * rows, MPI_DOUBLE, &status);
    MPI_File_close(&fh);
    /* End input matrix A */
    /**************************************************/
    /* Start input vector b */
    check_open = MPI_File_open(MPI_COMM_WORLD, vector_name, MPI_MODE_RDWR | MPI_MODE_CREATE, MPI_INFO_NULL, &fh_vec);

    if (check_open){
        perror("Could not open the specified vector file");
        MPI_Abort(MPI_COMM_WORLD, -1);
    }

    setup_start = MPI_Wtime(); //setup time start

    int rhs_rows;
    double *rhs_rows_double = malloc(sizeof(double));
    double *rhs_local_block = (double *)malloc(local_block_size * sizeof(double));
    int rhs_lb_offset = local_block_size;                         //matrix_local_block offset
    int rhs_lb_memory_offset = sizeof(double) * ( 1 + rank * rhs_lb_offset);  //offset by byte! very inportant!!!

    setup_time = MPI_Wtime() - setup_start; //setup end

    MPI_File_read_all(fh_vec, rhs_rows_double, 1, MPI_DOUBLE, &status);
    rhs_rows = *rhs_rows_double;
    if (rhs_rows != rows){
        perror("RHS rows must match the sizes of A");
        MPI_Abort(MPI_COMM_WORLD, -1);
    }

    MPI_File_read_at_all(fh_vec, rhs_lb_memory_offset, rhs_local_block, local_block_size, MPI_DOUBLE, &status);
    MPI_File_close(&fh_vec);
    /* End input vector b */
    /**************************************************/

    io_time += MPI_Wtime() - io_start; //io time end

    /**************************************************/
    // solution = (double *)malloc(rows * sizeof(double));

    setup_start = MPI_Wtime(); //setup time start

    int i;
    
    int process, column_pivot;
    double tmp, pivot;
    double *pivots = (double *)malloc((local_block_size + (rows * local_block_size) + 1) * sizeof(double));
    double *local_work_buffer = (double *)malloc(local_block_size * sizeof(double));
    double *accumulation_buffer = (double *)malloc(local_block_size * 2 * sizeof(double));
    double *solution_local_block = (double *)malloc(local_block_size * sizeof(double));

    setup_time = MPI_Wtime() - setup_start; //setup end

    //////below start comopute!//////////////////////////////
    kernel_start = MPI_Wtime(); // computing start

    //Ranks except rank 0 receices pivots from other rank in upstairs
    for (process = 0; process < rank; process++)
    {
        mpi_start = MPI_Wtime();
        MPI_Recv(pivots, (local_block_size * rows + local_block_size + 1), MPI_DOUBLE, process, process, MPI_COMM_WORLD, &status);
        mpi_time += MPI_Wtime() - mpi_start;

        //Processes in downstairs do GE with pivot from upstairs
        for (row = 0; row < local_block_size; row++)
        {
            column_pivot = ((int)pivots[0]) * local_block_size + row;
            for (i = 0; i < local_block_size; i++)
            {
                index = i * rows;
                tmp = matrix_local_block[index + column_pivot];
                for (column = column_pivot; column < columns; column++)
                {
                    matrix_local_block[index + column] -= tmp * pivots[(row * rows) + (column + local_block_size + 1)];
                }
                rhs_local_block[i] -= tmp * pivots[row + 1];
                matrix_local_block[index + column_pivot] = 0.0;
            }
        }
    }

    for (row = 0; row < local_block_size; row++)
    {
        //Step0, choice the value of pivot in row[i]

        column_pivot = (rank * local_block_size) + row;
        index = row * rows;
        // assign the value of pivot in row[i]  from MLB
        pivot = matrix_local_block[index + column_pivot];
        assert(pivot != 0);

        //Step1-Make all elements in local column[j] in row[i], divide by pivot
        for (column = column_pivot; column < columns; column++)
        {
            matrix_local_block[index + column] = matrix_local_block[index + column] / pivot;
            pivots[index + column + local_block_size + 1] = matrix_local_block[index + column];
        }

        local_work_buffer[row] = (rhs_local_block[row]) / pivot;
        pivots[row + 1] = local_work_buffer[row];

        //Step2 - Do local_column[c]_row[i] - pivot_row_global[0](value = 1) x local_column_pivot_row[i],
        for (i = (row + 1); i < local_block_size; i++)
        {
            tmp = matrix_local_block[i * rows + column_pivot];
            for (column = column_pivot + 1; column < columns; column++)
            { //c
                matrix_local_block[i * rows + column] -= tmp * pivots[index + column + local_block_size + 1];
            }
            rhs_local_block[i] -= tmp * local_work_buffer[row];
            matrix_local_block[i * rows + row] = 0; // assign 0 to the element before the pivot in row[i]
        }
    }

    //send pivot to all rank in downstairs
    for (process = (rank + 1); process < size; process++)
    {
        pivots[0] = (double)rank;
        mpi_start = MPI_Wtime();
        MPI_Send(pivots, (local_block_size * rows + local_block_size + 1), MPI_DOUBLE, process, rank, MPI_COMM_WORLD);
        mpi_time += MPI_Wtime() - mpi_start;
    }

    for (process = (rank + 1); process < size; ++process)
    {
        mpi_start = MPI_Wtime();
        MPI_Recv(accumulation_buffer, (2 * local_block_size), MPI_DOUBLE, process, process, MPI_COMM_WORLD, &status);
        mpi_time += MPI_Wtime() - mpi_start;

        for (row = (local_block_size - 1); row >= 0; row--)
        {
            for (column = (local_block_size - 1); column >= 0; column--)
            {
                index = (int)accumulation_buffer[column];
                local_work_buffer[row] -= accumulation_buffer[local_block_size + column] * matrix_local_block[row * rows + index];
            }
        }
    }

    for (row = (local_block_size - 1); row >= 0; row--)
    {
        index = rank * local_block_size + row;
        accumulation_buffer[row] = (double)index;
        accumulation_buffer[local_block_size + row] = solution_local_block[row] = local_work_buffer[row];
        for (i = (row - 1); i >= 0; i--)
        {
            local_work_buffer[i] -= solution_local_block[row] * matrix_local_block[(i * rows) + index];
        }
    }

    for (process = 0; process < rank; process++)
    {
        mpi_start = MPI_Wtime();
        MPI_Send(accumulation_buffer, (2 * local_block_size), MPI_DOUBLE, process, rank, MPI_COMM_WORLD);
        mpi_time += MPI_Wtime() - mpi_start;
    }

    kernel_time = MPI_Wtime() - kernel_start; // computing  end

    //////comopute ending////////////////////////////
    /**************************************************/
    /* Start output vector x (solution) */
    io_start = MPI_Wtime(); //io (output) start
    MPI_File_open(MPI_COMM_WORLD, solution_name, MPI_MODE_RDWR | MPI_MODE_CREATE, MPI_INFO_NULL, &fh_sol);

    int sol_lb_offset = local_block_size;                               //matrix_local_block offset
    int sol_lb_memory_offset = sizeof(double) * (rank * sol_lb_offset); //offset by byte! very inportant!!!

    MPI_File_write_at_all(fh_sol, sol_lb_memory_offset, solution_local_block, local_block_size, MPI_DOUBLE, &status);
    MPI_File_close(&fh_sol);
    io_time += MPI_Wtime() - io_start; ////io (output) End

    /* End output vector x (solution) */
    /**************************************************/

    total_time = MPI_Wtime() - total_start;

    printf("[R%02d] Times: IO: %f; Setup: %f; Compute: %f; MPI: %f; Total: %f;\n",
           rank, io_time, setup_time, kernel_time, mpi_time, total_time);

    free(matrix_local_block);
    free(rhs_local_block);
    free(pivots);
    free(local_work_buffer);
    free(accumulation_buffer);
    free(solution_local_block);

    free(mat_size_double);

    MPI_Finalize();
    return 0;
}
