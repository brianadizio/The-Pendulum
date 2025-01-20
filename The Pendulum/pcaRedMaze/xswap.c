/*
 * xswap.c
 *
 * Code generation for function 'xswap'
 *
 */

/* Include files */
#include "xswap.h"
#include "pcaRed_types.h"
#include "rt_nonfinite.h"

/* Function Definitions */
void xswap(int n, emxArray_real_T *x, int ix0, int iy0)
{
  double *x_data;
  int k;
  x_data = x->data;
  for (k = 0; k < n; k++) {
    double temp;
    int i;
    int temp_tmp;
    temp_tmp = (ix0 + k) - 1;
    temp = x_data[temp_tmp];
    i = (iy0 + k) - 1;
    x_data[temp_tmp] = x_data[i];
    x_data[i] = temp;
  }
}

/* End of code generation (xswap.c) */
